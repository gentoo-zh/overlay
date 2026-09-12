# Repository Guidelines

Reload this file at the start of a work item, and again whenever the conversation has grown long or context was trimmed, so its rules stay in force.

This repository is a Gentoo overlay fork. Use skills and official Gentoo sources for generic ebuild knowledge; keep repository policy and non-obvious correctness gates here.

These rules are the default, not a veto. An explicit instruction from the human directing the work overrides them for that item: carry it out and record the deviation.

Stop only where this file says to, or where continuing would discard work or publish something unreviewed.

Prefer the package and its history, a genuinely comparable current package, eclass and upstream source, then official Gentoo documentation and gentoo.git.

Never substitute memory or superficial similarity for evidence.

## Repository Layout

Packages live under `category/package/` with ebuilds, `metadata.xml`, optional `Manifest`, and optional `files/`.

Repository metadata is under `metadata/` and `profiles/`. CI is under `.github/`.

## Task routing

Read a rule file before touching the surface it names. These files carry repository policy that used to sit in this one.

- Version bumps and keeping old versions: `.agents/rules/version-bumps.md`.
- New packages, `virtual/`, `overlay.toml` entries: `.agents/rules/new-packages.md`.
- Prebuilt or bundled binaries: `.agents/rules/prebuilt-binaries.md`.
- Desktop files, icons, Wayland flags: `.agents/rules/desktop-integration.md`.
- Units, init scripts, service or `systemd` dependencies: `.agents/rules/openrc-systemd.md`.
- Choosing or reading an eclass: `.agents/rules/eclass-discovery.md`.
- Commit subject and body, PR title and body: `.agents/rules/pr-text.md`.

## Git Workflow

Every repository modification is PR-bound unless the current request explicitly says otherwise. Read-only inspection is exempt.

Complete preflight before the first edit, and repeat it only if the state is no longer known.

Treat `master` only as an upstream-sync branch.

- Start with `git status --short --branch`.
- Use one topic branch per logical PR. Create new work from local `master` freshly synced with `<canonical>/master`; prefer `category-package-version` for bumps.
- When resuming, reuse the correct topic branch.
- Before preparing a PR, fetch the canonical remote and rebase the topic branch onto `<canonical>/master`. A stale base makes GitHub report the PR out of date.
- Re-fetch the canonical remote before stating that a commit or PR is merged, and before basing follow-up work on it. A stale ref reports the opposite.
- Compare and open against `<canonical>/master`, never the personal fork's `master`. The fork lags and inflates the diff with unrelated commits.
- One bump or one fix is one PR.
- Packages share a PR only when they must land together: one dependency chain, a coordinated bump, or a fix that spans them. A batch of unrelated bumps never does.
- Never split an ebuild from its `Manifest`.
- When fresh state is needed, find an existing remote for one of these, matching the GitHub owner and repository case-insensitively.

  ```text
  git@github.com:gentoo-zh/overlay.git
  https://github.com/gentoo-zh/overlay.git
  git@github.com:microcai/gentoo-zh.git
  https://github.com/microcai/gentoo-zh.git
  ```

- Support both fork clones (`origin` is personal) and direct clones (`origin` is canonical). Use the existing canonical remote, whatever its name is.
- If neither remote exists, add `upstream` as `https://github.com/gentoo-zh/overlay.git`.
- Fetch the canonical remote before using its state, and ensure `<canonical>/HEAD` resolves; run `git remote set-head <canonical> master` if it does not.
- pkgcheck's git checks depend on that head independently of any explicit commit range.
- If the fetch fails, stop and report the current URL and error; do not rewrite or bypass it.
- Push only topic branches to an unambiguous personal fork, never `master` or the canonical remote. Use `--force-with-lease` after a rebase.
- A missing or ambiguous personal fork blocks publishing, not local editing.
- Preserve unrelated changes; never overwrite, revert, stage, or commit them.
- For non-ebuild changes, check `.github/workflows/emerge-on-pr.yml` `ignore_list` so paths are not interpreted as package atoms.
- Stop before editing if any of these holds:

  - The canonical remote is ambiguous.
  - A required `master` sync fails.
  - A branch cannot be created safely.
  - Unrelated changes make staging ambiguous.
  - The request spans unrelated PRs.

## Ebuild Policy

