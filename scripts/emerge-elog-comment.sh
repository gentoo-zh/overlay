#!/usr/bin/env bash
# usage: emerge-elog-comment.sh <artifacts-directory>
# Each subdirectory holds one emerge-on-pr target: atom, profile, outcome, elog.
set -euo pipefail
MARKER='<!-- pkgcheck-report -->'
MAX_LINES=40
MAX_BYTES=40000
MAX_TABLE=20000
artifacts_dir=${1:?artifacts-directory}
body_file=$(mktemp)
trap 'rm -f "$body_file"' EXIT

pr=$(scripts/pr-at-commit.sh "$GITHUB_REPOSITORY" "$HEAD_SHA")
if [ -z "$pr" ]; then
    echo 'no open pull request at this commit'
    exit 0
fi
echo "pull request #${pr}"

# field <dir> <name>: one artifact value. The pull request's run wrote it, so only
# atom characters are kept.
field() {
    { head -c 200 "$1/$2" 2>/dev/null || true; } | tr -cd '[:alnum:]/._+=~@:-'
}

targets=()
while IFS= read -r dir; do
    targets+=("$dir")
done < <(
    find "$artifacts_dir" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r dir; do
        echo "$(field "$dir" atom) $(field "$dir" profile) $dir"
    done | sort -V | cut -d ' ' -f 3-
)
if [ "${#targets[@]}" -eq 0 ]; then
    echo 'no elog reports'
    exit 0
fi

# sections <file> <classes>: Portage starts every elog section with "CLASS: phase".
sections() {
    grep -cE "^(${2}): [a-z]+\$" "$1" || true
}

# add_detail <atom> <profile> <title> <file> [<build-log-url>]: a collapsed block, shared
# by the profiles that printed the same text
keys=()
declare -A detail_atom detail_title detail_text detail_profiles detail_links detail_unlinked atom_profiles
add_detail() {
    local text key
    text=$(sed 's/\x1b\[[0-9;]*m//g' "$4")
    # the fetch lines carry a wget time stamp and byte count that differ between runners
    key=$(sed -E '/^[0-9-]{10} [0-9:]{8} /{s///; s/\[[0-9/]+\]//g}' <<< "$1 $3"$'\n'"$text" | md5sum)
    if [ -z "${detail_text[$key]+set}" ]; then
        keys+=("$key")
        detail_atom[$key]=$1
        detail_title[$key]="<code>$1</code> $3"
        detail_text[$key]=$text
    fi
    detail_profiles[$key]+="${detail_profiles[$key]:+, }<code>$2</code>"
    if [ -n "${5:-}" ]; then
        detail_links[$key]+="${detail_links[$key]:+ · }<a href=\"$5\">${2/-desktop/}</a>"
    else
        detail_unlinked[$key]=1
    fi
}

t_atom=()
t_profile=()
t_emerge=()
t_elog=()
broken=0
output=0
failing=0
warned=0
logged=0
for dir in "${targets[@]}"; do
    atom=$(field "$dir" atom)
    atom=${atom#=}
    profile=$(field "$dir" profile)
    atom_profiles[$atom]+="${atom_profiles[$atom]:+, }<code>${profile}</code>"
    outcome=$(field "$dir" outcome)
    if [ "$(field "$dir" setup)" = failure ]; then
        emerge='portage setup failed'
    elif [ "$(field "$dir" deps)" = failure ]; then
        emerge='dependencies failed'
    else
        case $outcome in
            success|failure) emerge=$outcome ;;
            skipped) emerge='not run, an earlier step failed' ;;
            *) emerge=unknown ;;
        esac
    fi
    [ "$outcome" = success ] || broken=$(( broken + 1 ))
    build_logs=$(field "$dir" build-logs)
    [[ $build_logs == "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/"* ]] || build_logs=
    if [ -s "$dir/output" ]; then
        add_detail "$atom" "$profile" 'emerge output' "$dir/output" "$build_logs"
        output=1
    fi
    elog=$dir/elog
    if [ ! -s "$elog" ]; then
        case $outcome in
            success|failure) verdict=none ;;
            *) verdict=N/A ;;
        esac
    else
        qa=$(sections "$elog" QA)
        errors=$(sections "$elog" ERROR)
        warnings=$(sections "$elog" WARN)
        messages=$(sections "$elog" LOG)
        counts=()
        [ "$qa" -eq 0 ] || counts+=("${qa} QA")
        [ "$errors" -eq 0 ] || counts+=("${errors} error")
        [ "$warnings" -eq 0 ] || counts+=("${warnings} warn")
        [ "$messages" -eq 0 ] || counts+=("${messages} log")
        if [ $(( qa + errors )) -gt 0 ]; then
            failing=$(( failing + 1 ))
        elif [ "$warnings" -gt 0 ]; then
            warned=$(( warned + 1 ))
        else
            logged=$(( logged + 1 ))
        fi
        verdict=$(printf '%s, ' "${counts[@]}")
        verdict=${verdict%, }
        add_detail "$atom" "$profile" elog "$elog"
    fi
    t_atom+=("$atom")
    t_profile+=("$profile")
    t_emerge+=("$emerge")
    t_elog+=("$verdict")
