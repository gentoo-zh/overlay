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

# plural <count> <noun> [<plural>]: "1 file", "2 files"
plural() {
    if [ "$1" -eq 1 ]; then
        echo "$1 $2"
    else
        echo "$1 ${3:-$2s}"
    fi
}

# fix <atom> <name> <count>: the largest count of a QA notice that needs a fix, over the
# profiles of the package
declare -A fixes
fixed=0
fix() {
    local key="$1"$'\t'"$2"
    fixed=1
    [ "${fixes[$key]:-0}" -ge "$3" ] || fixes[$key]=$3
}

# summary <qa> <errors> <warnings> <messages>: "1 QA, 2 messages", empty without sections
summary() {
    local counts=() text
    [ "$1" -eq 0 ] || counts+=("$1 QA")
    [ "$2" -eq 0 ] || counts+=("$(plural "$2" error)")
    [ "$3" -eq 0 ] || counts+=("$(plural "$3" warning)")
    [ "$4" -eq 0 ] || counts+=("$(plural "$4" message)")
    text=$(printf '%s, ' "${counts[@]}")
    echo "${text%, }"
}

# add_detail <atom> <profile> <title> <file> [<build-log-url>]: a collapsed block, shared
# by the profiles that printed the same text. The block's key is left in detail_key.
keys=()
declare -A detail_atom detail_title detail_text detail_profiles detail_links detail_unlinked detail_all detail_action detail_footer atom_profiles
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
    detail_key=$key
}

# add_notice <atom> <profile> <title> <action> <file>: add_detail for a QA notice that
# needs a fix, with the fix under the summary
add_notice() {
    add_detail "$1" "$2" "$3" "$5"
    detail_all[$detail_key]=1
    detail_action[$detail_key]=$4
}

