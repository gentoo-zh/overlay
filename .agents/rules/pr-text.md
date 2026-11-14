## Commit and PR Text

Read with: `git-workflow.md` for branch, rebase, and push; `version-bumps.md` § Keeping Old Versions for the `drop OLD` decision the subject states.

### Subject

- Use pkgdev's final English subject verbatim as PR title, never translated or reworded; for multiple commits, choose the main change's subject.
- Use `category/package: summary`; bumps use `category/package: add NEW`, adding `, drop OLD` only when dropping. First package commits use `category/package: new package, add NEW`; later versions omit `new package`.

```text
category/package: new package, add NEW
category/package: add NEW
category/package: add NEW, drop OLD
```

- Prefix non-package subjects with the affected eclass/path/file, e.g. `name.eclass:`, `profiles:`, `licenses:`, `package.mask:`, or `AGENTS.md:`. Keep one unwrapped line, at most 69 characters where the prefix permits (GLEP 66).

### Commit body

- Add a body only for rationale the subject cannot carry, separated by a blank line. Do not narrate steps or restate the diff, and do not claim a cause the evidence lacks or fold an unrelated fact into a parenthetical. State each value once; keep package/version/add-drop in the subject and routine passing results in the completion report. Do not open the body by restating the subject (no `更新到 <version>` line). Link upstream evidence for mechanisms Gentoo reviewers already know.
- Give each changed dependency, phase, patch, USE flag, `RESTRICT`, or revbump its own evidence-backed causal line per § Writing. Keep unrelated facts separate.
- For large rewrites or upstream restructuring, name the rewritten scope and its cause in one line; add lines only for unexpected behavior changes.

### PR body

- Use Chinese when the directing human writes in Chinese; otherwise English. Keep one language and the commit body's rationale.
- An optional first line names the precedent or packaging model the change follows, e.g. the `::gentoo` ebuild a fork starts from. Then give one line per change, each with its cause; mention tests among them only when they forced a change, and record actual execution per § Opening the PR.
- For a routine or behavior-neutral change closing an overlay issue, use `Closes #N` followed by the template.

Illustrative completed bodies: a routine bump closing an issue, then two dependency changes tested by an agent. Both assume the explicit-range scan in `qa.md` passed.

```text
Closes #N

<!-- Please put the pull request description above -->

---

Please check all the boxes that apply:

- [x] I have run `pkgcheck scan --commits --net` to check for issues with my commits.
- [x] If I used AI: it followed AGENTS.md, I checked and tested its output, and the description shows tested results, not guesses.

Please note that all boxes must be checked for the pull request to be merged.
```

```text
因为程序通过 `dlopen` 加载 libcurl，所以增加 `net-misc/curl` 运行依赖。
因为程序直接链接 libfmt，所以使用 `dev-libs/libfmt:=`，使 subslot 变化触发重建。

测试：amd64 systemd 安装后启动一次，下载一个文件。

<!-- Please put the pull request description above -->
...
```

### Issue references and trailers

- Place overlay issues as bare `Closes #N` on a separate line after the reason in the PR body. Never pass an overlay issue number or URL to `pkgdev commit -b/--bug` or `-c/--closes`, or rewrite it as a Bugzilla URL. For those options, bare numbers denote Gentoo Bugzilla; non-numeric values require full HTTP(S) URLs. `FIXED`, `OBSOLETE`, and `PKGREMOVED` apply only to Gentoo Bugzilla.
- Let pkgdev generate trailers. Sign off with the contributor's real identity and email, excluding GitHub noreply addresses. Attribution is human-only, without AI, generated-by, or `Co-Authored-By` additions.

### Commits

- Squash each logical change into one clean commit; multi-package PRs use one commit per package, except that `kernels.md` lands one kernel version's source, binary, and virtual in one commit.
- Each commit leaves the tree installable: include its ebuild, `metadata.xml`, and referenced new `licenses/`, `files/`, or eclasses. Apply `AGENTS.md` § Git Workflow for the Manifest. Shared prerequisites land in or before their first consumer commit.
- Never substitute `git commit` for pkgdev; use `pkgdev commit --scan false --signoff --gpg-sign`, omitting `--gpg-sign` if GPG is unavailable.

### Opening the PR

- Replace the first template comment with the reason. Keep the template's checkboxes, which `scripts/pr-template.sh` requires, and tick each only when its statement is true for this PR. The AI checkbox claims tested results, so AI-assisted work states in the body the arch, profile and what ran, or that nothing ran and why. Tick pkgcheck only after the explicit-range commit scan in `qa.md` passes, or when no ebuild changed.
- Before `gh pr create`/`gh pr edit`, show the exact title, body, and files and obtain confirmation for that specific PR, including drafts. Batch authorization requires per-PR confirmation.
- Open only routine bumps yourself: ebuild rename plus `pkgdev manifest`, or a version variable such as a build id, with no other change. For other changes, push the fork topic branch and hand over the drafted subject/body and canonical compare link for the human to open.
  `https://github.com/gentoo-zh/overlay/compare/master...<fork-owner>:<fork-repo>:<branch>`
- Watch CI and fix failures using its logs.

## Writing

Use precise, plain, short prose for commits, PRs, comments, notes, and replies.

- Name concrete variables, phases, USE flags, `FEATURES`, eclasses, and commands. Use established technical terms and concrete behavior. Keep wording professional and factual; mix languages only where necessary; back absolute claims with evidence. Never coin an ad-hoc term.
- State evidence-backed cause and effect explicitly, never through a vague linker such as correspondingly/相应; because/so (因为…所以…) is the usual form, and a fact that already carries its own consequence needs no forced because-clause. Explain the reason beyond metadata values.
- Chinese may be Traditional or Simplified; use standard Mandarin understood across regions. Write ordinary words plainly and each language natively, professionally, and fluently.
- Do not set off Chinese words with full-width brackets (`「」`, `『』`).
- Put variables, atoms, commands, options, `FEATURES`, and other code/literal values in backticks.

| Reads naturally | Does not |
| --- | --- |
| 原生可执行文件移到各平台子包 | 拆成薄 loader |
| 因为上游变更了 Go 模块路径，所以 `-ldflags` 中的导入路径需同步更新，否则注入的版本号不正确 | module 改名，相应更新 ldflags |
