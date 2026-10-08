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

        scan() {
            local out=$1
            shift
            pmaint regen --dir ~/.cache/pkgcheck/repos . > /dev/null
            pkgcheck scan --checks=-RedundantVersionCheck --keywords=-NonsolvableDepsInDev \
                "$@" > "${out}" 2>&1 || true
        }

        mapfile -t pkgs < packages.txt
        scan report.txt "${pkgs[@]}"

        git checkout --quiet 'HEAD^1'
        : > base-report.txt
        mapfile -t base_pkgs < <(
            for pkg in "${pkgs[@]}"; do
                ls "${pkg}"/*.ebuild > /dev/null 2>&1 && echo "${pkg}"
            done
        )
        [ "${#base_pkgs[@]}" -eq 0 ] || scan base-report.txt "${base_pkgs[@]}"
        git checkout --quiet "${head}"

        python3 scripts/pkgcheck-new-findings.py base-report.txt report.txt > new.txt
        echo '--- new ---'; cat new.txt
        echo '--- all ---'; cat report.txt
        : > scan-complete
        ;;
    stage)
        mkdir -p pkgcheck-report
        git rev-parse --short 'HEAD^2' > pkgcheck-report/commit
        cp packages.txt pkgcheck-report/packages 2>/dev/null || : > pkgcheck-report/packages
        cp report.txt pkgcheck-report/report.txt 2>/dev/null || : > pkgcheck-report/report.txt
        cp new.txt pkgcheck-report/new.txt 2>/dev/null || : > pkgcheck-report/new.txt
        [ ! -f scan-complete ] || : > pkgcheck-report/complete
        ;;
esac
