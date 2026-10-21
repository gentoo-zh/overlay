#!/usr/bin/env bash
# usage: comment-status.sh <section> [<status>]
# Sets a section of the pkgcheck report comment to its heading and a status
# line, or removes the section when no status is given.
set -euo pipefail
MARKER='<!-- pkgcheck-report -->'
section=${1:?section}
status=${2:-}
body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

pr=$(scripts/pr-at-commit.sh "$GITHUB_REPOSITORY" "$HEAD_SHA")
if [ -z "$pr" ]; then
    echo 'no open pull request at this commit'
    exit 0
fi
echo "pull request #${pr}"

if [ -n "$status" ]; then
    case $section in
        pkgcheck) echo '## Pull request pkgcheck report' ;;
        elog) echo '## emerge elog' ;;
    esac > "$body_file"
    echo >> "$body_file"
    echo "*Status*: ${status}" >> "$body_file"
fi

scripts/upsert-comment-section.sh "$GITHUB_REPOSITORY" "$pr" "$MARKER" "$section" "$body_file"
