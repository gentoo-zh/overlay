#!/usr/bin/env bash
# usage: pr-at-commit.sh <repository> <sha>
set -euo pipefail

repository=${1:?repository}
sha=${2:?sha}

# commits/{sha}/pulls returns nothing for a fork PR, and artifacts are not trusted to name it
pulls=$(gh api "repos/$repository/pulls?state=open&per_page=100" --paginate --slurp)
jq -r --arg sha "$sha" '
    first(.[][] | select(.head.sha == $sha) | .number) // empty
' <<< "$pulls"
