#!/usr/bin/env bash
# usage: emerge-qa.sh before
#        emerge-qa.sh after
# Adds the qa-vdb and LDFLAGS QA checks to emerge-on-pr, and moves their notices
# out of the elog in elog-report/, so they are listed in the pull request comment
# and do not fail the job.
set -euo pipefail
REPORT=elog-report

# before: install iwdevtools, run qa-vdb after pkg_postinst as qa-vdb(1) shows, and
# mark LDFLAGS with the symbol Portage checks for in every ELF file
before() {
    FEATURES=getbinpkg emerge --oneshot --quiet app-portage/iwdevtools
    cat >> /etc/portage/bashrc << 'EOF'
QA_VDB_ARGS="--no-color --no-extra"
source /usr/share/iwdevtools/qa-vdb.bashrc

post_pkg_postinst() {
	qa-vdb_post_pkg_postinst
}
EOF
    cat >> /etc/portage/make.conf << 'EOF'
LDFLAGS="${LDFLAGS} -Wl,--defsym=__gentoo_check_ldflags__=0"
EOF
    echo "LDFLAGS=$(portageq envvar LDFLAGS)"
}

# split_notices <elog> <notices>: print the elog without the notices, which go to <notices>
# under the same package and section lines
split_notices() {
    awk -v notices="$2" '
        function flush(   i) {
            if (kept) {
                if (pkg != "") print pkg
                pkg = ""
                print header
                for (i = 1; i <= kept; i++) print keep[i]
            }
            if (noted) {
                if (notice_pkg != "") print notice_pkg > notices
                notice_pkg = ""
                print header > notices
                for (i = 1; i <= noted; i++) print note[i] > notices
            }
            kept = noted = 0
            state = ""
        }
        /^>>> / { flush(); header = ""; pkg = notice_pkg = $0; next }
        /^(LOG|WARN|ERROR|QA): [a-z]+$/ { flush(); header = $0; qa = $0 ~ /^QA/; next }
        {
            line = $0
            gsub(/\x1b\[[0-9;]*m/, "", line)
            if (qa && line ~ /^QA Notice: Files built without respecting LDFLAGS have been detected/)
                state = "ldflags"
            else if (state == "ldflags" && line !~ /^( Please include the following list of files in your report:$|\/)/)
                state = ""
            # qa-vdb runs after pkg_postinst, so its output ends the section
            if (qa && line ~ /^VDB: detected possibly incorrect R?DEPEND /)
                state = "vdb"
            if (state != "") note[++noted] = $0
            else keep[++kept] = $0
        }
        END { flush() }
    ' "$1"
}

# after: move the notices out of elog and target-elog, keeping only the target's in notices
after() {
    local file
    [ -f "$REPORT/elog" ] || return 0
    for file in elog target-elog; do
        split_notices "$REPORT/$file" "$REPORT/$file.notices" > "$REPORT/$file.new"
        mv "$REPORT/$file.new" "$REPORT/$file"
    done
    rm -f "$REPORT/elog.notices"
    if [ -s "$REPORT/target-elog.notices" ]; then
        mv "$REPORT/target-elog.notices" "$REPORT/notices"
        cat "$REPORT/notices"
    else
        rm -f "$REPORT/target-elog.notices"
    fi
}

command=${1:-}
case $command in
    before|after)
        shift
        "$command" "$@"
        ;;
    *)
        echo 'usage: emerge-qa.sh before | after' >&2
        exit 2
        ;;
esac
