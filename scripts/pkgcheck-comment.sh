#!/usr/bin/env bash
# usage: pkgcheck-comment.sh <report-directory>
set -euo pipefail
MARKER='<!-- pkgcheck-report -->'
report_dir=${1:?report-directory}
body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

# commits/{sha}/pulls returns nothing for a fork PR; the artifact is not trusted
pulls=$(gh api "repos/$REPO/pulls?state=open&per_page=100" --paginate --slurp)
matches=$(jq -r --arg head_sha "$HEAD_SHA" '
    .[][] | select(.head.sha == $head_sha) | .number
' <<< "$pulls")
pr=${matches%%$'\n'*}
if [ -z "$pr" ]; then
    echo 'no open pull request at this commit'
    exit 0
fi
echo "pull request #${pr}"

count=$(wc -l < "$report_dir"/packages)
if [ "$count" -eq 0 ]; then
    echo 'no packages touched'
    exit 0
fi
commit=$(cat "$report_dir"/commit)
# findings are indented under a package name, package names are not
new=$(grep -c '^  ' "$report_dir"/new.txt || true)
existing=$(( $(grep -c '^  ' "$report_dir"/report.txt || true) - new ))

issue_word=issues
if [ "$existing" -eq 1 ]; then
    issue_word=issue
fi

{
    echo '## Pull request pkgcheck report'
    echo
    echo "*Newest commit scanned*: \`${commit}\`"
    if [ "${count}" -le 10 ]; then
        packages=()
        while IFS= read -r package; do
            packages+=("\`$package\`")
        done < "$report_dir/packages"
        echo "*Packages scanned*: ${packages[*]}"
    else
        echo "*Packages scanned*: ${count}"
    fi
    if [ ! -f "$report_dir"/complete ]; then
        echo "*Status*: :x: the scan did not finish, see the [run](${RUN_URL})"
    elif [ "${new}" -eq 0 ]; then
        echo '*Status*: :white_check_mark: good'
    else
        echo '*Status*: :warning: **new issues**'
        echo
        if [ "${new}" -gt 10 ]; then
            echo "<details><summary>New issues caused by PR (${new})</summary>"
            echo
            close='</details>'
        else
            echo 'New issues caused by PR:'
            echo
            close=''
        fi
        echo '``````'
        if [ "$(wc -c < "$report_dir"/new.txt)" -le 55000 ]; then
            cat "$report_dir"/new.txt
        else
            head -c 55000 "$report_dir"/new.txt | head -n -1
            echo '[truncated, see the full report]'
        fi
        echo '``````'
        if [ -n "$close" ]; then
            echo
            echo "$close"
        fi
    fi
    if [ "${existing}" -gt 0 ]; then
        echo
        echo "There are ${existing} existing ${issue_word} in these packages. Please look"
        echo "into the [full report](${RUN_URL}) to make sure none of them affect your change."
    fi
    echo
    echo "${MARKER}"
} > "$body_file"

scripts/upsert-comment.sh "$REPO" "$pr" "$MARKER" "$body_file"
echo "commented on #${pr}"
