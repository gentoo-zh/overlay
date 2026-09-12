## Commit and PR Text

### Subject

- Take `pkgdev`'s final English subject verbatim as the PR title. Never translate or reword it.
- Where a PR carries more than one commit, use the subject of the commit carrying its main change.
- A package subject is `category/package: summary`. A bump is `category/package: add NEW`, with `, drop OLD` only when dropping.
- A package's first commit is `category/package: new package, add NEW`. Later versions of it drop the `new package` clause.
- A non-package change instead names an eclass (`name.eclass:`) or the affected path or filename—`profiles:`, `licenses:`, `package.mask:`, this overlay's own `AGENTS.md:`—whatever lets a reader identify what changed.
- The subject is one unwrapped line, at most 69 characters (GLEP 66) where the prefix permits.

### Commit body

- Add a body only when the subject cannot carry the reason; use subject / blank line / body.
- The commit body carries only the reason. Do not narrate steps, restate the diff, or report a passing build, test, or scan.
- Do not lecture on a mechanism a Gentoo reviewer already knows; link the upstream source instead.
- The subject already carries the package, version, and add/drop. The body repeats none of them and states each value once.
- Do not open the body by restating the title (no `更新到 <version>` line).
- Give each changed dependency, phase function, patch, USE flag, `RESTRICT`, or revbump its own line, applying the causality rule in `AGENTS.md` § Writing.
- Do not invent causality the evidence lacks, or fold an unrelated fact into a parenthetical.
- For a large rewrite or upstream restructure, name the rewritten scope instead of enumerating per change. Add a line only for an unexpected behavioral shift.
- When upstream drove that rewrite, give one line in the form 因为上游修改了 X，所以重写 Y.
- Put variables, atoms, commands, options, and `FEATURES` values in backticks.

### PR body

- Write the PR body in Chinese when the human directing the current work item writes in Chinese; otherwise use English. Never use both languages.
- The PR body carries the same rationale as the commit body.
- Do not report passing tests or which arches were tested; the checklist and CI attest those. A test earns a mention only when it forced a change.
- A routine or behavior-neutral change needs only `Closes #N` when it closes an overlay issue.

### Issue references and trailers

- Keep overlay GitHub issues as bare `Closes #N` in the PR body; never pass their number or URL to `pkgdev commit -b/--bug` or `-c/--closes`, or rewrite them as Gentoo Bugzilla URLs.
- For those `pkgdev` options, a bare number means a Gentoo Bugzilla ID; a non-numeric value requires a full HTTP(S) URL. `FIXED`, `OBSOLETE`, and `PKGREMOVED` apply only to Gentoo Bugzilla bugs.
- Let `pkgdev` generate trailers. Sign off with the contributor's real identity and email, never a GitHub noreply address such as `<id>+<user>@users.noreply.github.com`.
- Do not add AI, generated-by, or `Co-Authored-By` attribution.

### Commits

- Land each logical change as one clean squashed commit. In a multi-package PR that means one commit per package, never two packages combined.
- Every commit stands alone and leaves the tree installable: keep an ebuild with its `Manifest`, `metadata.xml`, and any new `licenses/`, `files/`, or eclass it references in that same commit.
- In a multi-commit PR, order commits so a shared prerequisite lands in or before the first commit that uses it: a new license, eclass, or depended-on package.
- Commit with `pkgdev commit --scan false --signoff --gpg-sign`; if GPG is unavailable, omit `--gpg-sign`. Never use raw `git commit`.

### Opening the PR

- Keep the PR template: put the description above its marker, leave the checklist intact, and tick only checks that ran.
- Before opening or updating a PR (`gh pr create`/`gh pr edit`), show the human the exact title, body, and files, and get confirmation for that specific PR.
- A blanket or batch go-ahead is not per-PR confirmation, drafts included.
- Open the PR yourself only for a routine bump: an ebuild rename plus `pkgdev manifest`, or a version variable such as a build id, with nothing else changed.
- Any other change stops at the fork. Push the topic branch, hand the human the drafted subject and body with its compare link against `<canonical>/master`, and let them open the PR.

  ```text
  https://github.com/gentoo-zh/overlay/compare/master...<fork-owner>:<fork-repo>:<branch>
  ```

- Watch CI and fix failures from their logs rather than guessing.

Non-version-bump commit example:

```text
category/package: short description

Essential reason, only when the subject cannot carry it.
Reference related bugs or issues when relevant.
```

Version-bump subjects (choose one):

```text
category/package: new package, add new_version
```

```text
category/package: add new_version
```

```text
category/package: add new_version, drop old_version
```

PR body examples—a routine bump, a single change, one change with two reasons, then several changes:

```text
Closes #<issue>
```

```text
在 `RDEPEND` 中增加 `dev-libs/libfoo`，因为已安装的文件需要 `libfoo.so`。Closes #<issue>
```

```text
因为测试会导入 `media-sound/feeluown`，但将它加入测试依赖会造成循环依赖；测试还需联网访问 YouTube Music API，无法在 `FEATURES=network-sandbox` 下运行，所以增加 `RESTRICT=test`。Closes #<issue>
```

```text
上游 `FindLibCURL.cmake` 会在构建时通过 `FetchContent` 下载固定版本的 curl 头文件。Closes #<issue>

1. 因为该下载会被 `FEATURES=network-sandbox` 阻止，所以改为离线提供：在 `SRC_URI` 加入该版本的 curl 头文件包，并通过 `-DFETCHCONTENT_SOURCE_DIR_LIBCURLHEADERS` 指向解包目录。
2. 因为程序运行时通过 `dlopen` 加载 libcurl，所以 `RDEPEND` 增加 `net-misc/curl`。
3. 因为程序直接链接 libfmt，所以将依赖改为 `dev-libs/libfmt:=`，使当前包在 libfmt 的 subslot 变化时重新构建。
```
