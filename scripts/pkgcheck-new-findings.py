#!/usr/bin/env python3
"""Print the pkgcheck findings a pull request adds, dropping the ones already there.

pkgcheck plain output puts a package on its own line and indents its findings under
it. Findings are compared without their line numbers, so one that merely moved to
another line does not count as new; a finding printed more often than in the base
report counts as new that many times.

Usage: pkgcheck-new-findings.py BASE_REPORT HEAD_REPORT
"""

from collections import Counter
import re
import sys

LINE_NUMBERS = re.compile(r"\blines?:? \d+(?:, \d+)*")


def parse(path):
    """(package, finding without line numbers, finding as pkgcheck printed it) for each finding."""
    findings = []
    package = None
    with open(path) as report:
        for line in report:
            line = line.rstrip("\n")
            if not line:
                continue
            if not line.startswith(" "):
                package = line
                continue
            findings.append((package, LINE_NUMBERS.sub("line", line.strip()), line))
    return findings


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    existing = Counter((package, finding) for package, finding, _ in parse(sys.argv[1]))
    added = []
    for package, finding, line in parse(sys.argv[2]):
        if existing[(package, finding)]:
            existing[(package, finding)] -= 1
        else:
            added.append((package, line))

    package = None
    for pkg, line in added:
        if pkg != package:
            if package is not None:
                print()
            print(pkg)
            package = pkg
        print(line)


if __name__ == "__main__":
    main()
