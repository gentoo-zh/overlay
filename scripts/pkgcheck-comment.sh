#!/usr/bin/env bash
# usage: pkgcheck-comment.sh <report-directory>
set -euo pipefail
MARKER='<!-- pkgcheck-report -->'
MAX_LINES=30
report_dir=${1:?report-directory}
findings=$report_dir/findings.json
body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

pr=$(scripts/pr-at-commit.sh "$GITHUB_REPOSITORY" "$HEAD_SHA")
if [ -z "$pr" ]; then
    echo 'no open pull request at this commit'
    exit 0
fi
echo "pull request #${pr}"

if [ ! -f "$findings" ]; then
    echo 'the report predates findings.json'
    exit 0
fi

# list <new> <level>...: one line per finding, existing ones prefixed with their level
list() {
    jq -r --argjson new "$1" '
        .[] | select(.new == $new and (.level | IN($ARGS.positional[])))
        | (if $new then "" else "\(.level): " end) + "\(.target): \(.keyword): \(.desc)"
    ' "$findings" --args "${@:2}"
}

# block <title> <collapsed> <lines>
block() {
    local title=$1 collapsed=$2 lines=$3 n
    n=$(grep -c . <<< "$lines" || true)
    [ "$n" -gt 0 ] || return 0
    echo
    if [ "$collapsed" = yes ]; then
        echo "<details><summary>${title} (${n})</summary>"
    else
        echo "### ${title} (${n})"
    fi
    echo
    echo '``````'
    head -n "$MAX_LINES" <<< "$lines"
    echo '``````'
    if [ "$n" -gt "$MAX_LINES" ]; then
        echo
        echo "$(( n - MAX_LINES )) more in the [run log](${RUN_URL})."
    fi
    if [ "$collapsed" = yes ]; then
        echo
        echo '</details>'
    fi
}

count=$(wc -l < "$report_dir"/packages)
if [ "$count" -eq 0 ]; then
    {
        echo '## Pull request pkgcheck report'
        echo
        echo "*Newest commit scanned*: \`$(cat "$report_dir"/commit)\`"
        echo '*Status*: :white_check_mark: no packages touched'
    } > "$body_file"
    scripts/upsert-comment-section.sh "$GITHUB_REPOSITORY" "$pr" "$MARKER" pkgcheck "$body_file"
    # emerge-on-pr skips a pull request that only touches .github, so drop its report here
    : > "$body_file"
    scripts/upsert-comment-section.sh "$GITHUB_REPOSITORY" "$pr" "$MARKER" elog "$body_file"
    echo 'no packages touched'
    exit 0
fi
errors=$(list true error)
warnings=$(list true warning)
minor=$(list true style info)

{
    echo '## Pull request pkgcheck report'
    echo
    echo "*Newest commit scanned*: \`$(cat "$report_dir"/commit)\`"
    if [ "${count}" -le 10 ]; then
        packages=()
        while IFS= read -r package; do
            packages+=("\`$package\`")
        done < "$report_dir/packages"
        echo "*Packages scanned*: ${packages[*]}"
    else
        echo "*Packages scanned*: ${count}"
    fi
    if [ -f "$report_dir"/incomplete ]; then
        echo "*Status*: :x: the scan did not finish, see the [run](${RUN_URL})"
    elif [ -z "$errors$warnings$minor" ]; then
        echo '*Status*: :white_check_mark: no new findings'
        block 'Existing findings in these packages' yes "$(list false error warning style info)"
    else
        if [ -n "$errors" ]; then
            echo '*Status*: :x: **new errors**'
        else
            echo '*Status*: :warning: **new issues**'
        fi
        echo
        echo "This pull request adds these findings. Errors fail the \`report\` check."
        block 'New errors' no "$errors"
        block 'New warnings' no "$warnings"
        block 'New style and info findings' yes "$minor"
        block 'Existing findings in these packages' yes "$(list false error warning style info)"
    fi
} > "$body_file"

scripts/upsert-comment-section.sh "$GITHUB_REPOSITORY" "$pr" "$MARKER" pkgcheck "$body_file"
echo "commented on #${pr}"
