#!/usr/bin/env bash
# usage: upsert-comment-section.sh <repository> <issue> <marker> <section> <body-file>
# Several workflow runs share one bot comment, each owning one section of it.
# An empty body file removes the section.
set -euo pipefail
SECTIONS=(pkgcheck elog)
ATTEMPTS=4
PAUSE=10

repository=${1:?repository}
issue=${2:?issue}
marker=${3:?marker}
section=${4:?section}
body_file=${5:?body-file}
: "${HEAD_SHA:?}"
case $section in
    pkgcheck|elog) ;;
    *) echo "unknown section: $section" >&2; exit 1 ;;
esac

new_body=$(mktemp)
trap 'rm -f "$new_body"' EXIT

# Runs of the other section and of older pushes write the same comment at the
# same time, so write only while the pull request is at HEAD_SHA, then read it
# back after a pause and write again if another run overwrote this section.
for attempt in $(seq "$ATTEMPTS"); do
    head=$(gh api "repos/$repository/pulls/$issue" --jq .head.sha)
    if [ "$head" != "$HEAD_SHA" ]; then
        echo "the pull request moved on to ${head}"
        exit 0
    fi

    comments=$(gh api "repos/$repository/issues/$issue/comments" --paginate --slurp)
    # Section text comes from pull request runs; dropping "<!--" keeps it from forging a marker.
    plan=$(jq -c --arg marker "$marker" --arg section "$section" --rawfile text "$body_file" '
        def trim: gsub("\r"; "") | ltrimstr("\n") | rtrimstr("\n");
        def between($n):
            split("<!-- \($n):begin -->")
            | if length > 1 then .[1] | split("<!-- \($n):end -->")[0] | trim else null end;

        [.[][] | select(.user.type == "Bot" and (.body | contains($marker)))] as $found
        | ($found[0].body // "") as $old
        | ($text | gsub("<!--"; "") | trim | if . == "" then null else . end) as $want
        | [$ARGS.positional[] as $n
            | (if $n == $section then $want else $old | between($n) end)
            | select(. != null)
            | "<!-- \($n):begin -->\n\(.)\n<!-- \($n):end -->"
          ] as $sections
        | {
            id: $found[0].id,
            duplicates: [$found[1:][].id],
            done: (($old | between($section)) == $want),
            body: (($sections | join("\n\n")) + "\n\n" + $marker)
          }
    ' --args "${SECTIONS[@]}" <<< "$comments")

    # two runs that both found no comment each create one; keep the oldest
    for id in $(jq -r '.duplicates[]' <<< "$plan"); do
        gh api -X DELETE "repos/$repository/issues/comments/$id" >/dev/null
    done
    if [ "$(jq -r .done <<< "$plan")" = true ]; then
        echo "the ${section} section is up to date"
        exit 0
    fi
    if [ "$attempt" -eq "$ATTEMPTS" ]; then
        echo "the ${section} section kept being overwritten" >&2
        exit 1
    fi

    jq -r .body <<< "$plan" > "$new_body"
    comment_id=$(jq -r '.id // empty' <<< "$plan")
    if [ -n "$comment_id" ]; then
        gh api -X PATCH "repos/$repository/issues/comments/$comment_id" -F "body=@$new_body" >/dev/null
    else
        gh api "repos/$repository/issues/$issue/comments" -F "body=@$new_body" >/dev/null
    fi
    sleep "$PAUSE"
done
