#!/usr/bin/env bash
# usage: pkgcheck-report.sh packages|scan|stage
set -euo pipefail

case "${1:?packages, scan or stage}" in
    packages)
        git config --global --add safe.directory '*'
        # The merge ref parents are the current base tip and PR head.
        git diff --name-only --diff-filter=d 'HEAD^1...HEAD^2' \
            | awk -F/ 'NF > 2 { print $1"/"$2 }' | sort -u > touched.txt
        : > packages.txt
        while read -r pkg; do
            ls "${pkg}"/*.ebuild >/dev/null 2>&1 || continue
            echo "${pkg}" >> packages.txt
        done < touched.txt
        echo "count=$(wc -l < packages.txt)" >> "$GITHUB_OUTPUT"
        cat packages.txt
        ;;
    scan)
        pmaint sync gentoo
        head=$(git rev-parse HEAD)

        # --config no drops the exit keywords in metadata/pkgcheck.conf, so a failure means the
        # scan broke rather than that it found something.
        scan() {
            local out=$1
            shift
            pmaint regen --dir ~/.cache/pkgcheck/repos . > /dev/null
            pkgcheck scan --config no --checks=-RedundantVersionCheck --keywords=-NonsolvableDepsInDev \
                --reporter JsonStream "$@" > "${out}"
        }

        mapfile -t pkgs < packages.txt
        scan report.json "${pkgs[@]}"

        git checkout --quiet 'HEAD^1'
        : > base-report.json
        mapfile -t base_pkgs < <(
            for pkg in "${pkgs[@]}"; do
                ls "${pkg}"/*.ebuild > /dev/null 2>&1 && echo "${pkg}"
            done
        )
        [ "${#base_pkgs[@]}" -eq 0 ] || scan base-report.json "${base_pkgs[@]}"
        git checkout --quiet "${head}"

        rc=0
        python3 scripts/pkgcheck-new-findings.py base-report.json report.json > findings.json || rc=$?
        [ "${rc}" -eq 0 ] || [ "${rc}" -eq 3 ] || exit "${rc}"
        : > scan-complete
        if [ "${rc}" -eq 3 ]; then
            echo '::error::this pull request adds error level pkgcheck findings'
            exit 1
        fi
        ;;
    stage)
        mkdir -p pkgcheck-report
        git rev-parse --short 'HEAD^2' > pkgcheck-report/commit
        cp packages.txt pkgcheck-report/packages 2>/dev/null || : > pkgcheck-report/packages
        cp findings.json pkgcheck-report/findings.json 2>/dev/null || echo '[]' > pkgcheck-report/findings.json
        # the comment runs master's scripts, which may be newer than the ones that made this artifact
        [ -f scan-complete ] || : > pkgcheck-report/incomplete
        ;;
esac
