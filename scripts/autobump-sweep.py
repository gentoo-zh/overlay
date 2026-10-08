#!/usr/bin/env python3

"""Bump the packages nvchecker reported, one issue at a time.

    autobump-sweep.py [issue#...] [--limit N] [--pr] [--comment]
    autobump-sweep.py [issue#...] [--limit N] --plan N [--bundles JSON --bundles-delta PATH] [--bundles-only]
    autobump-sweep.py --worker JSON --delta PATH [--limit N] [--pr] [--comment]
    autobump-sweep.py --collect JSON [delta...]
"""

import datetime
from dataclasses import dataclass
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
import tomllib


STATUS_MARKER = "<!-- autobump-status -->"
# One hidden marker keeps each issue editable instead of creating an unbounded status-comment stream.
SPACE = " \t\r\n\v\f"


@dataclass
class Arguments:
    pr: str
    comment: bool
    limit: str
    issues: list[str]
    retry: bool
    plan_shards: int | None
    worker: str | None
    delta: str | None
    collect: str | None
    delta_files: list[str]
    bundles: str | None
    bundles_delta: str | None
    bundles_only: bool


@dataclass
class Settings:
    repo: str
    upstream_repo: str
    assignee: str
    judge: str
    done_ledger: Path | None
    attempts_ledger: Path | None
    bundles_ledger: Path | None
    pr: str
    comment: bool
    limit: str
    issues: list[str]
    retry: bool
    engine: str | None
    bundle_controller: str | None
    plan_shards: int | None
    worker_items: list[dict] | None
    delta: Path | None
    collect_plan: dict | None
    delta_files: list[Path]
    ledger_additions: dict[str, list[str]]
    worker_attempts: dict[tuple[str, str], int]
    evidence_dir: Path | None
    bundles: Path | None
    bundles_delta: Path | None
    bundles_only: bool
    waits: list[dict]


# A build log carries whatever bytes upstream wrote; strict decoding loses the bump over one.
TEXT_OUTPUT = {"encoding": "utf-8", "errors": "replace"}


def command_output(command, *, stderr=None):
    """Run a command and return its status and command-substitution-style stdout."""
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=stderr, **TEXT_OUTPUT)
    except FileNotFoundError:
        return 127, ""
    return result.returncode, result.stdout.rstrip("\n")


def command_output_with_stderr(command):
    """Run a command and return its status and command-substitution-style combined output."""
    try:
        result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, **TEXT_OUTPUT)
    except FileNotFoundError:
        return 127, f"{command[0]}: command not found"
    return result.returncode, result.stdout.rstrip("\n")


def today():
    return datetime.date.today().isoformat()


# A new target version has a distinct ledger key, so terminal results never retry.
def ledger_line(package, version, result=None):
    fields = (package, version, result, today()) if result else (package, version, today(), attempt_token())
    return " ".join(fields)


def run_token():
    """What tells one attempt from another: two runs on one day, one delivered twice."""
    return os.environ.get("GITHUB_RUN_ID") or f"p{os.getpid()}"


def attempt_token():
    """A rerun keeps its run id; its attempt number tells its tries from the first run's."""
    attempt = os.environ.get("GITHUB_RUN_ATTEMPT")
    return f"{run_token()}.{attempt}" if attempt and attempt != "1" else run_token()


def record_ledger(settings, ledger_name, package, version, result=None):
    if settings.worker_items is not None:
        settings.ledger_additions[ledger_name].append(ledger_line(package, version, result))
        if ledger_name == "attempts":
            key = (package, version)
            settings.worker_attempts[key] = settings.worker_attempts.get(key, 0) + 1
        return

    path = settings.done_ledger if ledger_name == "done" else settings.attempts_ledger
    with path.open("a") as f:
        f.write(ledger_line(package, version, result) + "\n")


# The line format the bundle controller reads: one observation per run, whatever the bundle count.
# Only a worker defers on a bundle, and collect merges its lines.
def record_bundle_event(settings, package, version, kind):
    settings.ledger_additions["bundles"].append(f"{package} {version} {kind} {today()} {run_token()}")


def matching_ledger_line(path, package, version):
    needle = f"{package} {version} "
    with path.open() as f:
        for line in f:
            if needle in line:
                return line.rstrip("\n")
    return None


def matching_ledger_count(path, package, version):
    needle = f"{package} {version} "
    with path.open() as f:
        return sum(needle in line for line in f)


def attempt_count(settings, package, version):
    if settings.worker_items is not None:
        return settings.worker_attempts.get((package, version), 0)
    return matching_ledger_count(settings.attempts_ledger, package, version)


# A dangling value flag keeps its current value, matching the shell this replaced.
VALUE_FLAGS = {
    "--limit": "limit",
    "--plan": "plan_shards",
    "--worker": "worker",
    "--delta": "delta",
    "--collect": "collect",
    "--bundles": "bundles",
    "--bundles-delta": "bundles_delta",
}
NUMERIC_FLAGS = {"limit", "plan_shards"}


def parse_args(argv):
    parsed = {
        "pr": "",
        "comment": False,
        "limit": "0",
        "issues": [],
        "retry": False,
        "plan_shards": None,
        "worker": None,
        "delta": None,
        "collect": None,
        "delta_files": [],
        "bundles": None,
        "bundles_delta": None,
        "bundles_only": False,
    }
    remaining = list(argv)
    while remaining:
        arg = remaining.pop(0)
        if arg == "--pr":
            parsed["pr"] = "--pr"
        elif arg == "--comment":
            parsed["comment"] = True
        elif arg == "--retry":
            parsed["retry"] = True
        elif arg == "--bundles-only":
            parsed["bundles_only"] = True
        elif arg in VALUE_FLAGS:
            option = VALUE_FLAGS[arg]
            if remaining:
                value = remaining.pop(0)
                if option in NUMERIC_FLAGS:
                    value = validated_number(value)
                parsed[option] = int(value) if option == "plan_shards" else value
        elif parsed["collect"] is not None:
            parsed["delta_files"].append(arg)
        elif re.match(r"[0-9]", arg):
            parsed["issues"].append(validated_number(arg))
        else:
            print(f"unknown arg: {arg}", file=sys.stderr)
            raise SystemExit(2)
    return Arguments(**parsed)


