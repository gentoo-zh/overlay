#!/usr/bin/env python3
"""Restore the old version where nvchecker returned one Portage cannot parse.

nvcmp --sort portage raises TypeError on such a version and fails the whole job.

Usage: nvchecker-check.py OVERLAY_TOML OLD_VER NEW_VER
"""
import json
import os
import subprocess
import sys
import tomllib

from portage.versions import ververify

repo = os.environ["GITHUB_REPOSITORY"]


def gh(*args):
    return subprocess.run(["gh", *args, "--repo", repo], stdout=subprocess.PIPE, text=True).stdout


def report(pkg, ver, maintainers):
    title = f"nvchecker: {pkg}: {ver} is not a valid Portage version"
    print(f"::warning::{title}")
    open_issues = gh("issue", "list", "--search", f'"{title}" in:title',
                     "--json", "title", "--jq", ".[].title")
    if title in open_issues.splitlines():
        return

    if isinstance(maintainers, str):
        maintainers = [maintainers]
    cc = ["zakkaus", "liangyongxiang"]
    cc += [m for m in maintainers if m.lower() not in cc]
    body = (
        f"nvchecker returned `{ver}`, which Portage cannot parse, so this run skipped `{pkg}`.\n"
        f"Please fix its entry in `.github/workflows/overlay.toml`.\n\n"
        f"CC: {' '.join('@' + m for m in cc)}"
    )
    gh("issue", "create", "--title", title, "--body", body)


toml_path, old_path, new_path = sys.argv[1:]
with open(toml_path, "rb") as f:
    config = tomllib.load(f)
with open(old_path) as f:
    old = json.load(f)
with open(new_path) as f:
    new = json.load(f)

for pkg in sorted(old):
    if pkg in config and pkg not in new["data"]:
        print(f"::warning::nvchecker: {pkg}: no version from upstream")

for pkg, entry in new["data"].items():
    ver = entry["version"]
    if pkg in old and ver != old[pkg] and not ververify(ver):
        entry["version"] = old[pkg]
        report(pkg, ver, config[pkg].get("github_account", []))

with open(new_path, "w") as f:
    json.dump(new, f, indent=2)
