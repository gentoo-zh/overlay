# Repository Guidelines

Reload this file at the start of a work item, and again whenever the conversation has grown long or context was trimmed, so its rules stay in force.

This repository is a Gentoo overlay fork. Use skills and official Gentoo sources for generic ebuild knowledge; keep repository policy and non-obvious correctness gates here.

Prefer the package and its history, a genuinely comparable current package, eclass and upstream source, then official Gentoo documentation and gentoo.git. Never substitute memory or superficial similarity for evidence.

## Writing

Use one standard for commit messages, PRs, comments, notes, and replies: precise, plain, and short.

- Name concrete variables, phases, USE flags, `FEATURES`, eclasses, and commands—not a vague paraphrase or adjective. Use current Gentoo terminology.
- Avoid colloquial wording, needless language mixing, unsupported absolutes, marketing, and filler—name a thing by its ecosystem's term or concrete behavior, never an ad-hoc coinage. "原生可执行文件移到各平台子包" reads; "拆成薄 loader" does not.
- State a reason as an explicit because/so (因为…所以…) cause and effect—never a vague linker like "correspondingly"/相应—not a restatement of `name = value` metadata. "因为上游改了 Go 模块路径，所以 `-ldflags` 里的导入路径也要一起改，否则生成的版本号会不对" reads; "module 改名，相应更新 ldflags" does not.
- Chinese may use Traditional or Simplified characters. Use standard Mandarin wording readily understood across regions; avoid region-specific terms.
- Write each language natively: professional but plainly worded, fluent, and causal. Stilted phrasing usually comes from translating the other language word for word—avoid it.

## Commit and PR Text

