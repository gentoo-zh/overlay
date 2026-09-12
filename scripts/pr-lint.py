#!/usr/bin/env python3
"""Check deterministic pull-request rules for gentoo-zh/overlay."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable

CHECK_IDS = (
    "title-format",
    "routine-bump-body",
    "no-ai-attribution",
    "closes-format",
    "new-package-nvchecker",
    "overlay-toml-sorted",
    "workflow-change",
    "checklist",
)

PACKAGE_FILE_RE = re.compile(r"^[^/]+/[^/]+/[^/]+$")
TABLE_RE = re.compile(r'^#?\["([^"]+)"\]$', re.MULTILINE)
TEMPLATE_RE = re.compile(r"^---\s*$", re.MULTILINE)
AI_ATTRIBUTION_RE = re.compile(
    r"Co-Authored-By:\s*.*(?:Claude|Copilot|Codex|GPT|ChatGPT|Gemini)|"
    r"Generated with|Claude-Session:|🤖",
    re.IGNORECASE,
)
NOREPLY_SIGNOFF_RE = re.compile(
    r"^Signed-off-by:.*@users\.noreply\.github\.com\b", re.IGNORECASE
)
OVERLAY_ISSUE_URL = "https://github.com/gentoo-zh/overlay/issues/"
OVERLAY_TOML = ".github/workflows/overlay.toml"


@dataclass(frozen=True)
class Change:
    status: str
    old_path: str | None
    new_path: str

    @property
    def paths(self) -> tuple[str, ...]:
        return tuple(path for path in (self.old_path, self.new_path) if path is not None)


@dataclass(frozen=True)
class Inputs:
    title: str
    body: str
    changes: tuple[Change, ...]
    commits: str
    overlay_toml: str | None
    base_overlay_toml: str | None
    subjects: tuple[str, ...] = ()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_name_status(text: str) -> tuple[Change, ...]:
    changes = []
    for line in text.splitlines():
        if not line:
            continue
        fields = line.split("\t")
        status = fields[0]
        if status.startswith(("R", "C")):
            if len(fields) != 3:
                raise ValueError(f"invalid rename status line: {line!r}")
            changes.append(Change(status, fields[1], fields[2]))
        else:
            if len(fields) != 2:
                raise ValueError(f"invalid name-status line: {line!r}")
            changes.append(Change(status, None, fields[1]))
    return tuple(changes)


def git_output(*args: str) -> str:
    result = subprocess.run(
        ["git", *args],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    if result.returncode:
        detail = result.stderr.strip() or "git command failed"
        raise RuntimeError(detail)
    return result.stdout


def split_range(value: str) -> tuple[str, str]:
    base, separator, head = value.partition("..")
    if separator != ".." or not base or not head:
        raise ValueError("--range must be BASE..HEAD")
    return base, head


def load_git_inputs(title: str, body: str, revision_range: str) -> Inputs:
    base, _ = split_range(revision_range)
    changes = parse_name_status(git_output("diff", "--name-status", "-M", revision_range))
    commits = git_output("log", "--format=%B", revision_range)
    subjects = tuple(line for line in git_output("log", "--format=%s", revision_range).splitlines() if line)
    overlay_changed = any(OVERLAY_TOML in change.paths for change in changes)
    overlay_toml = read_text(Path(OVERLAY_TOML)) if overlay_changed else None
    base_overlay_toml = (
        git_output("show", f"{base}:{OVERLAY_TOML}") if overlay_changed else None
    )
    return Inputs(title, body, changes, commits, overlay_toml, base_overlay_toml, subjects)


def load_fixture_inputs(directory: Path) -> Inputs:
    changes = parse_name_status(read_text(directory / "diff.name-status"))
    overlay = directory / "overlay.toml"
    base_overlay = directory / "overlay.base.toml"
    return Inputs(
        read_text(directory / "title.txt").rstrip("\n"),
        read_text(directory / "body.md"),
        changes,
        read_text(directory / "commits.txt"),
        read_text(overlay) if overlay.exists() else None,
        read_text(base_overlay) if base_overlay.exists() else None,
        tuple(
            line for line in read_text(directory / "commits.txt").splitlines()[:1] if line
        ),
    )


def package_path(path: str, filename: str) -> str | None:
    parts = path.split("/")
    if len(parts) != 3 or parts[2] != filename:
        return None
    return "/".join(parts[:2])


def is_ebuild_path(path: str) -> bool:
    return bool(PACKAGE_FILE_RE.fullmatch(path) and path.endswith(".ebuild"))


def overlay_keys(text: str | None) -> tuple[str, ...]:
    return tuple(TABLE_RE.findall(text or ""))


def check_title_format(inputs: Inputs) -> Iterable[str]:
    # AGENTS.md § Commit and PR Text: the PR title is the commit subject verbatim;
    # subject format and length are pkgcheck's GitCommitMessageCheck job
    title = inputs.title.strip()
    if "\n" in inputs.title.strip("\n"):
        yield "title must be one line"
        return
    if inputs.subjects and title not in inputs.subjects:
        yield "title must equal the subject of the commit carrying the main change"


def is_routine_bump(changes: tuple[Change, ...]) -> bool:
    if not changes:
        return False
    has_manifest = False
    has_rename = False
    for change in changes:
        manifest_package = package_path(change.new_path, "Manifest")
        if change.status == "M" and manifest_package:
            has_manifest = True
            continue
        # only an unchanged ebuild (R100) is routine; an edited one needs a reason
        if (
            change.status == "R100"
            and change.old_path is not None
            and is_ebuild_path(change.old_path)
            and is_ebuild_path(change.new_path)
            and Path(change.old_path).parent == Path(change.new_path).parent
        ):
            has_rename = True
            continue
        return False
    return has_manifest and has_rename


def body_before_template(body: str) -> str:
    return TEMPLATE_RE.split(body, maxsplit=1)[0]


def check_routine_bump_body(inputs: Inputs) -> Iterable[str]:
    if not is_routine_bump(inputs.changes):
        return
    lines = [line.strip() for line in body_before_template(inputs.body).splitlines() if line.strip()]
    if not lines or any(re.fullmatch(r"Closes #\d+", line) is None for line in lines):
        yield "routine bump body must contain only bare Closes #<n> lines"


def check_no_ai_attribution(inputs: Inputs) -> Iterable[str]:
    for label, text in (("PR body", inputs.body), ("commit message", inputs.commits)):
        for line in text.splitlines():
            if AI_ATTRIBUTION_RE.search(line):
                yield f"{label} contains forbidden AI attribution"
    for line in inputs.commits.splitlines():
        if NOREPLY_SIGNOFF_RE.search(line):
            yield "commit message uses a GitHub noreply Signed-off-by address"


def check_closes_format(inputs: Inputs) -> Iterable[str]:
    for text in (inputs.body, inputs.commits):
        for line in text.splitlines():
            if OVERLAY_ISSUE_URL in line:
                yield "overlay issue links must use bare Closes #<n>"
            if re.search(r"\bFixes\s+#\d+\b", line, re.IGNORECASE):
                yield "use Closes #<n>, not Fixes #<n>"
            if re.match(r"^Bug:\s*", line, re.IGNORECASE):
                yield "issue references must use bare Closes #<n>"
            if re.search(r"\bCloses:\s*https://bugs\.gentoo\.org", line, re.IGNORECASE):
                yield "issue references must use bare Closes #<n>"
            if re.search(r"\bCloses\s+#\d+\b", line, re.IGNORECASE) and not re.fullmatch(
                r"Closes #\d+", line.strip(), re.IGNORECASE
            ):
                yield "issue references must use bare Closes #<n>"


def new_package_paths(changes: tuple[Change, ...]) -> tuple[str, ...]:
    packages = []
    for change in changes:
        package = package_path(change.new_path, "metadata.xml")
        if change.status == "A" and package and package.split("/", 1)[0] not in {
            "acct-group",
            "acct-user",
            "virtual",
        }:
            packages.append(package)
    return tuple(packages)


def check_new_package_nvchecker(inputs: Inputs) -> Iterable[str]:
    changed_overlay = any(OVERLAY_TOML in change.paths for change in inputs.changes)
    keys = set(overlay_keys(inputs.overlay_toml))
    for package in new_package_paths(inputs.changes):
        if not changed_overlay or package not in keys:
            yield f"new package {package} lacks an overlay.toml entry in this diff"


def check_overlay_toml_sorted(inputs: Inputs) -> Iterable[str]:
    if not any(OVERLAY_TOML in change.paths for change in inputs.changes):
        return
    keys = overlay_keys(inputs.overlay_toml)
    existing = set(overlay_keys(inputs.base_overlay_toml))
    for index, key in enumerate(keys):
        if key in existing:
            continue
        previous = keys[index - 1] if index else None
        following = keys[index + 1] if index + 1 < len(keys) else None
        if (previous is not None and previous > key) or (
            following is not None and key > following
        ):
            yield f'new key "{key}" is not sorted between its adjacent keys'


def check_workflow_change(inputs: Inputs) -> Iterable[str]:
    if any(
        path.startswith(".github/workflows/") and path.endswith(".yml")
        for change in inputs.changes
        for path in change.paths
    ):
        yield "workflow files changed; needs a maintainer to review"


def check_checklist(inputs: Inputs) -> Iterable[str]:
    if re.search(r"^- \[ \] I have run", inputs.body, re.MULTILINE):
        yield "pkgcheck checklist item is not checked"


CHECKS: tuple[tuple[str, Callable[[Inputs], Iterable[str]]], ...] = (
    ("title-format", check_title_format),
    ("routine-bump-body", check_routine_bump_body),
    ("no-ai-attribution", check_no_ai_attribution),
    ("closes-format", check_closes_format),
    ("new-package-nvchecker", check_new_package_nvchecker),
    ("overlay-toml-sorted", check_overlay_toml_sorted),
    ("workflow-change", check_workflow_change),
    ("checklist", check_checklist),
)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Check deterministic gentoo-zh pull-request rules.",
        epilog="Checks: " + ", ".join(CHECK_IDS),
    )
    parser.add_argument("--title", help="pull-request title")
    parser.add_argument("--body", help="pull-request body")
    parser.add_argument("--range", dest="revision_range", help="commit range as BASE..HEAD")
    parser.add_argument("--fixture", type=Path, help="read test inputs from a fixture directory")
    parser.add_argument(
        "--skip",
        choices=CHECK_IDS,
        action="append",
        default=[],
        metavar="CHECK-ID",
        help="disable a check; may be repeated",
    )
    args = parser.parse_args(argv)
    if args.fixture is None and (args.title is None or args.body is None or args.revision_range is None):
        parser.error("--title, --body, and --range are required without --fixture")
    if args.fixture is not None and any(
        value is not None for value in (args.title, args.body, args.revision_range)
    ):
        parser.error("--fixture cannot be combined with --title, --body, or --range")
    return args


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    try:
        inputs = load_fixture_inputs(args.fixture) if args.fixture else load_git_inputs(
            args.title, args.body, args.revision_range
        )
    except (OSError, RuntimeError, ValueError) as error:
        print(f"pr-lint: {error}", file=sys.stderr)
        return 2

    failed = False
    skipped = set(args.skip)
    for check_id, check in CHECKS:
        if check_id in skipped:
            continue
        for message in check(inputs):
            print(f"{check_id}: {message}")
            failed = failed or check_id != "workflow-change"
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
