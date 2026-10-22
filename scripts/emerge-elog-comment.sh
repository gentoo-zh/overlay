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

# summary <qa> <errors> <warnings> <messages>: "1 QA, 2 log", empty without sections
summary() {
    local counts=() text
    [ "$1" -eq 0 ] || counts+=("$1 QA")
    [ "$2" -eq 0 ] || counts+=("$2 error")
    [ "$3" -eq 0 ] || counts+=("$3 warn")
    [ "$4" -eq 0 ] || counts+=("$4 log")
    text=$(printf '%s, ' "${counts[@]}")
    echo "${text%, }"
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

# add_need <atom> <profile> <entry>: an entry autounmask added, shared by the profiles
# that needed it
need_keys=()
declare -A need_profiles
add_need() {
    local key="$1"$'\t'"$3"
    [ -n "${need_profiles[$key]+set}" ] || need_keys+=("$key")
    need_profiles[$key]+="${need_profiles[$key]:+, }<code>$2</code>"
}

t_atom=()
t_profile=()
t_emerge=()
t_elog=()
broken=0
output=0
failing=0
dependencies_failing=0
noticed=0
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
    if [ "$outcome" != success ]; then
        broken=$(( broken + 1 ))
    elif [ "$(field "$dir" unmerge)" = failure ]; then
        emerge='unmerge failed'
        broken=$(( broken + 1 ))
    fi
    build_logs=$(field "$dir" build-logs)
    [[ $build_logs == "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/"* ]] || build_logs=
    if [ -s "$dir/output" ]; then
        add_detail "$atom" "$profile" 'emerge output' "$dir/output" "$build_logs"
        output=1
    fi
    # the pull request's run wrote the entries, so only the first 20 and atom and USE
    # flag characters are kept
    if [ -s "$dir/autounmask" ]; then
        while IFS= read -r entry; do
            [ -z "$entry" ] || add_need "$atom" "$profile" "$entry"
        done < <(head -n 20 "$dir/autounmask" | cut -c 1-200 | tr -cd '[:alnum:] /._+=~@:*<>!\n-')
    fi
    elog=$dir/elog
    if [ ! -s "$elog" ]; then
        case $outcome in
            success|failure) verdict=none ;;
            *) verdict=N/A ;;
        esac
    else
        # only the target's own QA and error elog fails the job; older reports have no
        # target-elog and count every package as the target
        target=$dir/target-elog
        [ -f "$target" ] || target=$elog
        qa=$(sections "$target" QA)
        errors=$(sections "$target" ERROR)
        warnings=$(sections "$target" WARN)
        messages=$(sections "$target" LOG)
        dep_qa=$(( $(sections "$elog" QA) - qa ))
        dep_errors=$(( $(sections "$elog" ERROR) - errors ))
        dep_warnings=$(( $(sections "$elog" WARN) - warnings ))
        dep_messages=$(( $(sections "$elog" LOG) - messages ))
        if [ $(( qa + errors )) -gt 0 ]; then
            failing=$(( failing + 1 ))
        elif [ $(( dep_qa + dep_errors )) -gt 0 ]; then
            dependencies_failing=$(( dependencies_failing + 1 ))
        elif [ $(( warnings + dep_warnings )) -gt 0 ]; then
            warned=$(( warned + 1 ))
        else
            logged=$(( logged + 1 ))
        fi
        verdict=$(summary "$qa" "$errors" "$warnings" "$messages")
        verdict=${verdict:-none}
        dependencies=$(summary "$dep_qa" "$dep_errors" "$dep_warnings" "$dep_messages")
        if [ -n "$dependencies" ]; then
            verdict+="; dependencies: ${dependencies}"
            [ $(( dep_qa + dep_errors )) -eq 0 ] || verdict+=', which do not fail the job'
        fi
        add_detail "$atom" "$profile" elog "$elog"
    fi
    # emerge-qa.sh moved the qa-vdb and LDFLAGS notices out of the elog
    if [ -s "$dir/notices" ]; then
        notices="$(sections "$dir/notices" QA) notice"
        [ "$verdict" = none ] && verdict=$notices || verdict+="; ${notices}"
        noticed=$(( noticed + 1 ))
        add_detail "$atom" "$profile" 'QA notices, which do not fail the job' "$dir/notices"
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
    elif [ "$dependencies_failing" -gt 0 ]; then
        echo '*Status*: :warning: QA or error elog from dependencies only, which does not fail the emerge job'
    elif [ "$noticed" -gt 0 ]; then
        echo '*Status*: :warning: qa-vdb or LDFLAGS QA notices only, which do not fail the emerge job'
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
    if [ "${#need_keys[@]}" -gt 0 ]; then
        echo
        echo 'Autounmask changed the Portage configuration to emerge these packages, so users have to make the same changes:'
        previous=
        for key in "${need_keys[@]}"; do
            atom=${key%%$'\t'*}
            entry=${key#*$'\t'}
            if [ "$atom" != "$previous" ]; then
                echo
                echo "\`${atom}\` needs:"
                echo
                previous=$atom
            fi
            where=
            [ "${need_profiles[$key]}" = "${atom_profiles[$atom]}" ] || where=" (${need_profiles[$key]})"
            echo "- \`${entry%% *}\`: \`${entry#* }\`${where}"
        done
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
