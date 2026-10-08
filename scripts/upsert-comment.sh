#!/usr/bin/env bash
# usage: upsert-comment.sh <repository> <issue> <marker> <body-file>
set -euo pipefail

repository=${1:?repository}
issue=${2:?issue}
marker=${3:?marker}
body_file=${4:?body-file}

comments=$(gh api "repos/$repository/issues/$issue/comments" --paginate --slurp)
comment_id=$(jq -r --arg marker "$marker" '
    [.[][] | select(.user.type == "Bot" and (.body | contains($marker)))][0].id // empty
' <<< "$comments")

if [ -n "$comment_id" ]; then
    gh api -X PATCH "repos/$repository/issues/comments/$comment_id" -F "body=@$body_file" >/dev/null
else
    gh api "repos/$repository/issues/$issue/comments" -F "body=@$body_file" >/dev/null
fi
