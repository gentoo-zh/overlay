#!/usr/bin/env bash
# usage: pr-at-commit.sh <repository> <sha>
set -euo pipefail

repository=${1:?repository}
sha=${2:?sha}

# commits/{sha}/pulls returns nothing for a fork PR, and artifacts are not trusted to name it.
# A pull request merged before its comment run is closed by then, so the recently updated
# closed ones count too when they were merged.
{
    gh api "repos/$repository/pulls?state=open&per_page=100" --paginate
    gh api "repos/$repository/pulls?state=closed&sort=updated&direction=desc&per_page=30"
} | jq -rs --arg sha "$sha" '
    first(.[][] | select(.head.sha == $sha and (.state == "open" or .merged_at != null)) | .number) // empty
'
