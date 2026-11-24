#!/usr/bin/env bash
# usage: commit-rules.sh <pull request number>
# prints the commits of the pull request that break the commit rules in CONTRIBUTING.en.md
set -euo pipefail
# shellcheck disable=SC2016 # jq, not shell, expands these
gh api "repos/$GITHUB_REPOSITORY/pulls/${1:?pull request number}/commits?per_page=100" --paginate --jq '
  .[] | (.commit.message | split("\n")[0] | gsub("[[:cntrl:]]"; " ") | gsub("`"; "\u0027")) as $s
  | if (.parents | length) > 1 then ["It is a merge commit"]
    else [ if ($s | test("^(Revert \"|[^\\s:][^:]*: \\S)")) then empty else "The subject does not start with what it changes" end,
           if (.commit.message | test("(?m)^Signed-off-by: \\S")) then empty else "It has no `Signed-off-by:` line" end,
           if (.commit.message | test("(?im)^Co-authored-by:.*(anthropic\\.com|openai\\.com|cursor\\.com|copilot|\\[bot\\])")) then "It names an AI tool in a `Co-authored-by:` line; mark AI help with `Assisted-by:` instead" else empty end ]
    end as $why
  | select($why | length > 0)
  | "- `\(.sha[0:12])` `\($s)`\n" + ($why | map("  - " + .) | join("\n"))'
