# Repository Guidelines

This repository is a Gentoo overlay fork. Prefer generic Gentoo ebuild workflow knowledge from skills or official Gentoo documentation, and keep repository-specific policy here.

## Repository Layout

- Packages live under `category/package/`.
- Each package directory normally contains ebuilds, `metadata.xml`, optional `Manifest`, optional files under `files/`.
- Repository metadata lives under `metadata/`, `profiles/`, `repo.xml`, and CI config under `.github/`.

## Git Workflow

- Before starting package work, ensure an `upstream` remote exists for the upstream overlay.
- If `upstream` is missing, add it with:

  ```bash
  git remote add upstream git@github.com:Gentoo-zh/overlay.git
  git fetch upstream
  ```

- If `upstream` already exists but points elsewhere, do not silently rewrite it; report the current URL and confirm before changing it.
- Treat `master` as the upstream-sync branch. Do not make feature work directly on `master`.
- Use one topic branch per logical pull request.
- Branch package work from a freshly synced `master`; for version bumps, prefer names like `category-package-version`.
- A pull request may touch multiple packages only when they are part of one logical contribution, such as one dependency chain, one coordinated version bump, or one shared fix.
- Keep unrelated package changes in separate branches and PRs.
- Never split an ebuild change and its `Manifest` update across separate PRs.
- When rebasing an open PR, prefer `git rebase upstream/master` and push with `--force-with-lease`.

## Ebuild Policy

- Do not break people's systems.
- Every ebuild change must avoid compile-time errors before commit.
- Test ebuilds for every `KEYWORDS` arch claimed. If an arch was not tested, do not claim support for it.
- Use unstable keywords only, such as `~amd64`; do not add stable keywords.
- Preserve existing package style unless a change is needed for correctness or QA.
- Avoid broad refactors while doing package maintenance.
- For new packages, inspect similar packages in this overlay and in the main Gentoo tree before drafting.
- Do not choose eclasses from memory alone. Prefer local Gentoo tree evidence first, then official Gentoo documentation or gentoo.git when local evidence is missing or ambiguous.
- Use package-local and ecosystem-local precedent before generic templates.
- Keep live `9999` ebuild behavior separate from release ebuild behavior.
- Do not invent licenses. Verify upstream license files and Gentoo license names.
- For bundled binaries, verify architecture, redistribution constraints, install paths, and whether QA exceptions are needed.

## New Packages

- Before drafting a new package, identify category/package name, upstream URL, release version, source archive, license, build system, runtime files, and expected tested arches.
- Search for existing package names, forks, renamed projects, and same upstream in this overlay and the main Gentoo tree.
- Run eclass discovery before writing the ebuild, and keep a short decision record when the choice is non-obvious.
- Add files under `files/` only when patches, init scripts, service files, wrappers, or desktop integration cannot be generated cleanly in ebuild phases.
- Stop and ask before proceeding when license or redistribution rights are unclear, the package requires credentials or click-through downloads, the package name/category is ambiguous, or major patching/vendoring decisions are needed.

## Version Bumps

- Before bumping, read existing ebuilds and package history.
- Normalize upstream version strings according to Gentoo version rules, such as `v1.2.3` to `1.2.3` and `rc`/`beta`/`pre` to `_rc`/`_beta`/`_pre`.
- Compare upstream release notes, build files, dependency changes, and license changes.
- Check whether patches, files, services, wrappers, desktop assets, and source archive layout still apply.
- Add new ebuilds and update `SRC_URI`, checksums, and version-specific variables together.
- Drop old versions only when requested or when repository policy makes it appropriate; preserve old revisions when they are still needed for compatibility.
- For routine version bumps, default to add-only; dropping old versions is a separate decision.

## Eclass Discovery

- Prefer `/var/db/repos/gentoo` as the local main Gentoo tree when present.
- Inspect candidate eclasses directly under `eclass/*.eclass` before relying on phase behavior.
- Read eclass comments, exported functions, and relevant variables before using them.
- Use official Gentoo sources when local data is absent or ambiguous: Gentoo devmanual, Gentoo eclass reference, gentoo.git package examples, and gentoo.git eclass files.
- Do not inherit an eclass only for one helper when simple phase code is clearer and established local precedent agrees.
- Prefer modern eclasses used by current Gentoo packages over old compatibility eclasses.

## Commands

- Regenerate manifests with `pkgdev manifest` for affected packages when distfiles change.
- Run narrower package-level QA commands while iterating, then broader commit-level commands before PR.
- Before opening a PR, run:

  ```bash
  pkgcheck scan --commits --net
  ```

- Commit with `pkgdev commit --scan false --signoff --gpg-sign` by default.
- If GPG signing is unavailable in the current environment, fall back to `pkgdev commit --scan false --signoff`.

## QA

- Fix root causes, not only warnings.
- Do not silence QA unless the package type genuinely requires it.
- If adding QA exceptions, explain why they are correct for this package.
- Re-run the command that exposed a QA problem after each fix.
- When a warning is intentionally left, include the rationale and risk.
- Final reports must include commands run, pass/fail result, checks skipped and why, and any remaining warnings or known limitations.
- Retry at most three times. If the same error repeats twice for the same package, stop, report the failed phase and attempts, and ask before continuing.

## Commit Messages

- Prefer `pkgdev commit` over raw `git commit` so package commit subjects are generated consistently.
- Do not include AI-generated signatures or attribution in commits, including `Co-Authored-By` or generated-by lines.
- Non-version-bump commits:

  ```text
  category/package: short description

  Longer explanation when useful.
  Reference related bugs or issues when relevant.
  ```

- Version bump commits:

  ```text
  category/package: add new_version, drop old_version
  ```

## Pull Requests

- Fill the PR description with the reason for the change and notable testing.
- Check the PR template box only after `pkgcheck scan --commits --net` has been run.
- Keep generated or mechanical churn out of the PR unless it is directly required by the package change.
