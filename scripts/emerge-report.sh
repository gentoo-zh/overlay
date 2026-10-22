#!/usr/bin/env bash
# usage: emerge-report.sh snapshot
#        emerge-report.sh save <atom>
#        emerge-report.sh check <atom>
# Writes the emerge-on-pr report of one target to elog-report/, which
# emerge-elog-comment.sh turns into the pull request comment.
set -euo pipefail
REPORT=elog-report
BEFORE=/var/tmp/portage-before
SECTION='^(LOG|WARN|ERROR|QA): [a-z]+$'
FAILING='^(QA|ERROR): [a-z]+$'

# package_of <atom>: category/pn, empty when Portage cannot parse the atom
package_of() {
    python3 -I -c '
import sys
from portage.dep import Atom
from portage.exception import InvalidAtom
try:
    print(Atom(sys.argv[1], allow_repo=True).cp)
except InvalidAtom:
    pass
' "$1"
}

# config <directory>: "package.use >=category/pn-1 flag" for each package.* entry,
# including the ._cfg files autounmask writes under CONFIG_PROTECT
config() (
    cd "$1"
    grep -rsHvE '^[[:space:]]*(#|$)' package.accept_keywords package.license package.unmask package.use \
        | sed -E 's|^(package\.[a-z_]+)[^:]*:|\1 |' | sort -u || true
)

# autounmask <package>: the package.* entries added since snapshot
autounmask() {
    local file atom rest
    comm -13 <(config "$BEFORE") <(config /etc/portage) | while read -r file atom rest; do
        # the target is often keyworded ~arch only, so its own keyword entry is expected
        if [ "$file" = package.accept_keywords ] && [ "$(package_of "$atom")" = "$1" ]; then
            continue
        fi
        echo "$file $atom${rest:+ $rest}"
    done
}

# elog <file>...: the elog files as one text, each starting with ">>> category/pf"
elog() {
    local file pkg
    for file in "$@"; do
        # category:pf:date.log -> category/pf
        pkg=${file##*/}
        pkg=${pkg%:*}
        pkg=${pkg/://}
        [[ $file != /var/log/portage/unmerge/* ]] || pkg+=' (unmerge)'
        echo ">>> ${pkg}"
        cat "$file"
    done | awk -v section="$SECTION" '
        # pkg_pretend writes a second file for the package, and an unsaved INFO section
        # between two sections of the same class repeats their header
        /^>>> / { if ($0 == pkg) next; pkg = $0; last = "" }
        $0 ~ section { if ($0 == last) next; last = $0 }
        { print }
    '
}

# snapshot: the package.* configuration before the first emerge, for autounmask
snapshot() {
    mkdir -p "$BEFORE"
    cp -a /etc/portage/package.* "$BEFORE/"
}

# save <atom>: the step outcomes from SETUP, DEPS, OUTCOME and UNMERGE, the output
# of the failed step, the configuration autounmask added, and the elog
save() {
    local atom=${1:?atom} package log file pkg files=() own=()
    package=$(package_of "$atom")
    mkdir -p "$REPORT"
    echo "$atom" > "$REPORT/atom"
    echo "$PROFILE" > "$REPORT/profile"
    echo "$BUILD_LOGS" > "$REPORT/build-logs"
    echo "$SETUP" > "$REPORT/setup"
    echo "$DEPS" > "$REPORT/deps"
    echo "$OUTCOME" > "$REPORT/outcome"
    echo "$UNMERGE" > "$REPORT/unmerge"
    log=
    [ "$DEPS" != failure ] || log=/var/tmp/deps.log
    [ "$OUTCOME" != failure ] || log=/var/tmp/emerge.log
    [ "$UNMERGE" != failure ] || log=/var/tmp/unmerge.log
    # news and config file notices differ between images and say nothing about the failure
    [ -z "$log" ] || grep -vE '^ \* (IMPORTANT: |Use eselect news|See the CONFIGURATION FILES|sections of the emerge man page)' "$log" \
        | cat -s | tail -n 40 > "$REPORT/output"
    # the onlydeps elog is left over when that step fails
    [ "$OUTCOME" != skipped ] || return 0
    autounmask "$package" > "$REPORT/autounmask"
    for file in /var/log/portage/elog/* /var/log/portage/unmerge/elog/*; do
        [ -f "$file" ] || continue
        files+=("$file")
        pkg=${file##*/}
        pkg=${pkg%:*}
        [ "$(package_of "=${pkg/://}")" != "$package" ] || own+=("$file")
    done
    elog "${files[@]}" > "$REPORT/elog"
    elog "${own[@]}" > "$REPORT/target-elog"
}

# check <atom>: fail on QA or error elog of the target. Warn and log elog, such as
# CONFIG_CHECK without kernel sources, and the elog of dependencies only go to the
# pull request comment.
check() {
    local atom=${1:?atom}
    cat "$REPORT/elog"
    if grep -qE "$FAILING" "$REPORT/target-elog"; then
        echo "Found QA or error elog messages from ${atom}."
        exit 1
    fi
    if grep -qE "$FAILING" "$REPORT/elog"; then
        echo 'Found QA or error elog messages from dependencies only, which do not fail this job.'
    else
        echo 'No QA or error elog messages found.'
    fi
}

command=${1:-}
case $command in
    snapshot|save|check)
        shift
        "$command" "$@"
        ;;
    *)
        echo 'usage: emerge-report.sh snapshot | save <atom> | check <atom>' >&2
        exit 2
        ;;
esac