def validated_number(arg):
    if not re.fullmatch(r"[0-9]+", arg):
        print(f"not a number: {arg}", file=sys.stderr)
        raise SystemExit(2)
    return arg


# Autobump is maintainer opt-in; its value carries the retention policy autobump-args.py turns into engine flags.
#
# A table header may carry a trailing comment; strip it before comparing or an opted-in
# package with an annotated header is silently skipped.
def autobump_enabled(path, package):
    # TOML quotes a key either way, and the file is read line by line rather than parsed
    wanted_headers = {f'["{package}"]', f"['{package}']"}
    in_package = False
    enabled = False

    try:
        with path.open() as f:
            for original in f:
                original = original.rstrip("\n")
                header = re.sub(r"[ \t\r\v\f]*#.*", "", original).rstrip(SPACE)
                if header in wanted_headers:
                    in_package = True
                    continue
                if original.startswith("["):
                    in_package = False
                if (in_package
                        and re.match(r"^[ \t\r\v\f]*autobump[ \t\r\v\f]*=", header)
                        and not re.search(r"=[ \t\r\v\f]*false", header)):
                    enabled = True
                    break
    except OSError as error:
        print(error, file=sys.stderr)

    return enabled


def package_and_version(title):
    packages = []
    versions = []
    for line in title.split("\n"):
        package = re.match(
            r"^\[nvchecker\] ([a-z0-9-]+/[A-Za-z0-9_.+-]+) can be bump to .*",
            line,
        )
        if package:
            packages.append(package.group(1))
        version = re.search(r".* can be bump to ([A-Za-z0-9._+-]+)$", line)
        if version:
            versions.append(version.group(1))
    return "\n".join(packages), "\n".join(versions)


def run_limit(settings):
    # 0 is no cap: with the queue sharded across workers there is usually no reason to
    # leave part of a day's issues for tomorrow.
    limit = int(settings.limit)
    return limit if limit > 0 else None


def run_link(upstream_repo, label="run"):
    run_id = os.environ.get("GITHUB_RUN_ID", "")
    if not run_id:
        return ""
    server = os.environ.get("GITHUB_SERVER_URL") or "https://github.com"
    repository = os.environ.get("GITHUB_REPOSITORY") or upstream_repo
    return f" · [{label}]({server}/{repository}/actions/runs/{run_id})"


# A comment takes 65536 characters; leave the verdict line and footer room around the evidence.
EVIDENCE_COMMENT_BUDGET = 55000
EVIDENCE_FILE_LINES = 200


def short_status_reason(reason):
    reason = re.sub(r"[ \t\r\n\v\f]+", " ", reason).strip(SPACE)
    if len(reason) > 200:
        return f"{reason[:199]}…"
    return reason


# Seconds between status-lookup retries; the tests drive the failure path and do not wait.
STATUS_LOOKUP_BACKOFF = float(os.environ.get("AUTOBUMP_STATUS_BACKOFF", "3"))


def find_status_comment_id(issue, upstream_repo):
    # A failed FIND must not fall through to CREATE: a transient API error would duplicate the status comment.
    status_comment_id_filter = (
        "map(select(.body|contains(\"<!-- autobump-status -->\")))|.[0].id // empty"
    )
    for _ in range(3):
        status, comment_id = command_output(
            [
                "gh",
                "api",
                f"repos/{upstream_repo}/issues/{issue}/comments",
                "--paginate",
                "--jq",
                status_comment_id_filter,
            ],
            stderr=subprocess.DEVNULL,
        )
        if status == 0:
            return comment_id
        time.sleep(STATUS_LOOKUP_BACKOFF)
    return None


def status_comment(issue, body, *, comment, footer, upstream_repo, status_comment_failed):
    if not comment:
        return

    if footer:
        body = f"{body}\n{footer}"
    body = f"{body}\n\n{STATUS_MARKER}"
    comment_id = find_status_comment_id(issue, upstream_repo)
    if comment_id is None:
        status_comment_failed.add(issue)
        return

    if comment_id:
        command = [
            "gh",
            "api",
            "-X",
            "PATCH",
            f"repos/{upstream_repo}/issues/comments/{comment_id}",
            "-f",
            f"body={body}",
        ]
    else:
        command = [
            "gh",
            "issue",
            "comment",
            issue,
            "--repo",
            upstream_repo,
            "--body",
            body,
        ]

    for _ in range(3):
        try:
            status = subprocess.run(
                command,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            ).returncode
        except FileNotFoundError:
            status = 127
        if status == 0:
            return
        time.sleep(3)
    # Keep a failed update visible in the final summary rather than claiming the issue has current status.
    status_comment_failed.add(issue)


def assign_issue(settings, issue, add):
    if not (settings.comment and settings.assignee):
        return
    flag = "--add-assignee" if add else "--remove-assignee"
    command = ["gh", "issue", "edit", issue, "--repo", settings.upstream_repo, flag, settings.assignee]
    for _ in range(3):
        status, _ = command_output(command, stderr=subprocess.DEVNULL)
        if status == 0:
            return
        time.sleep(3)
    print(f"warning: could not {'assign' if add else 'unassign'} {settings.assignee} on #{issue}", file=sys.stderr)


# GitHub refuses these in an artifact path, and portage names an elog
# "<cat>:<pn>-<ver>:<timestamp>.log".
UPLOADABLE_NAME = re.compile(r'["<>|*?:\r\n]')


def copy_named_for_upload(src, dst, **kwargs):
    dst = Path(dst)
    shutil.copy2(src, dst.with_name(UPLOADABLE_NAME.sub("-", dst.name)), **kwargs)