- Install every changed ebuild cleanly; a compile alone is insufficient. emerge-on-PR discards the elog its `--onlydeps` pass leaves, then fails on any `qa`, `warn`, or `error` elog from the emerge of the package itself, including a dependency that step happens to build.
- Where the environment cannot run a real merge, such as an unprivileged sandbox that cannot chown to the portage group, record the install as skipped.
- An elog from the dependency rather than the package is not a defect in the change. Report it; do not edit the ebuild to clear it.
- The emerge-on-PR CI installs the changed packages after each push: on both amd64 profiles, openrc and systemd, and on the arm64 systemd profile when the package is keyworded arm64. There is no arm64 openrc run, every other arch stays unverified, and a green run does not replace your own clean install.
- Build every newly added `KEYWORDS` arch of a source package; never keyword one you did not build. A prebuilt package follows the arm64 exception in `.agents/rules/prebuilt-binaries.md`.
- Carrying the prior version's keywords forward is retention—do not narrow them to the one arch you built.
- For an arch-independent package, keep the inherited keywords and note the arches you did not verify in the completion report; use `~arch`.
- When removing an arch, update affected reverse dependencies and virtual/meta packages in the same change.
- A virtual's keywords cannot exceed its providers'. `pkgcheck PotentialStable` is informational.
- Preserve package-local style and user/toolchain flags. Keep patches and refactors narrow; remove forced optimization, hardening, LTO, stripping, and blanket `-Werror`.
- For non-trivial work, use precedent matching the source or prebuilt model, build system, eclass stack, and runtime layout. Re-verify it against the current release.
- Before writing the fix, find how `::gentoo` or this overlay already solves the same problem and take that form. A construct with no precedent in either tree needs a stated reason.
- Search for that precedent instead of recalling it: `grep -rl '<eclass or construct>' "$(portageq get_repo_path / gentoo)" --include='*.ebuild'` shows who uses it today, and `git log -S'<construct>' -- '*.ebuild'` in gentoo.git shows why the tree adopted or dropped it.
- Keep release and `9999` behavior distinct. Port applicable dependency, QA, EAPI, and phase fixes to the live ebuild.
- A live ebuild must sort above every release the package has. `9999` is lower than a date version, so a package versioned `20240203` needs `99999999`; confirm with `python3 -c 'from portage.versions import vercmp; print(vercmp("9999", "20240203"))'` before naming the file.
- Every `${FILESDIR}` reference must name a committed file.
- If `PATCHES` coexists with a custom `src_prepare`, call `default` or apply the patches explicitly. `eapply_user` alone does not apply `PATCHES`.
- Keep global scope metadata-invariant and side-effect-free. Do not run external programs, emit uncaptured output, modify system state, or depend on system, profile, repository, or phase data.
- Do not use pipes, process substitution, heredocs, or herestrings there. Bash may back the latter two with temporary files that the metadata sandbox forbids.
- Deterministic package-manager helpers and pure shell expansion are valid in global scope. Put work requiring declared build context in phases.
- Declare external build and test inputs through `SRC_URI`/`Manifest` or an eclass vendor mechanism. Enforce offline operation without warm caches.
- Each USE state must control every applicable option, dependency, source selection, and install cleanup consistently. Disable automagic.
- When a package adds, removes, or renames a local USE flag, update its `metadata.xml` flag description in the same change.
- Prune only what `src_install` would otherwise install. Deleting a path it never reaches is dead code, as is a branch that only removes files that USE state does not install.
- `${ED}` already carries the offset; never append `${EPREFIX}` to it. `${D}` does not carry it. Use a bare `${EPREFIX}` only in installed content read at runtime, and only where that consumer runs under Prefix.
- Verify package and bundled-component licenses, Gentoo license names, and redistribution terms; they determine `RESTRICT=mirror` or `bindist`.
- A license absent from `::gentoo` needs its full text in `licenses/` and `RESTRICT` set from its own distribution terms. One that forbids redistribution sets both `mirror`, which covers the distfile, and `bindist`, which covers what is built from it. Add it to `profiles/license_groups` when it belongs to one of those groups; a license that fits none stays ungrouped.
- A backport records its upstream commit, PR, or bug URL and applicable and tested versions.
- A security fix covers every still-keyworded vulnerable branch and relevant sibling or fork. Revbump when installed content or behavior changes.
- A package move updates `profiles/updates` atomically with every affected reference.

