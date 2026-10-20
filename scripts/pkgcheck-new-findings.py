#!/usr/bin/env python3
"""Mark which pkgcheck findings a pull request adds and print all of them as JSON.

Both reports are pkgcheck JsonStream output. A head finding is new unless the base
report has the same keyword and message for the same package. The version, line
numbers and the version inside the message are left out of the comparison, so a
finding that a bump carries over from the previous ebuild is not new.

Lists the findings on stderr for the job log, and exits 3 when a new finding has the
error level.

Usage: pkgcheck-new-findings.py BASE_REPORT HEAD_REPORT
"""

import json
import re
import sys

from pkgcheck.reporters import JsonStream

LEVELS = ("error", "warning", "style", "info")
LINE_NUMBERS = re.compile(r"\blines?:? \d+(?:, \d+)*")


def load(path):
    with open(path) as report:
        return list(JsonStream.from_iter(report))


def describe(result):
    """(package, target as pkgcheck names it, message with version and line numbers removed)."""
    category = getattr(result, "category", None)
    package = getattr(result, "package", None)
    version = getattr(result, "version", None)
    message = LINE_NUMBERS.sub("line", result.desc)
    target = "/".join(filter(None, (category, package)))
    if version:
        target += f"-{version}"
        for ver in {version, version.split("-r")[0]}:
            message = re.sub(rf"(?<![\d.]){re.escape(ver)}(?!\.?\d)", "VERSION", message)
    return (category, package), target, message


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    existing = set()
    for result in load(sys.argv[1]):
        package, _, message = describe(result)
        existing.add((package, result.name, message))

    findings = []
    for result in load(sys.argv[2]):
        package, target, message = describe(result)
        findings.append({
            "level": result.level,
            "keyword": result.name,
            "target": target,
            "desc": result.desc,
            "new": (package, result.name, message) not in existing,
        })
    findings.sort(key=lambda f: (LEVELS.index(f["level"]), f["target"], f["keyword"]))
    json.dump(findings, sys.stdout, indent=1)
    print()
    for f in findings:
        mark = "new" if f["new"] else "old"
        print(f"{mark} {f['level']}: {f['target']}: {f['keyword']}: {f['desc']}", file=sys.stderr)
    if any(f["new"] and f["level"] == "error" for f in findings):
        sys.exit(3)


if __name__ == "__main__":
    main()
