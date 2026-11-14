# Repository Guidelines

This Gentoo overlay fork keeps repository policy and non-obvious gates here; skills and official Gentoo sources cover generic packaging knowledge.
Reload this file at each work item and after long or trimmed context.
Explicit human instructions override these defaults for that item; carry them out and record the deviation.

## Task routing

Read this file, then `git-workflow.md` before editing. For ebuilds, read `ebuild-construction.md` and `dependencies.md`, then `version-bumps.md` or `new-packages.md`, then each affected surface below. Read `qa.md` before scanning and `pr-text.md` before committing. Rule files start with `Read with:` links.

- Ebuild edits: `.agents/rules/ebuild-construction.md`.
- Atoms, slots, subslots, revbumps: `.agents/rules/dependencies.md`.
- Manifest, scans, tests, QA, network, review: `.agents/rules/qa.md`.
- Bumps and retention: `.agents/rules/version-bumps.md`.
- New packages, virtuals, `overlay.toml`: `.agents/rules/new-packages.md`.
- Bundled or prebuilt binaries: `.agents/rules/prebuilt-binaries.md`.
- Desktop files, icons, Wayland: `.agents/rules/desktop-integration.md`.
- Units, init scripts, service dependencies: `.agents/rules/openrc-systemd.md`.
- `sys-kernel/*-sources`, `*-kernel`, `*-kernel-bin`, `virtual/dist-kernel-*`: `.agents/rules/kernels.md`.
- Eclasses and EAPI: `.agents/rules/eclass-discovery.md`.
- Preflight, remotes, rebasing, pushing: `.agents/rules/git-workflow.md`.
- Commit and PR text, writing: `.agents/rules/pr-text.md`.

Runnable steps and checks for bumps, new packages and reviews: the `gentoo-zh` skill from https://github.com/gentoo-zh/skills (`npx skills add gentoo-zh/skills -g`). It applies these rules and adds none. When it is not installed, read `.agents/skills/gentoo-zh/references/checks.md` from that repository before the first edit and run the sections your change touches.

## Git Workflow

Repository edits are PR-bound unless explicitly exempted; read-only inspection is exempt. Complete `.agents/rules/git-workflow.md` preflight before editing.

- One bump or fix per PR. Packages share a PR only for a dependency chain, coordinated bump, or spanning fix; a batch of unrelated bumps never does.
- Never split an ebuild from its `Manifest`; keep them together.
- Never overwrite, revert, stage, or commit unrelated changes; preserve them.
- Never push `master` or the canonical remote; publish topic branches to an unambiguous personal fork.

## Ebuild Policy

- Install every changed ebuild cleanly before the PR; compilation and CI alone are insufficient. If a real merge is unavailable, record the skip and reason. Apply `.agents/rules/qa.md` for elog attribution and CI coverage.
- Never keyword a source arch you did not build; build each newly added arch. Prebuilt arm64 follows `.agents/rules/prebuilt-binaries.md`.
- Retain inherited keywords. For arch-independent packages use `~arch` and report unverified arches.
- An arch removal updates affected reverse dependencies and virtual/meta packages together. Virtual keywords stay within their providers' keywords; `pkgcheck PotentialStable` is informational. Every atom resolves on each keyworded arch through a package keyworded there; fix `DependencyMissingKeywords` by dropping that arch from the reverse dependency.
- Before a fix, search `::gentoo` and this overlay for precedent and use its form; explain constructs absent from both. For non-trivial work, match source/prebuilt model, build system, eclasses, and runtime layout, then verify against the release.

## Stopping

Stop only at a stated gate here or in `.agents/rules/`, or before discarding work or publishing unreviewed work. Stop after three attempts at most or two repetitions of the same failure; report the phase and attempts before asking how to continue.

## Completion Report

Report topic branch; canonical remote and fetch status; base and sync status; changed files; commands and pass/fail results; skipped checks and reasons; remaining warnings, risks, and limitations.