## Dependencies and Revisions

- Every atom traces to evidence here: a linked SONAME, a build-file `dependency()`, `find_package`, or `pkg-config` call, a `dlopen`ed library, or a program a phase runs.
- A launcher or `bwrap` script's external commands outside `@system` count as that evidence: find each command's provider with `qfile` on an installed system or by searching the repository. `xdg-user-dir` belongs to `x11-misc/xdg-user-dirs`, not `x11-misc/xdg-utils`.
- Another distro's control file is not evidence.
- Do not declare what the environment provides: `@system` members, tools an inherited eclass pulls in, or a compiler or libc floor the profile guarantees.
- One atom per package: fold the version bound, `SLOT`, and USE constraints into a single entry.
- Carry the build system's own version floors into the atom, and do not invent floors it does not state. Add an upper bound only for a verified incompatibility with no available fix.
- Before adding a slot operator (`:=` or `:slot=`), check that the provider declares a subslot. Without one it binds `slot/slot`, so consumers rebuild when the slot changes but never on an ABI break inside it.
- Revbump when a Gentoo-side change can alter an existing installation or runtime dependency decision.
- That includes installed output or behavior, runtime dependencies, subslot binding, and default USE changes.
- Also revbump for an affected non-free or soon-to-be-removed license and for a non-trivial EAPI change.
- Skip the revbump when a descriptive, copyright, keyword, message, test, build-failure, or build-dependency-relaxation change cannot leave an installed result wrong.
- In EAPI 8+, put host tools that must execute while the package is merged, such as post-install cache generators, in `IDEPEND`.
- For a verified direct ABI consumer, put `:=` or `:slot=` on every `DEPEND` or `RDEPEND` atom that models that linkage. Never copy it to transitive dependencies.
- Identical prebuilt bytes cannot adapt to a new ABI. Constrain verified provider slots or versions instead of assuming a reinstall fixes them.
- `:=` and `:slot=` are invalid in `PDEPEND` and must stay outside `|| ( )`. Inside an any-of group, list only supported providers, preferred first.
- Before adding or retaining any dependency or alternative provider, check removal entries in both this overlay's and the main Gentoo tree's `profiles/package.mask`.
- When a package is removed or renamed, update dependency atoms plus `elog` and `optfeature` recommendation strings.
- A provider subslot represents an ABI that requires consumer rebuilds. Re-check SONAMEs, private-header ABI, and library renames on every bump.
- Never derive a sibling package version from `${PV}` without verifying that it exists and resolves.
- Never replace a `files/` input still referenced by a surviving ebuild; give its replacement a version- or revision-specific name.

## Code Style

- Keep code concise. Prefer clear naming, established helpers, direct control flow, and simple structure over explanatory comments or complex shell code.
- Implement logic near the relevant code rather than adding a separate script. Use functions only when they materially reduce local complexity or duplication.
- Keep comments only when they explain non-obvious intent, constraints, trade-offs, or workarounds that the code cannot express and a future maintainer needs to preserve.
- Do not add comments that restate eclass-documented variable assignments, configuration, declarations, option values, function calls, commands, or standard settings.
- Do not add comments to justify QA suppressions, including `QA_PREBUILT` and `QA_SONAME`.
- Preserve existing useful comments unless they are outdated or incorrect.

## Commands and QA

- `dev-util/pkgdev` and `dev-util/pkgcheck` are required. When either is missing, stop and tell the human to `emerge` them; do not substitute `git commit`, hand-written Manifests, or a custom lint. `dev-util/github-cli` is optional: without `gh`, hand the human the compare link and let them open the PR.
- Before treating a finding as yours, read the package's history, the previous version's result, and the pkgcheck bot's report on the PR. A finding that predates your change is pre-existing, and the completion report says so.
- `ebuild <file> install` resolves no dependencies, so it cannot show a missing `BDEPEND`. A `fowners` to an `acct-user` in `src_install` needs that package in `BDEPEND` and in `RDEPEND`, as `acct-user.eclass` documents.
- Iterate with the narrowest relevant package checks, and re-run the command exposing each failure.
- Do not repeat a check that already passed on the same tree: no rebuilding what already built clean, no rerunning a scan that already passed. A rebase or a new commit makes a previous commit scan stale, and this never excuses a gate the Ebuild Policy requires.