done

# One row per package when every profile gave the same result, one per profile otherwise;
# packages that emerged everywhere without elog are only counted.
rows=()
clean=0
i=0
while [ "$i" -lt "${#t_atom[@]}" ]; do
    j=$i
    same=1
    while [ "$j" -lt "${#t_atom[@]}" ] && [ "${t_atom[$j]}" = "${t_atom[$i]}" ]; do
        [ "${t_emerge[$j]}" = "${t_emerge[$i]}" ] && [ "${t_elog[$j]}" = "${t_elog[$i]}" ] || same=0
        j=$(( j + 1 ))
    done
    if [ "$same" -eq 1 ] && [ "${t_emerge[$i]}" = success ] && [ "${t_elog[$i]}" = none ]; then
        clean=$(( clean + 1 ))
    elif [ "$same" -eq 1 ] && [ $(( j - i )) -gt 1 ]; then
        rows+=("| \`${t_atom[$i]}\` | all | ${t_emerge[$i]} | ${t_elog[$i]} |")
    else
        for (( k = i; k < j; k++ )); do
            rows+=("| \`${t_atom[$k]}\` | \`${t_profile[$k]}\` | ${t_emerge[$k]} | ${t_elog[$k]} |")
        done
    fi
    i=$j
done

{
    echo '## emerge elog'
    echo
    echo "*Newest commit emerged*: \`${HEAD_SHA:0:9}\`"
    if [ "$broken" -gt 0 ] && [ "$output" -gt 0 ]; then
        echo "*Status*: :x: **emerge failed**, the output is below and in the [run](${RUN_URL})"
    elif [ "$broken" -gt 0 ]; then
        echo "*Status*: :x: **emerge failed**, see the [run](${RUN_URL})"
    elif [ "$failing" -gt 0 ]; then
        echo '*Status*: :x: **QA or error elog**, which fails the emerge job'
    elif [ "$warned" -gt 0 ]; then
        echo '*Status*: :warning: warnings only, which do not fail the emerge job'
    elif [ "$logged" -gt 0 ]; then
        echo '*Status*: :white_check_mark: messages only, which do not fail the emerge job'
    else
        echo '*Status*: :white_check_mark: no elog'
    fi
    if [ "${#rows[@]}" -gt 0 ]; then
        echo
        echo '| Package | Profile | emerge | elog |'
        echo '| --- | --- | --- | --- |'
        table=0
        for (( k = 0; k < ${#rows[@]}; k++ )); do
            table=$(( table + ${#rows[$k]} + 1 ))
            if [ "$table" -gt "$MAX_TABLE" ]; then
                echo
                echo "$(( ${#rows[@]} - k )) more rows in the [run](${RUN_URL})."
                break
            fi
            printf '%s\n' "${rows[$k]}"
        done
    fi
    packages=packages
    [ "$clean" -ne 1 ] || packages=package
    if [ "$clean" -gt 0 ] && [ "${#rows[@]}" -gt 0 ]; then
        echo
        echo "${clean} more ${packages} emerged on every profile with no elog."
    elif [ "$clean" -gt 0 ]; then
        echo
        echo "All ${clean} ${packages} emerged on every profile with no elog."
    fi
} > "$body_file"
# a comment holds at most 65536 characters, shared with the pkgcheck section
for key in "${keys[@]}"; do
    text=${detail_text[$key]}
    title=${detail_title[$key]}
    links=${detail_links[$key]:-}
    # name the profiles when they did not all print the same, unless every one has a build.log link
    if [ -z "$links" ] || [ -n "${detail_unlinked[$key]:-}" ]; then
        [ "${detail_profiles[$key]}" = "${atom_profiles[${detail_atom[$key]}]}" ] || title+=" (${detail_profiles[$key]})"
    fi
    [ -z "$links" ] || title+=", build.log: ${links}"
    lines=$(wc -l <<< "$text")
    detail=$(
        echo
        echo "<details><summary>${title}</summary>"
        echo
        echo '``````'
        head -n "$MAX_LINES" <<< "$text"
        echo '``````'
        if [ "$lines" -gt "$MAX_LINES" ]; then
            echo
            echo "$(( lines - MAX_LINES )) more lines in the [run](${RUN_URL})."
        fi
        echo
        echo '</details>'
    )
    if [ $(( $(wc -c < "$body_file") + ${#detail} )) -gt "$MAX_BYTES" ]; then
        printf '\nMore elog in the [run](%s).\n' "$RUN_URL" >> "$body_file"
        break
    fi
    printf '%s\n' "$detail" >> "$body_file"
done

scripts/upsert-comment-section.sh "$GITHUB_REPOSITORY" "$pr" "$MARKER" elog "$body_file"
echo "commented on #${pr}"
