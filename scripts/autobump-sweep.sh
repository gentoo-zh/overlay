#!/usr/bin/env bash
# autobump-sweep.sh - the whole loop, end to end:
#   nvchecker issues -> autobump.sh -> (exit 3) judge -> retry / defer
#
# usage: autobump-sweep.sh [issue#...] [--limit N] [--pr] [--comment]
#   no issue numbers   process all open "[nvchecker]" issues (up to --limit, default 5)
#   --pr               let autobump.sh push + open PRs (default: local branch only)
#   --comment          post the judge's comment on deferred issues (default: print only)
#
# State: ~/.local/state/autobump/done.list - one "cat/pkg ver result date" per
# attempt. Terminal results (bumped/deferred) are never retried for the same
# version; a new upstream version gets a fresh attempt.

set -uo pipefail
REPO=${AUTOBUMP_REPO:-$(git rev-parse --show-toplevel 2>/dev/null)}
UPSTREAM_REPO=${AUTOBUMP_UPSTREAM_REPO:-gentoo-zh/overlay}
# AUTOBUMP_JUDGE: empty (default) = no model at all, every escalation goes to
# a human with the evidence. Set to "claude" to judge with a cheap model.
JUDGE=${AUTOBUMP_JUDGE:-}
STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/autobump
DONE="$STATE_DIR/done.list"
ATTEMPTS="$STATE_DIR/attempts"   # one line per transient (exit-2) attempt, to cap retries
mkdir -p "$STATE_DIR"; touch "$DONE" "$ATTEMPTS"
cd "$REPO" || exit 2

PR=""; COMMENT=0; LIMIT=5; ISSUES=()
prev=""
for a in "$@"; do
    case "$a" in
        --pr) PR="--pr"; prev="" ;;
        --comment) COMMENT=1; prev="" ;;
        --limit) prev=limit ;;
        [0-9]*)
            [[ $a =~ ^[0-9]+$ ]] || { echo "not a number: $a" >&2; exit 2; }
            if [ "$prev" = limit ]; then LIMIT=$a; prev=""; else ISSUES+=("$a"); fi ;;
        *) echo "unknown arg: $a" >&2; exit 2 ;;
    esac
done

