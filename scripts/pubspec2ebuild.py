#!/usr/bin/env python3
"""Generate the Dart-dependency section of a Gentoo ebuild from a Flutter app's
pubspec.lock -- the pub.dev equivalent of pycargoebuild.

Every "hosted" package becomes a pub.dev archive that portage can fetch and
verify; every "git" package becomes an upstream repository pinned to a commit.
flutter-app.eclass turns these into SRC_URI and lays the fetched archives out as
a pub-cache so `flutter pub get --offline` needs no bundled flutter-deps.

Usage:
    pubspec2ebuild.py path/to/pubspec.lock
"""

from __future__ import annotations

import argparse

import yaml


def load_packages(lockfile: str) -> dict:
    with open(lockfile) as f:
        return yaml.safe_load(f).get("packages", {})


def hosted_packages(packages: dict) -> list[tuple[str, str, str]]:
    """(name, version, sha256) for each package from a hosted registry (pub.dev)."""
    result = []
    for info in packages.values():
        if info.get("source") == "hosted":
            desc = info["description"]
            result.append((desc["name"], info["version"], desc["sha256"]))
    return sorted(result)


def git_packages(packages: dict) -> list[tuple[str, str, str, str]]:
    """(name, url, commit, subpath) for each package pinned to a git revision.

    subpath is the package's location within the repository (pub records it and
    the eclass reconstructs .git/pub-packages from it).
    """
    result = []
    for name, info in packages.items():
        if info.get("source") == "git":
            desc = info["description"]
            result.append(
                (name, desc["url"], desc["resolved-ref"], desc.get("path", "."))
            )
    return sorted(result)


def render(hosted: list, git: list) -> str:
    """Render bash arrays consumed by flutter-app.eclass."""
    blocks = []

    lines = ["PUB_HOSTED=("]
    for name, version, sha256 in hosted:
        lines.append(f'\t"{name} {version} {sha256}"')
    lines.append(")")
    blocks.append("\n".join(lines))

    if git:
        lines = ["PUB_GIT=("]
        for name, url, commit, subpath in git:
            lines.append(f'\t"{name} {url} {commit} {subpath}"')
        lines.append(")")
        blocks.append("\n".join(lines))

    return "\n\n".join(blocks)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pubspec_lock", help="path to the app's pubspec.lock")
    args = parser.parse_args()

    packages = load_packages(args.pubspec_lock)
    print(render(hosted_packages(packages), git_packages(packages)))


if __name__ == "__main__":
    main()
