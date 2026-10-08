#!/usr/bin/env bash
# usage: autobump-trial.sh (targets from TARGETS)
set -uo pipefail

case "$TARGETS" in
    '') echo 'no targets given' >&2; exit 1 ;;
    *[!0-9\ ]*) echo "targets must be issue numbers: $TARGETS" >&2; exit 1 ;;
esac

git config --global --add safe.directory "$(realpath .)"
trial_ref=$(git rev-parse HEAD) || exit 1
TRIAL_MARKER='<!-- autobump-trial-status -->'
RUN_URL="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
comment_file=$(mktemp)
trap 'rm -f "$comment_file"' EXIT

trial_comment() {
    printf '%s\n\n%s\n' "$2" "$TRIAL_MARKER" > "$comment_file"
    if ! scripts/upsert-comment.sh "$AUTOBUMP_UPSTREAM_REPO" "$1" "$TRIAL_MARKER" "$comment_file"; then
        echo "::warning::cannot update trial comment on #$1" >&2
    fi
}

{
    echo '## autobump build-trial'
    echo
    echo '| issue | package | → version | exit | result |'
    echo '|------:|---------|-----------|:----:|--------|'
} >> "$GITHUB_STEP_SUMMARY"

read -r -a issue_numbers <<< "$TARGETS"
for n in "${issue_numbers[@]}"; do
    title=$(gh issue view "$n" --repo "$AUTOBUMP_UPSTREAM_REPO" --json title --jq .title || true)
    pkg=$(sed -nE 's/^\[nvchecker\] ([a-z0-9-]+\/[A-Za-z0-9_.+-]+) can be bump to .*/\1/p' <<< "$title")
    ver=$(sed -nE 's/.* can be bump to ([A-Za-z0-9._+-]+)$/\1/p' <<< "$title")
    if [ -z "$pkg" ] || [ -z "$ver" ]; then
        printf '| #%s | (unparseable title) |  | - | SKIP |\n' "$n" >> "$GITHUB_STEP_SUMMARY"
        continue
    fi
    echo "==== #$n  $pkg -> $ver ===="
    if scripts/needs-cpu-flags.sh "$pkg"; then
        echo "$pkg $(cpuid2cpuflags)" > /etc/portage/package.use/autobump-cpuflags
    else
        rm -f /etc/portage/package.use/autobump-cpuflags
    fi
    trial_comment "$n" "**autobump-trial** build-testing \`$pkg\` → \`$ver\` (not opted in)… · [run]($RUN_URL)"

    args=()
    if ! flags=$(python3 scripts/autobump-args.py "$pkg"); then
        printf "| #%s | \`%s\` | %s | - | SKIP — overlay.toml entry refused |\n" "$n" "$pkg" "$ver" >> "$GITHUB_STEP_SUMMARY"
        trial_comment "$n" "**autobump-trial** \`$pkg\` → \`$ver\`: **SKIP** — overlay.toml entry refused. · [log]($RUN_URL)"
        continue
    fi
    if [ -n "$flags" ]; then
        mapfile -t args <<< "$flags"
    fi
    bundle=''
    if ! has=$(python3 autobump-rb/bin/bundles.py has "$pkg"); then
        echo "::error title=bundles::cannot tell whether $pkg has a bundle; see the log"
        printf "| #%s | \`%s\` | %s | - | SKIP — bundle index unreadable |\n" "$n" "$pkg" "$ver" >> "$GITHUB_STEP_SUMMARY"
        continue
    fi
    if [ "$has" = yes ]; then
        snap="/tmp/autobump-bundles/$n.json"
        python3 autobump-rb/bin/bundles.py status "$pkg" --version "$ver" --out "$snap" || true
        if [ ! -s "$snap" ]; then
            printf "| #%s | \`%s\` | %s | - | SKIP — no bundle snapshot |\n" "$n" "$pkg" "$ver" >> "$GITHUB_STEP_SUMMARY"
            continue
        fi
        args+=(--bundle-status "$snap")
        bundle=" · bundle $(jq -r '.targets[0].state' "$snap")"
    fi
    ec=0
    ruby autobump-rb/bin/autobump "$n" --install "${args[@]}" || ec=$?
    case "$ec" in
        0)
            res='PASS — mechanical, built + installed + pkgcheck clean'
            tres='**PASS** — builds + installs + pkgcheck clean; safe to opt in.'
            ;;
        3)
            res='FAIL — escalate / build-fail (major jump, deps, patch, vendor, or emerge/QA/pkgcheck failure)'
            tres="**FAIL** — escalate / build failure; needs a manual bump. · [log]($RUN_URL)"
            ;;
        2)
            res='DEFER — transient (fetch / network / dep-gap / timeout / precondition)'
            tres='**DEFER** — transient (fetch / dep-gap / timeout).'
            ;;
        130)
            res='interrupted (signal)'
            tres="unexpected exit $ec. · [log]($RUN_URL)"
            ;;
        *)
            res="unexpected exit $ec"
            tres="unexpected exit $ec. · [log]($RUN_URL)"
            ;;
    esac
    printf "| #%s | \`%s\` | %s | %s | %s%s |\n" "$n" "$pkg" "$ver" "$ec" "$res" "$bundle" >> "$GITHUB_STEP_SUMMARY"
    # The engine switches branches; restore the dispatched scripts before the next helper.
    git checkout -q "$trial_ref" || exit 1
    trial_comment "$n" "**autobump-trial** \`$pkg\` → \`$ver\`: $tres$bundle"
done

{
    echo
    echo 'Exit codes: **0** mechanical-built · **2** defer · **3** escalate/build-fail — the engine contract is 0/2/3 only.'
} >> "$GITHUB_STEP_SUMMARY"
