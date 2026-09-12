#!/usr/bin/env bash

set -u

root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
status=0

for fixture in "$root/scripts/tests/pr-lint"/*; do
    [ -d "$fixture" ] || continue
    actual=$(mktemp)
    result=0
    python3 "$root/scripts/pr-lint.py" --fixture "$fixture" > "$actual" || result=$?

    if ! diff -u "$fixture/expected.txt" "$actual"; then
        status=1
    fi

    case "$(cat "$fixture/expected.txt")" in
        ""|"workflow-change: workflow files changed; needs a maintainer to review")
            expected_status=0
            ;;
        *)
            expected_status=1
            ;;
    esac
    if [ "$result" -ne "$expected_status" ]; then
        printf '%s: expected exit %s, got %s\n' "${fixture##*/}" "$expected_status" "$result" >&2
        status=1
    fi
    rm -f "$actual"
done

exit "$status"
