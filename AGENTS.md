# Repository Guidelines

Reload this file at the start of a work item, and again whenever the conversation has grown long or context was trimmed, so its rules stay in force.

This repository is a Gentoo overlay fork. Use skills and official Gentoo sources for generic ebuild knowledge; keep repository policy and non-obvious correctness gates here.

These rules are the default, not a veto. An explicit instruction from the human directing the work overrides them for that item: carry it out and record the deviation.

Stop only where this file or `.agents/rules/` says to, or where continuing would discard work or publish something unreviewed.

Prefer the package and its history, a genuinely comparable current package, eclass and upstream source, then official Gentoo documentation and gentoo.git.

Never substitute memory or superficial similarity for evidence.

## Repository Layout

Packages live under `category/package/` with ebuilds, `metadata.xml`, optional `Manifest`, and optional `files/`.

Repository metadata is under `metadata/` and `profiles/`. CI is under `.github/`.

## Task routing

Reading order: this file; then `git-workflow.md` before the first edit; for any ebuild change `ebuild-construction.md` and `dependencies.md`; then `version-bumps.md` or `new-packages.md` for the change itself; then every surface file the change touches; then `qa.md` before scanning and `pr-text.md` before committing. Each rule file opens with a `Read with` line naming what to read next from there. These files carry repository policy that used to sit in this one.

- Writing or editing an ebuild: `.agents/rules/ebuild-construction.md`.
- Dependency atoms, slots, subslots, revbumps: `.agents/rules/dependencies.md`.
- Manifest, scanning, tests, QA notices, network results, reviewing: `.agents/rules/qa.md`.
- Version bumps and keeping old versions: `.agents/rules/version-bumps.md`.
- New packages, `virtual/`, `overlay.toml` entries: `.agents/rules/new-packages.md`.
- Prebuilt or bundled binaries: `.agents/rules/prebuilt-binaries.md`.
- Desktop files, icons, Wayland flags: `.agents/rules/desktop-integration.md`.
- Units, init scripts, service or `systemd` dependencies: `.agents/rules/openrc-systemd.md`.
- Kernel packages (`sys-kernel/*-sources`, `*-kernel`, `*-kernel-bin`, `virtual/dist-kernel-*`): `.agents/rules/kernels.md`.
- Choosing or reading an eclass: `.agents/rules/eclass-discovery.md`.
- Branch preflight, remotes, rebasing, pushing: `.agents/rules/git-workflow.md`.
- Commit subject and body, PR title and body, and writing style: `.agents/rules/pr-text.md`.

Runnable steps and checks for bumps, new packages and reviews: the `gentoo-zh` skill from https://github.com/gentoo-zh/skills (`npx skills add gentoo-zh/skills -g`). It applies these rules and adds none. When it is not installed, read `.agents/skills/gentoo-zh/references/checks.md` from that repository before the first edit and run the sections your change touches.

## Git Workflow

Every repository modification is PR-bound unless the current request explicitly says otherwise. Read-only inspection is exempt. Before the first edit, complete the preflight in `.agents/rules/git-workflow.md`, which also covers remotes, rebasing, and pushing.

- One bump or one fix is one PR.
- Packages share a PR only when they must land together: one dependency chain, a coordinated bump, or a fix that spans them. A batch of unrelated bumps never does.
- Never split an ebuild from its `Manifest`.
- Preserve unrelated changes; never overwrite, revert, stage, or commit them.

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

## Stopping

- Stop after at most three attempts, or after the same failure repeats twice. Report the failed phase and attempts before asking how to continue.

## Completion Report

Every completed change reports:

- the topic branch, the canonical remote and its fetch status, and the base and sync status;
- files changed;
- commands with pass/fail results;
- skipped checks and reasons;
- remaining warnings, risks, or limitations.