- Take `pkgdev`'s final English subject verbatim as the PR title—never translate or reword it. For a package, use `category/package: summary`; a bump is `category/package: add NEW`, with `, drop OLD` only when dropping.
- A non-package change instead names an eclass (`name.eclass:`) or the affected path or filename (`profiles:`, `licenses:`, `package.mask:`, this overlay's own `AGENTS.md:`), whatever lets a reader identify what changed.
- The subject is one unwrapped line, at most 69 characters (GLEP 66) where the prefix permits.
- Add a body only when the subject cannot carry the reason; use subject / blank line / body.
- The commit body carries only the reason; do not narrate steps, restate the diff, report a passing build/test/scan, or lecture on a mechanism a Gentoo reviewer already knows—link the upstream source instead.
- The subject already carries the package, version, and add/drop; the body repeats none of them and states each value once. Do not open the body by restating the title (no `更新到 <version>` line).
- Give each changed dependency, phase function, patch, USE flag, `RESTRICT`, or revbump its own line, applying the causality rule above; do not invent causality the evidence lacks, or fold an unrelated fact into a parenthetical.
- For a large rewrite or upstream restructure, do not enumerate per change—name the rewritten scope, and when upstream drove it give one line in the form 因为上游修改了 X，所以重写 Y; add a line only for an unexpected behavioral shift.
- Put variables, atoms, commands, options, and `FEATURES` values in backticks.
- Write the PR body in Chinese when the human directing the current work item writes in Chinese; otherwise use English. Never use both languages.
- The PR body carries the same rationale as the commit body and reports no passing tests or which arches were tested—the checklist and CI attest it; a test earns a mention only when it forced a change.
- A routine or behavior-neutral change needs only `Closes #N` when it closes an overlay issue.
- Keep overlay GitHub issues as bare `Closes #N` in the PR body; never pass their number or URL to `pkgdev commit -b/--bug` or `-c/--closes`, or rewrite them as Gentoo Bugzilla URLs.
- For those `pkgdev` options, a bare number means a Gentoo Bugzilla ID; a non-numeric value requires a full HTTP(S) URL. `FIXED`, `OBSOLETE`, and `PKGREMOVED` apply only to Gentoo Bugzilla bugs.
- Let `pkgdev` generate trailers. Sign off with the contributor's real identity and email, never a GitHub noreply address such as `<id>+<user>@users.noreply.github.com`. Do not add AI, generated-by, or `Co-Authored-By` attribution.
- Land each logical change as one clean squashed commit; in a multi-package PR that means one commit per package, never two packages combined.
- Every commit stands alone and leaves the tree installable: keep an ebuild with its `Manifest`, `metadata.xml`, and any new `licenses/`, `files/`, or eclass it references in that same commit.
- In a multi-commit PR, order commits so a shared prerequisite—a new license, eclass, or depended-on package—lands in or before the first commit that uses it.
- Commit with `pkgdev commit --scan false --signoff --gpg-sign`; if GPG is unavailable, omit `--gpg-sign`. Never use raw `git commit`.
- Keep the PR template: put the description above its marker, leave the checklist intact, and tick only checks that ran.
- Before opening or updating a PR (`gh pr create`/`gh pr edit`), show the human the exact title, body, and files and get confirmation for that specific PR—a blanket or batch go-ahead is not per-PR confirmation; this holds even for a draft.
- Watch CI and fix failures from their logs rather than guessing.

Non-version-bump commit example:

```text
category/package: short description

Essential reason, only when the subject cannot carry it.
Reference related bugs or issues when relevant.
```

Version-bump subjects (choose one):

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
因为测试会导入 `media-sound/feeluown`，但将它加入测试依赖会造成循环依赖；测试还需要访问在线 YouTube Music API，无法在 `FEATURES=network-sandbox` 下运行，所以增加 `RESTRICT=test`。Closes #<issue>
```

```text
上游 `FindLibCURL.cmake` 会在构建期用 `FetchContent` 下载固定版本的 curl 头文件。Closes #<issue>

1. 因为这个下载会被 `FEATURES=network-sandbox` 阻止，所以改为离线提供：在 `SRC_URI` 加入该版本的 curl 头文件包，并用 `-DFETCHCONTENT_SOURCE_DIR_LIBCURLHEADERS` 指向解包目录。
2. 因为程序运行时用 `dlopen` 加载 libcurl，所以 `RDEPEND` 增加 `net-misc/curl`。
3. 因为程序直接链接 libfmt，所以将依赖改为 `dev-libs/libfmt:=`，使当前包在 libfmt 的 subslot 变化时重新构建。
```

## Git Workflow

Every repository modification is PR-bound unless the current request explicitly says otherwise. Read-only inspection is exempt. Complete preflight before the first edit and repeat it only if the state is no longer known.

Treat `master` only as an upstream-sync branch.

- Start with `git status --short --branch`.
- Use one topic branch per logical PR. Create new work from local `master` freshly synced with `<canonical>/master`; prefer `category-package-version` for bumps.
- When resuming, reuse the correct topic branch. Before preparing a PR, fetch the canonical remote and rebase the topic branch onto `<canonical>/master`; a stale base makes GitHub report the PR out of date.
- Multiple packages may share a PR only for one dependency chain, coordinated bump, or shared fix. Keep unrelated work separate and never split an ebuild from its `Manifest`.
- When fresh state is needed, find the existing remote for `git@github.com:gentoo-zh/overlay.git` or `https://github.com/gentoo-zh/overlay.git`. Match the GitHub owner and repository case-insensitively.
- Support both fork clones (`origin` is personal) and direct clones (`origin` is canonical). Use the existing canonical remote, whatever its name is.
- If none exists, add `upstream` as `git@github.com:gentoo-zh/overlay.git`.
- Fetch the canonical remote before using its state, and ensure `<canonical>/HEAD` resolves (`git remote set-head <canonical> master` if not)—pkgcheck's git checks depend on it independently of any explicit commit range.
- If the fetch fails, stop and report the current URL and error; do not rewrite or bypass it.
- Push only topic branches to an unambiguous personal fork, never `master` or the canonical remote. Use `--force-with-lease` after a rebase. A missing or ambiguous personal fork blocks publishing, not local editing.
- Preserve unrelated changes; never overwrite, revert, stage, or commit them.
- For non-ebuild changes, check `.github/workflows/emerge-on-pr.yml` `ignore_list` so paths are not interpreted as package atoms.
- Stop before editing if the canonical remote is ambiguous, a required `master` sync fails, a branch cannot be created safely, unrelated changes make staging ambiguous, or the request spans unrelated PRs.

## Ebuild Policy

- Install every changed ebuild cleanly; a compile alone is insufficient, and emerge-on-PR fails on every Portage `qa`, `warn`, or `error` elog.
- Where the environment cannot run a real merge (e.g. an unprivileged sandbox that cannot chown to the portage group), record the install as skipped. The amd64 emerge-on-PR CI merges after the push—amd64 only, other `KEYWORDS` unverified—and does not equal a local clean install.
- Build every newly added `KEYWORDS` arch of a source package; never keyword one you did not build. A prebuilt package follows the arm64 exception under Bundled and Prebuilt Binaries.
- Carrying the prior version's keywords forward is retention—do not narrow them to the one arch you built.
- For an arch-independent package, keep the inherited keywords and note the arches you did not verify in the completion report; use `~arch`.
- When removing an arch, update affected reverse dependencies and virtual/meta packages in the same change. A virtual's keywords cannot exceed its providers'. `pkgcheck PotentialStable` is informational.
- Preserve package-local style and user/toolchain flags. Keep patches and refactors narrow; remove forced optimization, hardening, LTO, stripping, and blanket `-Werror`.
- For non-trivial work, use precedent matching the source or prebuilt model, build system, eclass stack, and runtime layout. Re-verify it against the current release.
- Keep release and `9999` behavior distinct. Port applicable dependency, QA, EAPI, and phase fixes to the live ebuild.
- Every `${FILESDIR}` reference must name a committed file. If `PATCHES` coexists with a custom `src_prepare`, call `default` or apply the patches explicitly; `eapply_user` alone does not apply `PATCHES`.
- Keep global scope metadata-invariant and side-effect-free. Do not run external programs, emit uncaptured output, modify system state, or depend on system, profile, repository, or phase data.
- Do not use pipes, process substitution, heredocs, or herestrings there. Bash may back the latter two with temporary files that the metadata sandbox forbids.
- Deterministic package-manager helpers and pure shell expansion are valid in global scope. Put work requiring declared build context in phases.
- Declare external build and test inputs through `SRC_URI`/`Manifest` or an eclass vendor mechanism. Enforce offline operation without warm caches.
- Each USE state must control every applicable option, dependency, source selection, and install cleanup consistently. Disable automagic.
- Verify package and bundled-component licenses, Gentoo license names, and redistribution terms; they determine `RESTRICT=mirror` or `bindist`.

## Version Bumps

- Compare existing ebuilds and history with upstream notes and build metadata for dependency, toolchain, option, license, layout, and installed-file changes.
- The `go.mod` `go` directive and `Cargo.toml` `rust-version` are real minimum versions; no eclass reads them for you. When one exceeds what the profile toolchain guarantees, raise the matching `>=dev-lang/go` `BDEPEND` or `RUST_MIN_VER`.
- If the raised floor is not yet in the tree (e.g. `>=dev-lang/go-1.26.5` while the tree has 1.26.4), open the PR as a draft and cite the upstream `go.mod` and the tree state (packages.gentoo.org).
- The `go.mod` `toolchain` line is only a suggestion under `GOTOOLCHAIN=local` and sets no floor. Use an upper bound only for a verified incompatibility with no available fix.
- Re-check patches and assets. Update the ebuild, `SRC_URI`, version variables, checksums, and `Manifest` together; stop when required evidence is unavailable.
- Normalize the ebuild version by Gentoo rules. Preserve the literal upstream tag through `MY_PV` or an equivalent variable when needed.
- Tracker output is only a hint: verify the real tag, artifact, and URL. `-rN` is a Gentoo revision; never derive upstream tags or filenames from `${PVR}` or `${PF}`.
- Never guess `RDEPEND`, `IUSE`, pins, generated dependency sets, build options, or vendor artifacts merely to obtain a green build.
- A versioned deps/vendor/crates/`node_modules` artifact must already exist for the new version, or the fetch 404s. It is often not upstream but in an overlay or contributor repo—commonly `gentoo-zh-drafts/<PN>`, sometimes `gentoo-zh/gentoo-deps` or a contributor's repo.
- Reuse the exact host and naming the existing `SRC_URI` uses; do not assume upstream, invent a host, or switch repos on your own. Change host only under a verified, maintainer-directed migration.
- Cross-check a large distfile's size against its source, so a truncated download cannot produce a plausible but invalid `Manifest`.
- When upstream moves, update `HOMEPAGE`, `metadata.xml` `remote-id`, and version-tracking URLs to the current project. Keep `SRC_URI` on the real artifact and provenance variables on the repository that produced that release.
- For an in-place tarball replacement, verify provenance, contents, tag or commit, signatures, and licenses. Use a distinct distfile name and revbump.
- A backport records its upstream commit, PR, or bug URL and applicable and tested versions.
- A security fix covers every still-keyworded vulnerable branch and relevant sibling or fork. Revbump when installed content or behavior changes.
- Follow the package's own consistent history, not a single recent commit: overlay packages variously roll the latest (`add X, drop Y`), keep everything, or keep an anchor and roll the rest. Reproduce the established pattern.
- When that pattern is mixed, conflicts with the current tree, or the package has no bump history, default to add-only and flag the choice for the maintainer. If an old version loses its immutable source bytes or a replacement is unexplained, stop for direction.
- For a major version jump, large rewrite, or build-system migration, add only—keep the prior version rather than dropping it, even when history rolls latest and even for a `-bin` package. The proven old version is the fallback until the new one is exercised.
- Before dropping, search the overlay and main tree for reverse-dependency pins and verify per `SLOT` that survivors resolve on every retained arch; keep any old version still needed.
- Remove or update only state made obsolete when a version, implementation, USE flag, provider, or package name is removed.
- Scope cleanup to affected ebuild conditionals, assets, metadata and profile entries, reverse-dependency references, and live or twin variants. Preserve everything required by surviving ebuilds or providers.
- A package move updates `profiles/updates` atomically with every affected reference.

## Dependencies and Revisions

- Revbump when a Gentoo-side change can alter an existing installation or runtime dependency decision. This includes installed output or behavior, runtime dependencies, subslot binding, and default USE changes.
- Also revbump for an affected non-free or soon-to-be-removed license and for a non-trivial EAPI change.
- Skip the revbump when a descriptive, copyright, keyword, message, test, build-failure, or build-dependency-relaxation change cannot leave an installed result wrong.
- In EAPI 8+, put host tools that must execute while the package is merged, such as post-install cache generators, in `IDEPEND`.
- For a verified direct ABI consumer, put `:=` or `:slot=` on every `DEPEND` or `RDEPEND` atom that models that linkage. Never copy it to transitive dependencies.
- Identical prebuilt bytes cannot adapt to a new ABI. Constrain verified provider slots or versions instead of assuming a reinstall fixes them.
- Built slot operators are invalid in `PDEPEND` and must stay outside `|| ( )`. Inside an any-of group, list only supported providers, preferred first.
- Before adding or retaining any dependency or alternative provider, check removal entries in both this overlay's and the main Gentoo tree's `profiles/package.mask`.
- When a package is removed or renamed, update dependency atoms plus `elog` and `optfeature` recommendation strings.
- A provider subslot represents an ABI that requires consumer rebuilds. Re-check SONAMEs, private-header ABI, and library renames on every bump.
- Never derive a sibling package version from `${PV}` without verifying that it exists and resolves.
- Never replace a `files/` input still referenced by a surviving ebuild; give its replacement a version- or revision-specific name.

## Bundled and Prebuilt Binaries

- For each upstream binary artifact, whitelist only shipped arches (for example `KEYWORDS="-* ~amd64 ~arm64"`) and use per-arch `SRC_URI`. Do not keyword or reference unpublished artifacts.
- Set `RESTRICT` from verified stripping and redistribution needs; `strip` and `splitdebug` are distinct.
- `QA_PREBUILT` suppresses broad checks, including DT_NEEDED, executable-stack, textrel/W+X, flags, pre-stripped files, and SONAME.
- Use `QA_PREBUILT` only for manually reviewed, immutable upstream blobs, scoped to exact installed paths. `RESTRICT=strip`, not `QA_PREBUILT`, prevents stripping.
- Audit every installed object: ELF class and machine, interpreter, `NEEDED`, SONAME, RPATH, installed path, required libc/libstdc++ symbol floors, and CPU ISA baseline.
- Smoke-test amd64. If upstream ships an `arm64` artifact for the same release, add `~arm64` untested; record the unverified arch in the completion report and fix arch-specific problems on report. Depend only on what blobs actually link or invoke.
- An unresolved `NEEDED` entry is a runtime defect even when QA is suppressed. Resolve it through a verified bundled layout or genuine system `RDEPEND`; never suppress it.
- A private module may legitimately lack SONAME, but every unusual RPATH needs object-specific justification.
- For source-built objects, fix the build, link, and install system first. Use `patchelf` only as an evidence-backed fallback and add it to `BDEPEND`.
- A retained private blob may use a verified literal `'$ORIGIN/...'` RPATH.
- Replace a bundled component with a system one only after verifying ABI, functionality, and launcher or configuration integration; otherwise stop.

## New Packages

- Before drafting, search this overlay and the main tree for the same project, former names, forks, and truly comparable packages. Identify its fixed source artifact, license, build system, runtime files, and tested arches.
- Update `.github/workflows/overlay.toml` in the same PR for a new package tied to an independent upstream project.
- Add an active version-check table when releases are trackable, otherwise a commented `#["category/package"]` block giving the reason (live-only, synced elsewhere, or a duplicate source/binary package).
- Packages with no independent upstream version (`virtual/*`, `acct-*`, meta) need no entry.
- Add `files/` assets only when phases cannot generate them cleanly.
- Stop when licensing or redistribution is unclear, downloads require credentials or click-through terms, naming or category is ambiguous, or substantial patching or vendoring needs a maintainer decision.

## Eclass Discovery

- Prefer the local main tree at `/var/db/repos/gentoo` when present.
- Before inheriting, read each eclass's supported EAPIs, deprecation status, pre-inherit and call-time variables, exports, phases, and defaults.
- On an EAPI bump, re-audit the whole ebuild, including disabled USE branches, generated dependencies, dead helpers, and changed eclass defaults.
- Define phase composition explicitly when eclasses export the same phase. An override calls the eclass implementation when its documented behavior must remain; `default` invokes the EAPI default, not an eclass-exported phase.
- Do not inherit an eclass for one helper when clear phase code and current precedent agree.

## Commands and QA

- Run `pkgdev manifest` when distfiles change; pass `--distdir <writable-dir>` if the system `DISTDIR` is not user-writable. Iterate with the narrowest relevant package checks and re-run the command exposing each failure.
- Before the PR, complete required clean installs, then scope the commit scan to this branch with an explicit merge-base range (a bare `--commits` compares against the fork's lagging `origin` and drags in unrelated packages):

  ```bash
  pkgcheck scan --git-remote <canonical> --commits="$(git merge-base <canonical>/master HEAD)..HEAD" --net
  ```

- The range selects the targets; `--git-remote` sets the canonical source for the commit-only checks. If cross-package noise still remains, confirm your own change with a package-scoped `pkgcheck scan <category>/<package> --net`, which is ground truth but does not replace the commit scan.
- Exercise every USE state affected by the change. Run upstream tests with `FEATURES=test` where available.
- Tests use the build tree, not an installed or system copy. Gate and declare test-only inputs, dependencies, and resources.
- Preserve the largest reliable subset and skip individual failures with reasons. Use `RESTRICT=test` only after proving no reliable subset can be retained, and record why.
- Use conditional `PROPERTIES="test? ( test_network )"` only with `IUSE=test`; otherwise use `PROPERTIES="test_network"`.
- Fix genuine QA defects at the root cause. Retain only a documented false positive or unavoidable notice, with its rationale and remaining risk; never rewrite working behavior merely to silence a checker.
- GitHub rate limits can cause false `DeadUrl` or `RedirectedUrl` results; re-verify flagged URLs.
- A dead `HOMEPAGE` does not block installation. A dead overlay `SRC_URI` is unfetchable because overlay distfiles are not mirrored on `distfiles.gentoo.org`.
- Review the staged diff and diffstat. Reject unrelated hunks, debug output, missing `files/` assets, or unintended `Manifest` entries.
- Verify patches, substitutions, generators, and manual or glob installs against the intended release source and final files, modes, and license notices—not command exit status alone.
- Stop after at most three attempts, or after the same failure repeats twice. Report the failed phase and attempts before asking how to continue.

## Completion Report

Every completed change reports the topic branch, canonical remote and fetch status, base and sync status, files changed, commands with pass/fail results, skipped checks and reasons, and remaining warnings, risks, or limitations.

## Repository Layout

Packages live under `category/package/` with ebuilds, `metadata.xml`, optional `Manifest`, and optional `files/`. Repository metadata is under `metadata/`, `profiles/`, and `repo.xml`; CI is under `.github/`.