# LIMIT caps ENGINE ATTEMPTS per run, not fetches: fetch a larger candidate window so
# opted-in packages below the top of a busy queue are not starved by cheap skips
# (not-opted-in / already-done). Explicit issue numbers are all honoured (no cap).
fetched=0
if [ ${#ISSUES[@]} -eq 0 ]; then
    fetched=1
    # capture gh separately so a failure (auth/rate-limit/network) surfaces as exit 2, not
    # swallowed by process-substitution into an empty list that looks identical to "no issues".
    if ! raw=$(gh issue list --repo "$UPSTREAM_REPO" --search '[nvchecker] in:title' \
        --state open --limit "$((LIMIT * 10))" --json number --jq '.[].number'); then
        echo "gh issue list failed (auth/rate-limit/network?)" >&2; exit 2
    fi
    mapfile -t ISSUES < <(printf '%s' "$raw")
fi
[ ${#ISSUES[@]} -gt 0 ] || { echo "no open nvchecker issues"; exit 0; }

ORIG_BRANCH=$(git branch --show-current)
declare -A RESULT

# run the judge from a copy: the engine switches branches, and if the script only
# exists on the current branch it would vanish mid-sweep
TOOLS=$(mktemp -d /tmp/autobump-tools-XXXX)
cp scripts/autobump-judge.sh "$TOOLS/"
# AUTOBUMP_ENGINE points at the engine (e.g. "ruby .../autobump-rb/bin/autobump"). Required:
# autobump-rb is the single engine, there is no in-tree fallback to default to.
ENGINE=${AUTOBUMP_ENGINE:?set AUTOBUMP_ENGINE, e.g. ruby autobump-rb/bin/autobump}

# ONE editable status comment per issue (upserted by a hidden marker -- never a stream of new
# comments), so a maintainer sees "autobumping / opened PR / needs a manual bump / deferred"
# on the issue itself. Gated by --comment (set in autobump.yml); a link to the run is added when
# in Actions. Keep the wording terse and English, matching the PR body.
STATUS_MARKER='<!-- autobump-status -->'
run_link() {  # markdown " · [LABEL](url)" to the Actions run when in CI, else nothing. $1=label (default run)
    [ -n "${GITHUB_RUN_ID:-}" ] || return 0
    printf ' · [%s](%s/%s/actions/runs/%s)' "${1:-run}" "${GITHUB_SERVER_URL:-https://github.com}" \
        "${GITHUB_REPOSITORY:-$UPSTREAM_REPO}" "$GITHUB_RUN_ID"
}
fold() {  # collapse a reason to one short line so a status comment never dumps evidence
    local s; s=$(printf '%s' "$1" | tr '\n' ' ' | sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//')
    if [ "${#s}" -gt 200 ]; then printf '%s…' "${s:0:199}"; else printf '%s' "$s"; fi
}

status_comment() {  # $1=issue $2=body ; edit the bot's marked comment in place, else create one
    [ "$COMMENT" = 1 ] || return 0
    local n=$1 body="$2" cid i
    [ -n "${AB_FOOTER:-}" ] && body="$body"$'\n'"$AB_FOOTER"
    body="$body"$'\n\n'"$STATUS_MARKER"
    # the FIND must be reliable: if a transient API error left cid empty we'd post a DUPLICATE.
    # retry, and if it never succeeds, skip this update rather than risk a second comment.
    cid=SKIP
    for i in 1 2 3; do
        if cid=$(gh api "repos/$UPSTREAM_REPO/issues/$n/comments" --paginate \
                --jq "map(select(.body|contains(\"$STATUS_MARKER\")))|.[0].id // empty" 2>/dev/null); then
            break
        fi
        cid=SKIP; sleep 3
    done
    [ "$cid" = SKIP ] && return 0
    if [ -n "$cid" ]; then
        for i in 1 2 3; do gh api -X PATCH "repos/$UPSTREAM_REPO/issues/comments/$cid" -f body="$body" >/dev/null 2>&1 && return 0; sleep 3; done
    else
        for i in 1 2 3; do gh issue comment "$n" --repo "$UPSTREAM_REPO" --body "$body" >/dev/null 2>&1 && return 0; sleep 3; done
    fi
}

# opt-in whitelist: only bump packages a maintainer marked `autobump = true` in the
# nvchecker config, so which packages are trusted for auto-bumping is an explicit choice.
# TOML permits a trailing comment after a table header (`["cat/pkg"] # note`); strip an
# inline comment + trailing space before the exact-match compare, else an opted-in package
# with a commented header is silently skipped as not-opted-in.
autobump_enabled() {
    awk -v want="[\"$1\"]" '
        {h=$0; sub(/[[:space:]]*#.*/,"",h); gsub(/[[:space:]]+$/,"",h)}
        h==want {in_pkg=1; next}
        /^\[/   {in_pkg=0}
        in_pkg && /^[[:space:]]*autobump[[:space:]]*=[[:space:]]*true/ {found=1; exit}
        END {exit !found}
    ' .github/workflows/overlay.toml
}

# keep-old opt-in: a package that must KEEP older versions (a real multi-version slot, or an
# upstream that leaves old distfiles fetchable) marks `keep_old = N`; the sweep forwards
# --keep-old=N so the engine keeps the N most-recent versions (0 or true = keep all). Independent
# of autobump (a package is only swept when opted in); same header-match + inline-comment strip.
keep_old_value() {  # print the package's keep_old value (true, or an integer N), else nothing
    awk -v want="[\"$1\"]" '
        {h=$0; sub(/[[:space:]]*#.*/,"",h); gsub(/[[:space:]]+$/,"",h)}
        h==want {in_pkg=1; next}
        /^\[/   {in_pkg=0}
        in_pkg && /^[[:space:]]*keep_old[[:space:]]*=/ {
            v=h; sub(/^[^=]*=[[:space:]]*/,"",v); print v; exit   # h already had the inline comment + trailing space stripped
        }
    ' .github/workflows/overlay.toml
}

attempts=0
for n in "${ISSUES[@]}"; do
    # in fetch mode, stop once LIMIT engine attempts are spent (the skips below are free)
    if [ "$fetched" = 1 ] && [ "$attempts" -ge "$LIMIT" ]; then
        RESULT[$n]="skip (per-run attempt limit $LIMIT reached)"; continue
    fi
    title=$(gh issue view "$n" --repo "$UPSTREAM_REPO" --json title --jq .title 2>/dev/null)
    pkg=$(sed -nE 's/^\[nvchecker\] ([a-z0-9-]+\/[A-Za-z0-9_.+-]+) can be bump to .*/\1/p' <<<"$title")
    ver=$(sed -nE 's/.* can be bump to ([A-Za-z0-9._+-]+)$/\1/p' <<<"$title")
    if [ -z "$pkg" ] || [ -z "$ver" ]; then RESULT[$n]="unparseable title"; continue; fi
    if ! autobump_enabled "$pkg"; then RESULT[$n]="skip (not opted in: no autobump=true)"; continue; fi
    # unquoted below (like $PR) so an empty value word-splits away instead of passing a literal ''
    KEEP_OLD=""; kov=$(keep_old_value "$pkg")
    case "$kov" in
        true)   KEEP_OLD="--keep-old" ;;         # keep all prior versions
        [0-9]*) KEEP_OLD="--keep-old=$kov" ;;     # keep the N most-recent versions
    esac
    # opt-in marker appended to every status comment for this issue, so watchers can see at a
    # glance that the package is auto-managed (and whether old versions are kept).
    AB_FOOTER="— \`autobump\` enabled"
    case "$kov" in
        true|0) AB_FOOTER="$AB_FOOTER · keep_old=all" ;;
        [1-9]*) AB_FOOTER="$AB_FOOTER · keep_old=$kov" ;;
    esac

    if prior=$(grep -m1 -F "$pkg $ver " "$DONE"); then
        RESULT[$n]="skip ($prior)"; continue
    fi

    attempts=$((attempts + 1))
    echo "==== #$n $pkg -> $ver ($attempts/$LIMIT) ===="
    status_comment "$n" "**autobump** is bumping \`$pkg\` → \`$ver\`…$(run_link)"
    out=$($ENGINE "$n" $KEEP_OLD $PR 2>&1); ec=$?
    echo "$out" | tail -4

    case "$ec" in
    0)
        echo "$pkg $ver bumped $(date +%F)" >> "$DONE"
        RESULT[$n]="bumped$([ -n "$PR" ] && echo ' + PR')"
        pr_url=$(grep -oE 'https://github.com/[^ ]+/pull/[0-9]+' <<<"$out" | tail -1)
        status_comment "$n" "**autobump** bumped \`$pkg\` → \`$ver\`${pr_url:+ — opened $pr_url}$(run_link)"
        ;;
    3)
        # parse the anchor the engine prints ("evidence: <dir> =="), not a hard-coded /tmp
        # prefix -- the engine's Dir.mktmpdir honors $TMPDIR (e.g. /var/tmp on a Gentoo box),
        # so a /tmp grep would miss or (with /var/tmp) strip to a wrong path.
        ev=$(sed -nE 's/.*evidence: ([^ ]+) ==.*/\1/p' <<<"$out" | tail -1)
        old=$(sed -nE 's/^>> current: ([^ ]+) +-> +target:.*/\1/p' <<<"$out" | head -1)
        if [ -z "$ev" ] || [ ! -d "$ev" ]; then
            # engine output/format drift: don't turn every escalation into a permanent empty-
            # reason defer. Treat as transient (retry, ATTEMPTS-capped) so it isn't silently lost.
            tries=$(grep -c -F "$pkg $ver " "$ATTEMPTS" 2>/dev/null); tries=${tries:-0}
            echo "$pkg $ver $(date +%F)" >> "$ATTEMPTS"
            if [ "$tries" -ge 2 ]; then
                echo "$pkg $ver deferred $(date +%F)" >> "$DONE"
                RESULT[$n]="deferred (exit 3, evidence dir unparseable after $((tries+1)) tries)"
            else
                RESULT[$n]="exit 3 but evidence dir not found (try $((tries+1)), retrying)"
            fi
            continue
        fi
        if [ -n "$JUDGE" ]; then
            verdict_json=$(bash "$TOOLS/autobump-judge.sh" "$ev" "$pkg" "${old:-?}" "$ver")
            echo "judge: $verdict_json"
        else
            # no model configured: straight to a human, evidence as the reason
            reasons=$(paste -sd';' "$ev/escalations.txt" 2>/dev/null | sed 's/;/; /g')
            [ -n "$reasons" ] || reasons="see evidence in $ev"
            verdict_json=$(jq -cn --arg r "$reasons" \
                '{verdict:"human",reasons:[$r],use_flags_needed:[],deps_changed:[],issue_comment:("not mechanically safe: "+$r)}')
        fi
        verdict=$(jq -r .verdict <<<"$verdict_json")
        if [ "$verdict" = proceed ]; then
            out2=$($ENGINE "$n" --accept-surface --accept-payload $KEEP_OLD $PR 2>&1); ec2=$?
            echo "$out2" | tail -3
            if [ "$ec2" = 0 ]; then
                echo "$pkg $ver bumped-after-judge $(date +%F)" >> "$DONE"
                RESULT[$n]="bumped (judge accepted surface delta)"
            elif [ "$ec2" = 2 ]; then
                # cap the judge-accepted retry through the same ATTEMPTS ledger as the top-level
                # transient path, so an escalate->judge->timeout loop terminates at a human
                # instead of re-running (and re-paying the judge) every sweep forever.
                tries=$(grep -c -F "$pkg $ver " "$ATTEMPTS" 2>/dev/null); tries=${tries:-0}
                echo "$pkg $ver $(date +%F)" >> "$ATTEMPTS"
                if [ "$tries" -ge 2 ]; then
                    echo "$pkg $ver deferred-transient $(date +%F)" >> "$DONE"
                    RESULT[$n]="deferred after $((tries+1)) judge-retry transients"
                    status_comment "$n" "**autobump** accepted the surface delta for \`$pkg\` → \`$ver\` but the retry hit transient failures $((tries+1)) times. A maintainer may need to bump it by hand.$(run_link)"
                else
                    RESULT[$n]="judge-retry deferred transiently (try $((tries+1)))"
                fi
            else
                echo "$pkg $ver deferred $(date +%F)" >> "$DONE"
                RESULT[$n]="deferred (retry failed, exit $ec2)"
            fi
        else
            echo "$pkg $ver deferred $(date +%F)" >> "$DONE"
            # CLEAR reason first: the engine's own one-line "not mechanically safe (REASON)"
            # (e.g. "payload layout changed") — never a bare /tmp evidence path.
            clear=$(sed -nE 's/.*not mechanically safe \(([^)]+)\).*/\1/p' <<<"$out" | tail -1)
            case "$clear" in ''|"see evidence in $ev") clear=$(jq -r '.reasons | join("; ")' <<<"$verdict_json") ;; esac
            case "$clear" in ''|"see evidence in $ev") clear="needs a manual bump" ;; esac
            RESULT[$n]="escalated: $clear"
            body="**autobump** can't bump \`$pkg\` → \`$ver\` mechanically: **$(fold "$clear")**. Needs a manual bump.$(run_link log)"
            # collapse the raw evidence into <details> so the comment stays short but the detail is one click away
            ev_txt=$(sed 's/```//g' "$ev/escalations.txt" 2>/dev/null | grep -v '^[[:space:]]*$' | head -25)
            [ -n "$ev_txt" ] && body="$body"$'\n\n'"<details><summary>evidence</summary>"$'\n\n''```'$'\n'"$ev_txt"$'\n''```'$'\n'"</details>"
            status_comment "$n" "$body"
        fi
        ;;
    *)
        # a PERMANENT precondition (already at target / ebuild exists / would downgrade) is
        # not transient: record terminal and skip the misleading "build failure" comment.
        if grep -qE 'already at|already exists|would downgrade|newer than target' <<<"$out"; then
            echo "$pkg $ver done-precondition $(date +%F)" >> "$DONE"
            RESULT[$n]="done (precondition: overlay already at/ahead of $ver)"
            # overlay already has this version or newer (a stale nvchecker issue); replace the
            # "is bumping…" comment with a terminal note so it does not read as stuck forever.
            status_comment "$n" "**autobump**: \`$pkg\` is already at (or ahead of) \`$ver\` in the overlay — nothing to bump.$(run_link)"
        else
            # genuine transient (dirty tree, fetch flake, emerge timeout, dep-resolution gap):
            # retry next sweep, but CAP retries so it eventually reaches a human.
            tries=$(grep -c -F "$pkg $ver " "$ATTEMPTS" 2>/dev/null); tries=${tries:-0}
            echo "$pkg $ver $(date +%F)" >> "$ATTEMPTS"
            reason=$(tail -1 <<<"$out" | sed -E 's/^[[:space:]]*!+[[:space:]]*//')
            if [ "$tries" -ge 2 ]; then
                echo "$pkg $ver deferred-transient $(date +%F)" >> "$DONE"
                RESULT[$n]="deferred after $((tries+1)) transient attempts: $reason"
                status_comment "$n" "**autobump** gave up on \`$pkg\` → \`$ver\` after $((tries+1)) tries: $(fold "$reason"). A maintainer may need to bump it by hand.$(run_link log)"
            else
                RESULT[$n]="not attempted (transient, try $((tries+1))): $reason"
                status_comment "$n" "**autobump** deferred \`$pkg\` → \`$ver\` (transient: $(fold "$reason")). Will retry automatically.$(run_link)"
            fi
        fi
        ;;
    esac
done

[ -n "$ORIG_BRANCH" ] && git checkout -q "$ORIG_BRANCH" 2>/dev/null
rm -rf "$TOOLS"

echo
echo "==== sweep summary ===="
for n in "${ISSUES[@]}"; do printf '#%s  %s\n' "$n" "${RESULT[$n]:-?}"; done
