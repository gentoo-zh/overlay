#!/usr/bin/env bash
# usage: emerge-targets.sh PR
set -euo pipefail

pr=${1:?PR number}
files=$(gh api --paginate "repos/$GITHUB_REPOSITORY/pulls/$pr/files" \
    --jq '.[] | [.filename, .additions, .deletions] | @tsv')
ignore_list=(
    .agents .gitignore AGENTS.md AUTHORS COPYING MIGRATION.md
    README.md README.en.md README.zh-TW.md README.yue.md
    repo.xml skel.ChangeLog skel.metadata.xml .github
    eclass licenses metadata profiles scripts
)
packages=()
while IFS=$'\t' read -r file additions deletions; do
    [ -n "$file" ] || continue
    ignored=false
    for prefix in "${ignore_list[@]}"; do
        if [[ "$file" == "$prefix"* ]]; then
            ignored=true
            break
        fi
    done
    "$ignored" && continue

    IFS=/ read -r category package filename <<< "$file"
    [ -n "$filename" ] || continue
    package="$category/$package"
    if (( additions == 0 && deletions > 0 )); then
        [ -d "$package" ] || continue
        if [[ "$file" == *.ebuild && ! -f "$file" ]]; then
            continue
        fi
    fi
    if [[ "$file" == *.ebuild ]]; then
        packages+=("=$category/${filename%.ebuild}")
    else
        packages+=("$package")
    fi
done <<< "$files"

atoms=$(
    for atom in "${packages[@]}"; do
        if [[ "$atom" != =* ]]; then
            versioned=false
            for candidate in "${packages[@]}"; do
                if [[ "$candidate" == "=$atom-"[0-9]* ]]; then
                    versioned=true
                    break
                fi
            done
            "$versioned" && continue
        fi
        printf '%s\n' "$atom"
    done | sort -u
)

{
    arm64_packages=()
    while IFS= read -r atom; do
        [ -n "$atom" ] || continue
        printf '%s\t%s\t%s\n' "$atom" amd64-desktop-openrc ubuntu-latest
        printf '%s\t%s\t%s\n' "$atom" amd64-desktop-systemd ubuntu-latest

        if [[ "$atom" == =* ]]; then
            category=${atom#=}
            category=${category%%/*}
            filename=${atom##*/}
            ebuilds=("$category"/*/"$filename.ebuild")
        else
            ebuilds=("$atom"/*.ebuild)
        fi
        for ebuild in "${ebuilds[@]}"; do
            [ -f "$ebuild" ] || continue
            keywords=$(sed -n 's/^KEYWORDS="\(.*\)"/\1/p' "$ebuild")
            for keyword in $keywords; do
                if [[ "$keyword" == arm64 || "$keyword" == "~arm64" ]]; then
                    arm64_packages+=("$atom")
                    break 2
                fi
            done
        done
    done <<< "$atoms"
    for atom in "${arm64_packages[@]}"; do
        printf '%s\t%s\t%s\n' "$atom" arm64-desktop-systemd ubuntu-24.04-arm
    done
} | jq -R 'split("\t") | {package: .[0], profile: .[1], runner: .[2]}' | jq -sc .