def keep_evidence(settings, evidence, package, version):
    # an engine that died early printed no evidence path, and Path("") is the checkout
    if str(evidence) in ("", "."):
        return
    # The engine's evidence dir is a tmpdir inside the worker: without a copy under
    # AUTOBUMP_EVIDENCE_DIR (uploaded as a run artifact) every log and diff behind an
    # escalation dies with the container.
    if not settings.evidence_dir or not evidence.is_dir():
        return
    kept = settings.evidence_dir / f"{package.replace('/', '_')}-{version}"
    shutil.rmtree(kept, ignore_errors=True)
    try:
        shutil.copytree(evidence, kept, copy_function=copy_named_for_upload)
    except OSError as error:
        print(f"could not keep evidence for {package}: {error}")


def engine_abort_reason(text):
    # The reason can sit anywhere: it arrives on stderr, which is merged into the buffered
    # stdout. Exactly two bangs - portage writes "!!!" into the same stream, and that is a log.
    lines = [line for line in text.split("\n") if line.strip()]
    aborts = [line for line in lines if re.match(r"[ \t]*!![^!]", line)]
    reason = aborts[-1] if aborts else (lines[-1] if lines else "")
    return re.sub(r"^[ \t\r\v\f]*!!?[ \t\r\v\f]*", "", reason)


# Parsed from the engine's own line, never hard-coded: its mkdtemp follows TMPDIR, which
# is /var/tmp on a Gentoo box.
def evidence_directory_from_output(text):
    evidence_directories = []
    for line in text.split("\n"):
        match = re.search(r".*evidence: ([^ ]+) ==.*", line)
        if match:
            evidence_directories.append(match.group(1))
    return evidence_directories[-1] if evidence_directories else ""


def current_version(text):
    for line in text.split("\n"):
        match = re.match(r"^>> current: ([^ ]+) +-> +target:.*", line)
        if match:
            return match.group(1)
    return ""


def evidence_reasons(evidence):
    try:
        with (evidence / "escalations.txt").open() as f:
            reasons = ";".join(line.rstrip("\n") for line in f)
    except OSError:
        reasons = ""
    return reasons.replace(";", "; ") or f"see evidence in {evidence}"


def human_verdict(evidence):
    reason = evidence_reasons(evidence)
    return {
        "verdict": "human",
        "reasons": [reason],
        "use_flags_needed": [],
        "deps_changed": [],
        "issue_comment": f"not mechanically safe: {reason}",
    }


def parse_verdict(verdict_json):
    try:
        return json.loads(verdict_json)
    except json.JSONDecodeError:
        return {}


def last_clear_reason(text):
    clear_reasons = []
    for line in text.split("\n"):
        # a reason can carry its own parentheses; the engine ends it with "); evidence: <dir>"
        match = re.search(r"not mechanically safe \((.+)\); evidence: ", line)
        if match:
            clear_reasons.append(match.group(1))
    return clear_reasons[-1] if clear_reasons else ""


# wget writes one of these per 50K downloaded; a fetch log is mostly them.
PROGRESS_LINE = re.compile(r"^[ \t]*[0-9]+K[ .]+[0-9]+%")


def evidence_file_excerpt(path):
    try:
        text = path.read_text(errors="replace")
    except OSError:
        return "", 0, 0
    lines = [
        line.replace("```", "")
        for line in text.split("\n")
        if not re.fullmatch(r"[ \t\r\v\f]*", line) and not PROGRESS_LINE.match(line)
    ]
    if len(lines) <= EVIDENCE_FILE_LINES:
        return "\n".join(lines), len(lines), len(lines)
    # a log carries its failure at the end, a listing at the start
    kept = lines[-EVIDENCE_FILE_LINES:] if path.suffix == ".log" else lines[:EVIDENCE_FILE_LINES]
    return "\n".join(kept), len(kept), len(lines)


def evidence_excerpt(evidence):
    # Every file the engine wrote, not a summary of them: the reason line says what tripped,
    # these say what the tools actually printed. Long files are cut, never paraphrased, and
    # the run artifact holds them whole.
    try:
        paths = sorted(path for path in evidence.iterdir() if path.is_file())
    except OSError:
        return ""
    # the reason first, then the diffs and scan results, then the logs: a log is the bulkiest
    # file and the one the evidence artifact holds anyway, so it must not crowd out the rest
    paths.sort(key=lambda path: (path.suffix == ".log", path.name != "escalations.txt"))

    sections, budget = [], EVIDENCE_COMMENT_BUDGET
    for index, path in enumerate(paths):
        excerpt, kept, total = evidence_file_excerpt(path)
        if not excerpt:
            continue
        title = path.name if kept == total else f"{path.name} ({kept} of {total} lines)"
        section = f"<details><summary>{title}</summary>\n\n```\n{excerpt}\n```\n</details>"
        if len(section) > budget:
            left = len(paths) - index
            sections.append(f"({left} more files in the run's evidence artifact)")
            break
        sections.append(section)
        budget -= len(section)
    return "\n\n".join(sections)