# add_ldflags <atom> <profile> <file>: one block per package with the files of the first
# profile, and a line under it for every other profile that listed different files
add_ldflags() {
    local key="ldflags $1" text files
    text=$(cat "$3")
    files=$(plural "$(wc -l < "$3")" file)
    if [ -z "${detail_text[$key]+set}" ]; then
        keys+=("$key")
        detail_atom[$key]=$1
        detail_title[$key]="<code>$1</code> ${files} built without respecting LDFLAGS"
        detail_text[$key]=$text
        detail_all[$key]=1
        detail_action[$key]="Set \`QA_PREBUILT\` for prebuilt files; otherwise make the build pass \`LDFLAGS\`, for example with \`cargo_env\`."
    elif [ "$text" != "${detail_text[$key]}" ]; then
        detail_footer[$key]+="- \`$2\`: ${files}, see the [run](${RUN_URL})"$'\n'
    fi
    detail_profiles[$key]+="${detail_profiles[$key]:+, }<code>$2</code>"
    detail_unlinked[$key]=1
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
warned=0
informed=0
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
        # messages of the target and every elog of dependencies are informational
        title=elog
        if [ $(( qa + errors )) -gt 0 ]; then
            failing=$(( failing + 1 ))
        elif [ "$warnings" -gt 0 ]; then
            warned=$(( warned + 1 ))
        else
            informed=$(( informed + 1 ))
            title='elog, informational'
        fi
        verdict=$(summary "$qa" "$errors" "$warnings" "$messages")
        verdict=${verdict:-none}
        dependencies=$(summary "$dep_qa" "$dep_errors" "$dep_warnings" "$dep_messages")
        if [ -n "$dependencies" ]; then
            verdict+="; dependencies: ${dependencies}"
            [ $(( dep_qa + dep_errors )) -eq 0 ] || verdict+=', which do not fail the job'
        fi
        add_detail "$atom" "$profile" "$title" "$elog"
    fi
    # emerge-qa.sh moved the qa-vdb and LDFLAGS notices out of the elog
    # qa-vdb marks a missing dependency with > and a missing slot or binding operator with |
    notices=()
    if [ -s "$dir/notices-vdb" ]; then
        count=$(grep -cE '^ *> ' "$dir/notices-vdb" || true)
        if [ "$count" -gt 0 ]; then
            notices+=("missing dependencies ${count}")
            fix "$atom" 'missing dependencies' "$count"
            add_notice "$atom" "$profile" "$(plural "$count" 'missing dependency' 'missing dependencies')" \
                "Add each missing dependency to \`RDEPEND\`." <(sed -nE 's/^ *> //p' "$dir/notices-vdb")
        fi
        count=$(grep -c ' | ' "$dir/notices-vdb" || true)
        if [ "$count" -gt 0 ]; then
            notices+=("slot/binding ${count}")
            fix "$atom" slot/binding "$count"
            add_notice "$atom" "$profile" "$(plural "$count" 'missing slot or binding operator')" \
                'Add the slot or binding operator shown on the right to each dependency.' <(grep ' | ' "$dir/notices-vdb")
        fi
    fi
    if [ -s "$dir/notices-ldflags" ]; then
        count=$(wc -l < "$dir/notices-ldflags")
        notices+=("LDFLAGS $(plural "$count" file)")
        fix "$atom" LDFLAGS "$count"
        add_ldflags "$atom" "$profile" "$dir/notices-ldflags"
    fi
    if [ "${#notices[@]}" -gt 0 ]; then
        listed=$(printf '%s, ' "${notices[@]}")
        listed=":warning: ${listed%, }"
        [ "$verdict" = none ] && verdict=$listed || verdict+="; ${listed}"
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

# fix_summary: "missing dependencies 1, slot/binding 2, LDFLAGS 10 files", summed over
# the packages
fix_summary() {
    local name key total parts=() text
    for name in 'missing dependencies' slot/binding LDFLAGS; do
        total=0
        for key in "${!fixes[@]}"; do
            [ "${key#*$'\t'}" != "$name" ] || total=$(( total + fixes[$key] ))
        done
        [ "$total" -gt 0 ] || continue
        [ "$name" = LDFLAGS ] && parts+=("LDFLAGS $(plural "$total" file)") || parts+=("$name $total")
    done
    text=$(printf '%s, ' "${parts[@]}")
    echo "${text%, }"
}

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
    elif [ "$fixed" -gt 0 ]; then
        echo "*Status*: :warning: QA notices that need a fix, which do not fail the emerge job: $(fix_summary)"
    elif [ "$warned" -gt 0 ]; then
        echo '*Status*: :warning: warnings only, which do not fail the emerge job'
    elif [ "$informed" -gt 0 ] || [ "${#need_keys[@]}" -gt 0 ]; then
        echo '*Status*: :white_check_mark: informational output only, which does not fail the emerge job'
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
        echo 'Autounmask added these entries to the Portage configuration. The pull request needs no change for them, but users must add the same entries:'
        previous=
        for key in "${need_keys[@]}"; do
            atom=${key%%$'\t'*}
            entry=${key#*$'\t'}
            if [ "$atom" != "$previous" ]; then
                echo
                echo "\`${atom}\` requires:"
                echo
                previous=$atom
            fi
            where=
            [ "${need_profiles[$key]}" = "${atom_profiles[$atom]}" ] || where=" (${need_profiles[$key]})"
            echo "- \`${entry%% *}\`: \`${entry#* }\`${where}"
        done
    fi
} > "$body_file"
# a package's LDFLAGS block follows its other blocks, which later profiles can add
ordered=()
pending=
for key in "${keys[@]}"; do
    if [ -n "$pending" ] && [ "${detail_atom[$key]}" != "${detail_atom[$pending]}" ]; then
        ordered+=("$pending")
        pending=
    fi
    [[ $key == 'ldflags '* ]] && pending=$key || ordered+=("$key")
done
[ -z "$pending" ] || ordered+=("$pending")
# a comment holds at most 65536 characters, shared with the pkgcheck section
for key in "${ordered[@]}"; do
    text=${detail_text[$key]}
    title=${detail_title[$key]}
    links=${detail_links[$key]:-}
    # name the profiles when they did not all print the same, unless every one has a build.log link;
    # a QA notice says "all profiles" when more than one did
    if [ -z "$links" ] || [ -n "${detail_unlinked[$key]:-}" ]; then
        if [ "${detail_profiles[$key]}" != "${atom_profiles[${detail_atom[$key]}]}" ]; then
            title+=" (${detail_profiles[$key]})"
        elif [ -n "${detail_all[$key]:-}" ] && [[ ${detail_profiles[$key]} == *,* ]]; then
            title+=' (all profiles)'
        elif [ -n "${detail_all[$key]:-}" ]; then
            title+=" (${detail_profiles[$key]})"
        fi
    fi
    [ -z "$links" ] || title+=", build.log: ${links}"
    [ -z "${detail_action[$key]:-}" ] || title=":warning: ${title}"
    lines=$(wc -l <<< "$text")
    detail=$(
        echo
        echo "<details><summary>${title}</summary>"
        echo
        if [ -n "${detail_action[$key]:-}" ]; then
            echo "${detail_action[$key]}"
            echo
        fi
        echo '``````'
        head -n "$MAX_LINES" <<< "$text"
        echo '``````'
        if [ "$lines" -gt "$MAX_LINES" ]; then
            echo
            echo "$(( lines - MAX_LINES )) more lines in the [run](${RUN_URL})."
        fi
        if [ -n "${detail_footer[$key]:-}" ]; then
            echo
            echo 'Other profiles listed different files:'
            echo
            printf '%s' "${detail_footer[$key]}"
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