### Manifest

- Run `pkgdev manifest` when distfiles change. Pass `--distdir <writable-dir>` if the system `DISTDIR` is not user-writable.
- Before the first download of a package payload in a work item, whether a distfile, a vendor bundle, or a release asset, report the URL and the size upstream states, and wait for approval.

### Scanning

- Before the PR, complete required clean installs.
- After those installs pass, scope the commit scan to this branch with an explicit merge-base range. A bare `--commits` compares against whatever `origin` points at, which need not be the base you branched from.

  ```bash
  pkgcheck scan --git-remote <canonical> --commits="$(git merge-base <canonical>/master HEAD)..HEAD" --net
  ```

- The range selects the targets. `--git-remote` sets the canonical source for the commit-only checks.
- If cross-package noise still remains, confirm your own change with a package-scoped `pkgcheck scan <category>/<package> --net`. That is ground truth, but does not replace the commit scan.

### Tests

- Exercise every USE state affected by the change. Run upstream tests with `FEATURES=test` where available.
- Tests use the build tree, not an installed or system copy. Gate and declare test-only inputs, dependencies, and resources.
- Preserve the largest reliable subset and skip individual failures with reasons. Use `RESTRICT=test` only after proving no reliable subset can be retained, and record why.
- Use conditional `PROPERTIES="test? ( test_network )"` only with `IUSE=test`; otherwise use `PROPERTIES="test_network"`.

### QA notices

- The pkgcheck bot's report on the PR names the commit and packages it scanned and the status; read it instead of guessing what CI saw.
- Fix genuine QA defects at the root cause.
- Retain only a documented false positive or unavoidable notice, with its rationale and remaining risk.
- Never rewrite working behavior merely to silence a checker.

### Network results

- GitHub rate limits can cause false `DeadUrl` or `RedirectedUrl` results; re-verify flagged URLs.
- A network result is evidence about your host only. An edge that returns 403 here may serve the same URL elsewhere, so re-check from a second vantage point, such as another mirror or a fetch through a different route, before calling a URL dead.
- CI's `pkgcheck` runs without `--net`, so no network keyword fires there.
- A dead `HOMEPAGE` does not block installation. A dead overlay `SRC_URI` is unfetchable because overlay distfiles are not mirrored on `distfiles.gentoo.org`.

### Reviewing the change

- Review the staged diff and diffstat. Reject unrelated hunks, debug output, missing `files/` assets, or unintended `Manifest` entries.
- Verify patches, substitutions, generators, and manual or glob installs against the intended release source and final files, modes, and license notices—not command exit status alone.

### Stopping

- Stop after at most three attempts, or after the same failure repeats twice. Report the failed phase and attempts before asking how to continue.

## Writing

Use one standard for commit messages, PRs, comments, notes, and replies: precise, plain, and short.

- Name concrete variables, phases, USE flags, `FEATURES`, eclasses, and commands, not a vague paraphrase or adjective. Use current Gentoo terminology.
- Avoid colloquial wording, needless language mixing, unsupported absolutes, marketing, and filler.
- Name a thing by its ecosystem's term or concrete behavior, never an ad-hoc coinage.
- State a reason as an explicit because/so (因为…所以…) cause and effect. Never a vague linker like "correspondingly"/相应.
- A reason is not a restatement of `name = value` metadata.
- Chinese may use Traditional or Simplified characters. Use standard Mandarin wording readily understood across regions; avoid region-specific terms.
- Do not set off Chinese words with full-width brackets (`「」`, `『』`); state the term plainly and use backticks only for code and literal values.
- Write each language natively: professional but plainly worded, fluent, and causal. Stilted phrasing usually comes from translating the other language word for word—avoid it.

| Reads naturally | Does not |
| --- | --- |
| 原生可执行文件移到各平台子包 | 拆成薄 loader |
| 因为上游变更了 Go 模块路径，所以 `-ldflags` 中的导入路径需同步更新，否则注入的版本号不正确 | module 改名，相应更新 ldflags |

## Completion Report

Every completed change reports:

- the topic branch, the canonical remote and its fetch status, and the base and sync status;
- files changed;
- commands with pass/fail results;
- skipped checks and reasons;
- remaining warnings, risks, or limitations.