def read_settings(argv):
    arguments = parse_args(argv[1:])
    repo = os.environ.get("AUTOBUMP_REPO")
    if not repo:
        _, repo = command_output(["git", "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL)
    upstream_repo = os.environ.get("AUTOBUMP_UPSTREAM_REPO") or "gentoo-zh/overlay"
    # the account that opens the nvchecker issues; an empty value assigns nobody
    assignee = os.environ.get("AUTOBUMP_ASSIGNEE", "gentoo-zh-bot")
    # An unset judge sends each escalation to a human; configure one only when its semantic judgment merits a call.
    judge = os.environ.get("AUTOBUMP_JUDGE", "")
    # where escalation evidence is kept for upload; unset means the run keeps none
    evidence_dir = os.environ.get("AUTOBUMP_EVIDENCE_DIR")
    state_home = os.environ.get("XDG_STATE_HOME") or f"{os.environ.get('HOME', '')}/.local/state"
    state_dir = Path(state_home) / "autobump"
    done_ledger = state_dir / "done.list"
    # ATTEMPTS records only retryable outcomes, so its cap reaches a human without making transient failures terminal.
    attempts_ledger = state_dir / "attempts"
    # bundle observations and dispatches, written by the bundle controller and by bundle defers here
    bundles_ledger = state_dir / "bundles"
    if arguments.worker is None:
        state_dir.mkdir(parents=True, exist_ok=True)
        done_ledger.touch(exist_ok=True)
        attempts_ledger.touch(exist_ok=True)
        bundles_ledger.touch(exist_ok=True)
    if (arguments.bundles is None) != (arguments.bundles_delta is None):
        print("--bundles and --bundles-delta go together", file=sys.stderr)
        raise SystemExit(2)
    bundle_controller = os.environ.get("AUTOBUMP_BUNDLE_CONTROLLER")
    if arguments.bundles is not None and not bundle_controller:
        print("--bundles: set AUTOBUMP_BUNDLE_CONTROLLER, e.g. autobump-rb/bin/bundles.py", file=sys.stderr)
        raise SystemExit(2)

    try:
        os.chdir(repo)
    except OSError:
        return None

    worker = json.loads(arguments.worker) if arguments.worker is not None else None
    worker_items = worker["items"] if worker is not None else None
    worker_attempts = {
        (item["package"], item["version"]): item["attempts"] for item in worker_items or []
    }
    return Settings(
        repo=repo,
        upstream_repo=upstream_repo,
        assignee=assignee,
        judge=judge,
        done_ledger=done_ledger if arguments.worker is None else None,
        attempts_ledger=attempts_ledger if arguments.worker is None else None,
        bundles_ledger=bundles_ledger if arguments.worker is None else None,
        pr=arguments.pr,
        comment=arguments.comment,
        limit=arguments.limit,
        issues=arguments.issues,
        retry=arguments.retry,
        engine=os.environ.get("AUTOBUMP_ENGINE"),
        bundle_controller=bundle_controller,
        plan_shards=arguments.plan_shards,
        worker_items=worker_items,
        delta=Path(arguments.delta) if arguments.delta is not None else None,
        collect_plan=json.loads(arguments.collect) if arguments.collect is not None else None,
        delta_files=[Path(path) for path in arguments.delta_files],
        ledger_additions={"done": [], "attempts": [], "bundles": []},
        worker_attempts=worker_attempts,
        evidence_dir=Path(evidence_dir) if evidence_dir else None,
        bundles=Path(arguments.bundles) if arguments.bundles is not None else None,
        bundles_delta=Path(arguments.bundles_delta) if arguments.bundles_delta is not None else None,
        bundles_only=arguments.bundles_only,
        waits=[],
    )


def select_issues(settings):
    # LIMIT caps engine attempts, not fetched issues, so free skips below busy work do not starve opted-in packages.
    if settings.issues:
        return settings.issues, False

    # Keep a failed gh request distinct from an empty list so auth, rate-limit, and network failures do not skip a sweep.
    status, issue_numbers = command_output(
        [
            "gh",
            "issue",
            "list",
            "--repo",
            settings.upstream_repo,
            "--search",
            "[nvchecker] in:title",
            "--state",
            "open",
            "--limit",
            str((run_limit(settings) or 20) * 10),
            "--json",
            "number",
            "--jq",
            ".[].number",
        ]
    )
    if status != 0:
        print("gh issue list failed (auth/rate-limit/network?)", file=sys.stderr)
        return None, True
    return issue_numbers.split("\n") if issue_numbers else [], True


# The engine switches branches mid-sweep, so a helper that lives only on the starting
# branch would vanish under it.
def copy_tools():
    _, original_branch = command_output(["git", "branch", "--show-current"])
    tools = Path(tempfile.mkdtemp(prefix="autobump-tools-", dir="/tmp"))
    shutil.copy2("scripts/autobump-judge.sh", tools / "autobump-judge.sh")
    shutil.copy2("scripts/autobump-args.py", tools / "autobump-args.py")
    return tools, original_branch


def engine_command(settings):
    # autobump-rb is the single engine. There is no in-tree fallback to silently use.
    if not settings.engine:
        print("AUTOBUMP_ENGINE: set AUTOBUMP_ENGINE, e.g. ruby autobump-rb/bin/autobump", file=sys.stderr)
        return None
    return shlex.split(settings.engine)


OVERLAY_TOML = Path(".github/workflows/overlay.toml")
NOT_OPTED_IN = "skip (not opted in: no autobump key)"


def issue_title_target(settings, issue):
    status, title = command_output(
        ["gh", "issue", "view", issue, "--repo", settings.upstream_repo, "--json", "title", "--jq", ".title"],
        stderr=subprocess.DEVNULL,
    )
    # a failed call reads as an empty title, which is not a verdict about the issue
    if status != 0:
        return None, None, "gh issue view failed (auth/rate-limit/network?)"
    package, version = package_and_version(title)
    if not package or not version:
        return None, None, "unparseable title"
    return package, version, None


def issue_bump_target(settings, issue):
    package, version, result = issue_title_target(settings, issue)
    if result:
        return None, None, result
    if not autobump_enabled(OVERLAY_TOML, package):
        return None, None, NOT_OPTED_IN
    return package, version, None


def engine_arguments(tools, package):
    # stderr is the refusal reason; retain each newline-delimited regex as one engine argument.
    status, arguments = command_output_with_stderr(["python3", str(tools / "autobump-args.py"), package])
    if status != 0:
        return None, None, f"skip ({arguments.replace(chr(10), ' ')})"
    args = arguments.split("\n") if arguments else []
    _, footer = command_output(["python3", str(tools / "autobump-args.py"), "--describe", package])
    return args, f"— `autobump` enabled{footer}", None


# An engine fix does not reach a package the ledger already recorded, and DONE is keyed by
# version, so a deferred bump would wait for the next release. --retry runs the named issues
# again; it needs their numbers, so a re-run cannot sweep the whole queue by accident.
def ledger_skip(settings, package, version):
    if settings.retry and settings.issues:
        return None
    return matching_ledger_line(settings.done_ledger, package, version)


# A bundle that is not ready is waited on, not bumped: the bundle controller counts the waits.
BUNDLE_SCHEMA = 1


def bundle_packages():
    """Packages with a `deps` or `bundle` key; each needs a snapshot target before a shard may take it."""
    with OVERLAY_TOML.open("rb") as f:
        return {package for package, table in tomllib.load(f).items()
                if isinstance(table, dict) and ("deps" in table or "bundle" in table)}


def bundle_links(settings, package, bundles):
    """Where a human goes next: the bundle repo, its producer run, and the manual entry point.

    `bundles` are the snapshot's or the engine's; both give each bundle's repo and run_url."""
    links = []
    for bundle in bundles:
        repo = bundle.get("repo")
        if repo and repo != "-":
            links.append(f"[{repo}](https://github.com/{repo})")
        if bundle.get("run_url"):
            links.append(f"[producer run]({bundle['run_url']})")
    server = os.environ.get("GITHUB_SERVER_URL") or "https://github.com"
    links.append(f"[bundles.yml]({server}/{settings.upstream_repo}/actions/workflows/bundles.yml)"
                 f" with `packages={package}`")
    return " · ".join(dict.fromkeys(links))


def bundle_status_body(settings, package, version, reason, links, *, escalate, detail=""):
    if escalate:
        return (
            f"**autobump** can't get the vendor bundle for `{package}` → `{version}`{detail}: **{reason}**. "
            f"Needs a maintainer: {links}. Re-run autobump with `retry` for this issue once it is fixed."
            f"{run_link(settings.upstream_repo, 'log')}"
        )
    return (
        f"**autobump** is waiting for the vendor bundle of `{package}` → `{version}`{detail}: {reason}. "
        f"{links}. Will retry automatically.{run_link(settings.upstream_repo)}"
    )


def run_bundle_controller(settings, candidates):
    """The bundle controller's plan over every target with a bundle, opted in or not.

    Returns ({(package, version): target}, error). error names a controller that failed: with no
    snapshot every bundle target is held back; with one, a target it could not judge is not ready."""
    targets = [
        {"issue": c["issue"], "package": c["package"], "version": c["version"],
         "retry": settings.retry and bool(settings.issues)}
        for c in candidates
    ]
    with tempfile.NamedTemporaryFile("w", suffix=".json", prefix="autobump-targets-", delete=False) as f:
        json.dump(targets, f)
    # an earlier run's snapshot must not stand in for this one
    settings.bundles.unlink(missing_ok=True)
    status, output = command_output_with_stderr([
        sys.executable, settings.bundle_controller, "plan", "--targets", f.name,
        "--ledger", str(settings.bundles_ledger), "--out", str(settings.bundles),
        "--delta", str(settings.bundles_delta),
    ])
    os.unlink(f.name)
    # stdout carries the plan itself
    print(output, file=sys.stderr)
    if not settings.bundles_delta.exists():
        settings.bundles_delta.write_text(json.dumps({"done": [], "attempts": [], "bundles": [], "results": {},
                                                      "status_comment_failed": []}) + "\n")
    try:
        snapshot = json.loads(settings.bundles.read_text())
        if snapshot.get("schema") != BUNDLE_SCHEMA or not isinstance(snapshot.get("targets"), list):
            raise ValueError(f"not a schema {BUNDLE_SCHEMA} snapshot")
        # collect fails the run on it: an API failure that persists would otherwise stay unknown unseen
        error = f"bundles.py plan exited {status}; see the plan log" if status else None
        return {(t["package"], t["version"]): t for t in snapshot["targets"]}, error
    except (OSError, ValueError, AttributeError, KeyError, TypeError) as error:
        message = f"bundle controller failed: bundles.py plan exited {status}, {error}"
        print(f"::error title=bundles::{message}", file=sys.stderr)
        return {}, message


def announce_bundle(settings, target, status_comment_failed):
    """Comment on what changed this run: a dispatch, or the escalation to a maintainer."""
    if not target.get("escalated_now") and not target.get("dispatched"):
        return
    package = target["package"]
    body = bundle_status_body(settings, package, target["version"], short_status_reason(target["reason"]),
                              bundle_links(settings, package, target["bundles"]),
                              escalate=target.get("escalated_now"))
    status_comment(target["issue"], body, comment=settings.comment, footer="",
                   upstream_repo=settings.upstream_repo, status_comment_failed=status_comment_failed)


def plan_issues(settings, issues, apply_run_limit):
    results = {}
    candidates = []
    for issue in issues:
        package, version, result = issue_title_target(settings, issue)
        if result:
            results[issue] = result
            continue
        opted_in = autobump_enabled(OVERLAY_TOML, package)
        if not opted_in:
            results[issue] = NOT_OPTED_IN
        else:
            prior = ledger_skip(settings, package, version)
            if prior is not None:
                results[issue] = f"skip ({prior})"
                continue
        candidates.append({"issue": issue, "package": package, "version": version, "opted_in": opted_in})

    status_comment_failed = set()
    snapshot, with_bundles, bundle_error = {}, set(), None
    if settings.bundles is not None:
        with_bundles = bundle_packages()
        snapshot, bundle_error = run_bundle_controller(
            settings, [c for c in candidates if c["package"] in with_bundles or c["opted_in"]])
        for target in snapshot.values():
            if target.get("issue"):
                announce_bundle(settings, target, status_comment_failed)

    items = []
    planned = {}
    attempts = 0
    for candidate in candidates:
        issue, package, version = candidate["issue"], candidate["package"], candidate["version"]
        bundle = snapshot.get((package, version))
        if not candidate["opted_in"]:
            if bundle:
                results[issue] += f" · bundle {bundle['state']}"
            elif bundle_error and package in with_bundles:
                results[issue] += f" · {bundle_error}"
            continue
        # only a ready bundle reaches a shard: a fetch there would read a pending one as missing
        if package in with_bundles:
            if bundle is None:
                results[issue] = f"not attempted ({bundle_error or f'no bundle snapshot for {package} {version}'})"
                continue
            if bundle["state"] != "ready":
                reason = short_status_reason(bundle["reason"])
                results[issue] = f"not attempted (bundle {bundle['state']}): {reason}"
                continue

        args, footer, result = engine_arguments(Path("scripts"), package)
        if result:
            results[issue] = result
            continue

        # two issues can name one package - the same bump twice, or two versions of it - and
        # planning both runs two engines against one package dir, each pushing its own branch
        if package in planned:
            results[issue] = f"skip (#{planned[package]} already bumps {package} this run)"
            continue

        if settings.bundles_only:
            results[issue] = "skip (bundles_only run)"
            continue

        # GitHub matrices allow at most 256 jobs, including named issues.
        cap = run_limit(settings) if apply_run_limit else None
        cap = min(cap or 256, 256)
        if attempts >= cap:
            results[issue] = f"skip (per-run attempt limit {cap} reached)"
            continue

        planned[package] = issue
        attempts += 1
        item = {
            "issue": issue,
            "package": package,
            "version": version,
            "args": args,
            "footer": footer,
            "attempt": attempts,
            "attempts": matching_ledger_count(settings.attempts_ledger, package, version),
        }
        if bundle:
            item["bundle_observations"] = bundle["observations"]
            item["bundle_observation_limit"] = bundle["observation_limit"]
        items.append(item)

    shards = [[] for _ in range(min(settings.plan_shards, len(items)))]
    for index, item in enumerate(items):
        shards[index % len(shards)].append(item)
    return {
        # GitHub titles a matrix job with its own values, so the matrix carries only what
        # reads well as a title. The work itself sits in shards, which the worker indexes.
        "matrix": {
            "include": [
                {"shard": index, "packages": " ".join(item["package"] for item in shard)}
                for index, shard in enumerate(shards)
            ]
        },
        "shards": [{"items": shard} for shard in shards],
        "issues": issues,
        "results": results,
        "status_comment_failed": sorted(status_comment_failed),
        # collect fails the run on it, after the shards of every other package have run
        "bundle_error": bundle_error,
        "bundles_delta": settings.bundles_delta.name if settings.bundles_delta else None,
    }


def run_engine(engine, issue, args, pr):
    # Successful runs need only a tail; failures print all evidence because the CI container disappears after the run.
    status, engine_output = command_output_with_stderr(engine + [issue, *args] + ([pr] if pr else []))
    if status == 0:
        print(engine_output)
    else:
        print(engine_output)
    return status, engine_output


def record_bumped(settings, issue, package, version, engine_output, footer, status_comment_failed):
    record_ledger(settings, "done", package, version, "bumped")
    result = f"bumped{' + PR' if settings.pr else ''}"
    urls = re.findall(r"https://github\.com/[^ \n]+/pull/[0-9]+", engine_output)
    opened_pr = f" — opened {urls[-1]}" if urls else ""
    status_comment(
        issue,
        f"**autobump** bumped `{package}` → `{version}`{opened_pr}{run_link(settings.upstream_repo)}",
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    return result


def defer_unparseable_evidence(settings, package, version):
    # Output-format drift is a capped transient so it cannot permanently defer every escalation with an empty reason.
    tries = attempt_count(settings, package, version)
    record_ledger(settings, "attempts", package, version)
    if tries >= 2:
        record_ledger(settings, "done", package, version, "deferred")
        return f"deferred (exit 3, evidence dir unparseable after {tries + 1} tries)"
    return f"exit 3 but evidence dir not found (try {tries + 1}), retrying"


def escalation_verdict(settings, tools, evidence, package, current, version):
    if settings.judge:
        _, verdict_json = command_output(
            ["bash", str(tools / "autobump-judge.sh"), str(evidence), package, current or "?", version]
        )
        print(f"judge: {verdict_json}")
        return parse_verdict(verdict_json)

    return human_verdict(evidence)


def retry_accepted_escalation(
    settings, engine, issue, package, version, args, footer, status_comment_failed
):
    retry_status, retry_output = command_output_with_stderr(
        engine + [issue, "--accept-surface", "--accept-payload", *args] + ([settings.pr] if settings.pr else [])
    )
    print(retry_output)
    if retry_status == 0:
        record_ledger(settings, "done", package, version, "bumped-after-judge")
        return "bumped (judge accepted surface delta)"
    if retry_status != 2:
        record_ledger(settings, "done", package, version, "deferred")
        return f"deferred (retry failed, exit {retry_status})"

    # Share ATTEMPTS with judge retries so an escalation → judge → timeout loop ends without judging every sweep.
    tries = attempt_count(settings, package, version)
    record_ledger(settings, "attempts", package, version)
    if tries < 2:
        return f"judge-retry deferred transiently (try {tries + 1})"

    record_ledger(settings, "done", package, version, "deferred-transient")
    keep_evidence(settings, Path(evidence_directory_from_output(retry_output)), package, version)
    status_comment(
        issue,
        (
            f"**autobump** accepted the surface delta for `{package}` → `{version}` "
            f"but the retry hit transient failures {tries + 1} times. "
            f"A maintainer may need to bump it by hand.{run_link(settings.upstream_repo)}"
        ),
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    return f"deferred after {tries + 1} judge-retry transients"


def record_escalation(settings, issue, package, version, evidence, verdict, engine_output, footer, status_comment_failed):
    record_ledger(settings, "done", package, version, "deferred")
    reason = last_clear_reason(engine_output)
    if reason in ("", f"see evidence in {evidence}"):
        reasons = verdict.get("reasons", [])
        reason = "; ".join(reasons) if isinstance(reasons, list) else ""
    if reason in ("", f"see evidence in {evidence}"):
        reason = "needs a manual bump"

    body = (
        f"**autobump** can't bump `{package}` → `{version}` mechanically: "
        f"**{short_status_reason(reason)}**. Needs a manual bump.{run_link(settings.upstream_repo, 'log')}"
    )
    bundle = engine_bundle_result(engine_output)
    if bundle:
        body += f"\n\nBundle: {bundle_links(settings, package, bundle.get('bundles') or [])}"
    excerpt = evidence_excerpt(evidence)
    if excerpt:
        body += f"\n\n{excerpt}"
    status_comment(
        issue,
        body,
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    return f"escalated: {reason}"


def handle_escalation(
    settings, tools, engine, issue, package, version, args, footer, engine_output, status_comment_failed
):
    evidence_path = evidence_directory_from_output(engine_output)
    evidence = Path(evidence_path)
    if not evidence_path or not evidence.is_dir():
        return defer_unparseable_evidence(settings, package, version)

    keep_evidence(settings, evidence, package, version)
    verdict = escalation_verdict(
        settings, tools, evidence, package, current_version(engine_output), version
    )
    if verdict.get("verdict") == "proceed":
        return retry_accepted_escalation(
            settings, engine, issue, package, version, args, footer, status_comment_failed
        )
    return record_escalation(
        settings, issue, package, version, evidence, verdict, engine_output, footer, status_comment_failed
    )


def record_precondition(settings, issue, package, version, footer, status_comment_failed):
    # Already-at-target, existing-ebuild, and downgrade guards are permanent preconditions, not retryable build failures.
    record_ledger(settings, "done", package, version, "done-precondition")
    # Replace "bumping" for stale nvchecker issues so their status does not look stuck.
    status_comment(
        issue,
        f"**autobump**: `{package}` is already at (or ahead of) `{version}` in the overlay — nothing to bump.{run_link(settings.upstream_repo)}",
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    return f"done (precondition: overlay already at/ahead of {version})"


def engine_bundle_result(text):
    """The engine's `result:` line for a 404 judged from the bundle snapshot, or None."""
    for line in reversed(text.split("\n")):
        if line.startswith("result: "):
            try:
                result = json.loads(line[len("result: "):])
            except json.JSONDecodeError:
                return None
            return result if isinstance(result, dict) and result.get("bundle") is True else None
    return None


def defer_bundle(settings, issue, package, version, result, footer, observed, limit, status_comment_failed):
    # the bundle policy, not ATTEMPTS: a producer still at work is not a transient failure
    count = observed + 1
    record_bundle_event(settings, package, version, "observe")
    reason = short_status_reason(result.get("reason") or "bundle pending")
    escalate = count >= limit
    if escalate:
        record_bundle_event(settings, package, version, "escalate")
    detail = f" after {count} checks" if escalate else f" (check {count} of {limit})"
    links = bundle_links(settings, package, result.get("bundles") or [])
    status_comment(
        issue,
        bundle_status_body(settings, package, version, reason, links, escalate=escalate, detail=detail),
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    if escalate:
        return f"escalated: bundle not ready after {count} observations: {reason}"
    return f"not attempted (bundle pending, observation {count}/{limit}): {reason}"


def defer_transient(settings, issue, package, version, engine_output, footer, status_comment_failed):
    # Dirty trees, fetch flakes, timeouts, and dependency gaps retry until ATTEMPTS hands persistent failures to a maintainer.
    tries = attempt_count(settings, package, version)
    record_ledger(settings, "attempts", package, version)
    reason = engine_abort_reason(engine_output)
    if tries < 2:
        missing = re.match(r"per-version deps artifact missing \(HTTP 404\): (\S+)", reason)
        if missing:
            settings.waits.append({"issue": issue, "package": package, "version": version, "url": missing.group(1)})
        status_comment(
            issue,
            (
                f"**autobump** deferred `{package}` → `{version}` (transient: {short_status_reason(reason)}). "
                f"Will retry automatically.{run_link(settings.upstream_repo)}"
            ),
            comment=settings.comment,
            footer=footer,
            upstream_repo=settings.upstream_repo,
            status_comment_failed=status_comment_failed,
        )
        return f"not attempted (transient, try {tries + 1}): {reason}"

    record_ledger(settings, "done", package, version, "deferred-transient")
    # the run that hands the package to a maintainer is the one whose logs they need
    keep_evidence(settings, Path(evidence_directory_from_output(engine_output)), package, version)
    status_comment(
        issue,
        (
            f"**autobump** gave up on `{package}` → `{version}` after {tries + 1} tries: "
            f"{short_status_reason(reason)}. A maintainer may need to bump it by hand.{run_link(settings.upstream_repo, 'log')}"
        ),
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    return f"deferred after {tries + 1} transient attempts: {reason}"


def run_package(settings, tools, engine, issue, package, version, args, footer, attempt, status_comment_failed,
                bundle_observations=None, bundle_observation_limit=None):
    cap = run_limit(settings)
    counter = f"{attempt}/{cap}" if cap else str(attempt)
    print(f"==== #{issue} {package} -> {version} ({counter}) ====")
    # Assigned while the bump runs and kept only when a PR was opened, so the issue list shows who is on it.
    assign_issue(settings, issue, True)
    result = None
    try:
        result = bump_package(
            settings, tools, engine, issue, package, version, args, footer, status_comment_failed,
            bundle_observations, bundle_observation_limit,
        )
        return result
    finally:
        if not (settings.pr and result and result.startswith("bumped")):
            assign_issue(settings, issue, False)


def bump_package(settings, tools, engine, issue, package, version, args, footer, status_comment_failed,
                 bundle_observations, bundle_observation_limit):
    status_comment(
        issue,
        f"**autobump** is bumping `{package}` → `{version}`…{run_link(settings.upstream_repo)}",
        comment=settings.comment,
        footer=footer,
        upstream_repo=settings.upstream_repo,
        status_comment_failed=status_comment_failed,
    )
    status, engine_output = run_engine(engine, issue, args, settings.pr)
    if status == 0:
        return record_bumped(settings, issue, package, version, engine_output, footer, status_comment_failed)
    if status == 3:
        return handle_escalation(
            settings, tools, engine, issue, package, version, args, footer, engine_output, status_comment_failed
        )
    bundle = engine_bundle_result(engine_output) if bundle_observations is not None else None
    if bundle and bundle.get("exit") == 2:
        return defer_bundle(
            settings, issue, package, version, bundle, footer, bundle_observations, bundle_observation_limit,
            status_comment_failed,
        )
    # the abort reason only: a build log line ("destination path ... already exists") would
    # otherwise record a transient failure as a permanent precondition
    if re.search(r"already at|already exists|would downgrade|newer than target", engine_abort_reason(engine_output)):
        return record_precondition(settings, issue, package, version, footer, status_comment_failed)
    return defer_transient(settings, issue, package, version, engine_output, footer, status_comment_failed)


def run_issues(settings, issues, apply_run_limit, tools, engine):
    results = {}
    status_comment_failed = set()
    attempts = 0
    for issue in issues:
        cap = run_limit(settings)
        if apply_run_limit and cap is not None and attempts >= cap:
            results[issue] = f"skip (per-run attempt limit {cap} reached)"
            continue

        package, version, result = issue_bump_target(settings, issue)
        if result:
            results[issue] = result
            continue
        args, footer, result = engine_arguments(tools, package)
        if result:
            results[issue] = result
            continue
        prior = ledger_skip(settings, package, version)
        if prior is not None:
            results[issue] = f"skip ({prior})"
            continue

        attempts += 1
        try:
            results[issue] = run_package(
                settings, tools, engine, issue, package, version, args, footer, attempts, status_comment_failed
            )
        # the shell this replaced ran without `set -e`: one broken issue never took the rest
        # of the sweep, and the summary is the only record of a run
        except Exception as error:  # noqa: BLE001
            results[issue] = f"error ({type(error).__name__}: {error})"
    return results, status_comment_failed


def worker_engine_arguments(item):
    # the engine would run without the snapshot and read a pending bundle as a missing file
    if "bundle_observations" not in item:
        return item["args"]
    snapshot = os.environ.get("AUTOBUMP_BUNDLE_STATUS")
    if not snapshot or not Path(snapshot).is_file():
        raise RuntimeError(f"bundle snapshot missing (AUTOBUMP_BUNDLE_STATUS={snapshot!r})")
    return [*item["args"], "--bundle-status", str(Path(snapshot).resolve())]


def write_delta(settings, results, status_comment_failed):
    delta = {
        "done": settings.ledger_additions["done"],
        "attempts": settings.ledger_additions["attempts"],
        "bundles": settings.ledger_additions["bundles"],
        "results": results,
        "status_comment_failed": sorted(status_comment_failed),
        "waits": settings.waits,
    }
    settings.delta.parent.mkdir(parents=True, exist_ok=True)
    settings.delta.write_text(json.dumps(delta, separators=(",", ":")) + "\n")


def run_worker(settings):
    results = {}
    status_comment_failed = set()
    tools = None
    original_branch = ""
    try:
        tools, original_branch = copy_tools()
        engine = engine_command(settings)
        if engine is None:
            return 1
        for item in settings.worker_items:
            try:
                args = worker_engine_arguments(item)
                results[item["issue"]] = run_package(
                    settings,
                    tools,
                    engine,
                    item["issue"],
                    item["package"],
                    item["version"],
                    args,
                    item["footer"],
                    item["attempt"],
                    status_comment_failed,
                    bundle_observations=item.get("bundle_observations"),
                    bundle_observation_limit=item.get("bundle_observation_limit"),
                )
            except Exception as error:  # noqa: BLE001
                results[item["issue"]] = f"error ({type(error).__name__}: {error})"
    finally:
        restore_branch(original_branch)
        if tools is not None:
            shutil.rmtree(tools, ignore_errors=True)
        write_delta(settings, results, status_comment_failed)
    return 0


def merge_lines(path, lines):
    seen = set(path.read_text().splitlines())
    additions = []
    for line in lines:
        if line not in seen:
            additions.append(line)
            seen.add(line)
    if additions:
        with path.open("a") as f:
            f.write("\n".join(additions) + "\n")


def collect(settings):
    results = dict(settings.collect_plan["results"])
    status_comment_failed = set(settings.collect_plan.get("status_comment_failed", []))
    # the plan's lines first: a --retry reset there must not wipe a shard's observation of this run
    plan_delta = settings.collect_plan.get("bundles_delta")
    for path in sorted(settings.delta_files, key=lambda path: path.name != plan_delta):
        delta = json.loads(path.read_text())
        merge_lines(settings.done_ledger, delta["done"])
        # merged, like done: an attempt line carries the run it came from, so two attempts on one
        # day are two lines while the same delta delivered twice is still one
        merge_lines(settings.attempts_ledger, delta["attempts"])
        # the plan's own delta carries the bundle controller's lines, even when no shard ran
        merge_lines(settings.bundles_ledger, delta.get("bundles", []))
        results.update(delta["results"])
        status_comment_failed.update(delta["status_comment_failed"])
    print_summary(settings.collect_plan["issues"], results, status_comment_failed)
    return 0


def restore_branch(original_branch):
    if not original_branch:
        return
    try:
        subprocess.run(
            ["git", "checkout", "-q", original_branch],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except FileNotFoundError:
        pass


def print_summary(issues, results, status_comment_failed):
    # A failed status update must be visible in the run record as well as the issue log.
    print()
    print("==== sweep summary ====")
    for issue in issues:
        suffix = " (status comment not posted)" if issue in status_comment_failed else ""
        print(f"#{issue}  {results.get(issue, '?')}{suffix}")


def main(argv):
    settings = read_settings(argv)
    if settings is None:
        return 2
    if settings.collect_plan is not None:
        return collect(settings)
    if settings.worker_items is not None:
        return run_worker(settings)

    issues, apply_run_limit = select_issues(settings)
    if issues is None:
        return 2
    if settings.plan_shards is not None:
        print(json.dumps(plan_issues(settings, issues, apply_run_limit), separators=(",", ":")))
        return 0
    if not issues:
        print("no open nvchecker issues")
        return 0

    tools, original_branch = copy_tools()
    engine = engine_command(settings)
    if engine is None:
        return 1
    results, status_comment_failed = {}, set()
    try:
        results, status_comment_failed = run_issues(settings, issues, apply_run_limit, tools, engine)
    finally:
        # The summary is the only run record after the container exits, so print it from finally.
        restore_branch(original_branch)
        shutil.rmtree(tools, ignore_errors=True)
        print_summary(issues, results, status_comment_failed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
