# Repository Guidelines

This repository is a Gentoo overlay fork. Prefer generic Gentoo ebuild workflow knowledge from skills or official Gentoo documentation, and keep repository-specific policy here.

## Repository Layout

- Packages live under `category/package/`.
- Each package directory normally contains ebuilds, `metadata.xml`, optional `Manifest`, optional files under `files/`.
- Repository metadata lives under `metadata/`, `profiles/`, `repo.xml`, and CI config under `.github/`.

## Git Workflow

- Every repository modification is PR-bound work unless the user explicitly says otherwise in the current request. This applies to ebuilds, manifests, metadata, documentation, CI files, and README-only changes.
- Automated agents, AI assistants, scripts operating on behalf of a maintainer, and human maintainers using automation must complete the mandatory PR preflight before starting PR-bound editing work.
- Human-only exploratory inspection may read files without this preflight, but tracked file edits must happen only after the relevant preflight has been completed for the current work item.
- Treat `master` as the upstream-sync branch only. Never make feature, package, documentation, CI, or metadata changes directly on `master`.

### Mandatory PR Preflight

- At the start of a PR-bound work item, make sure the current branch and worktree state are known. When a git query is needed, prefer `git status --short --branch`, which reports both. Do not repeat this before every individual file edit when the state is already known in the current task.
- When fresh upstream state is needed, such as syncing `master`, creating a topic branch from `master`, rebasing an existing topic branch, or preparing a PR, identify the canonical remote for `git@github.com:gentoo-zh/overlay.git` or `https://github.com/gentoo-zh/overlay.git`. Compare GitHub owner and repository names case-insensitively, but write newly added URLs with lowercase `gentoo-zh`. Do not inspect remotes merely because a tracked file will be edited. Support both common clone layouts:
  - fork clone: `origin` points to a personal fork and `upstream` points to `gentoo-zh/overlay`;
  - direct clone: `origin` points to `gentoo-zh/overlay`; publish PR topic branches to a personal fork remote, not to the canonical remote.
- Use the existing canonical remote, whatever its name is. Do not add `upstream` just because it is absent.
- If no existing remote points to `gentoo-zh/overlay`, treat the checkout as a fork clone that needs a canonical remote, add `upstream`, and fetch it:

  ```bash
  git remote add upstream git@github.com:gentoo-zh/overlay.git
  git fetch upstream
  ```

- If a canonical remote already exists, fetch that remote instead:

  ```bash
  git fetch <canonical-remote>
  ```

- If fetching the canonical remote fails, do not silently rewrite or bypass it; report the current canonical remote URL or fetch error before changing it.
- If currently on `master`, first sync `master` from `<canonical-remote>/master`, then create a topic branch before editing tracked files.
- Push PR work only from topic branches on a personal fork remote. Never push PR work directly to `master` or to topic branches on the canonical remote.
- If the worktree contains unrelated changes, preserve them. Do not overwrite, revert, stage, or commit unrelated changes.
- Stop before editing and ask the user when the canonical remote is ambiguous or cannot be fetched, `master` cannot be synced from `<canonical-remote>/master`, a topic branch cannot be created safely, unrelated local changes make branch creation or staging ambiguous, or the requested change spans multiple unrelated logical PRs.
- Stop before publishing PR work when the personal fork remote is missing or ambiguous.

### Topic Branches

- Use one topic branch per logical pull request.
- Branch all PR-bound work from a freshly synced `master`; for version bumps, prefer names like `category-package-version`.
- A pull request may touch multiple packages only when they are part of one logical contribution, such as one dependency chain, one coordinated version bump, or one shared fix.
- Keep unrelated package changes in separate branches and PRs.
- Never split an ebuild change and its `Manifest` update across separate PRs.
- When rebasing an open PR, prefer `git rebase <canonical-remote>/master` and push with `--force-with-lease`.

### CI Ignore List

- When adding or modifying non-ebuild-related files, check whether `.github/workflows/emerge-on-pr.yml` needs its `ignore_list` updated so those paths do not get interpreted as package atoms for emerge-on-PR testing.

### Completion Reports

- Every completed change must report the topic branch used, canonical remote status, base branch and sync status, files changed, commands run with pass/fail results, checks skipped and why, and any remaining warnings, risks, or limitations.

## Ebuild Policy

- Do not break people's systems.
- Every ebuild change must install cleanly before commit. A clean compile is not the bar: the emerge-on-PR CI fails on any qa/warn/error Portage elog, not only compile errors. Clear it locally, or document a benign elog in the PR body for a human to merge.
- Test ebuilds for every `KEYWORDS` arch claimed; CI builds only amd64, so verify the others yourself and never claim an arch you did not build.
- Use unstable keywords only, such as `~amd64`; do not add stable keywords.
- Preserve existing package style unless a change is needed for correctness or QA.
- Avoid broad refactors while doing package maintenance.
- For new packages, inspect similar packages in this overlay and in the main Gentoo tree before drafting.
- Do not choose eclasses from memory alone. Prefer local Gentoo tree evidence first, then official Gentoo documentation or gentoo.git when local evidence is missing or ambiguous.
- Use package-local and ecosystem-local precedent before generic templates.
- Keep live `9999` ebuild behavior separate from release ebuild behavior.
- Do not invent licenses. Verify upstream license files and Gentoo license names.

## Bundled and Prebuilt Binaries

- Keyword a per-arch prebuilt blob only for the arches upstream ships, with `KEYWORDS="-* <those arches>"` and a per-arch `SRC_URI`; declare it prebuilt and set `RESTRICT` for stripping and redistribution as the blob requires.
- Treat an `Unresolved soname dependencies` QA notice as a real defect: no QA variable legitimately gags it, so make the bundled libraries resolve and declare the genuine system `RDEPEND` rather than mask it.

## New Packages

- Before drafting a new package, identify category/package name, upstream URL, release version, source archive, license, build system, runtime files, and expected tested arches.
- Search for existing package names, forks, renamed projects, and same upstream in this overlay and the main Gentoo tree.
- Run eclass discovery before writing the ebuild, and keep a short decision record when the choice is non-obvious.
- Add files under `files/` only when patches, init scripts, service files, wrappers, or desktop integration cannot be generated cleanly in ebuild phases.
- Stop and ask before proceeding when license or redistribution rights are unclear, the package requires credentials or click-through downloads, the package name/category is ambiguous, or major patching/vendoring decisions are needed.

## Version Bumps

- Before bumping, read existing ebuilds and package history.
- Normalize upstream version strings according to Gentoo version rules: strip a leading `v`; map `alpha`/`beta`/`pre`/`rc` to `_alpha`/`_beta`/`_pre`/`_rc`; map a trailing packaging/patch number to `_pN`; keep date versions numeric and monotonic (a date going backwards is suspect). When the tag is not a legal Gentoo version, derive it with a `MY_PV`-style variable rather than renaming the release.
- A version-tracking tool's reported string (for example an nvchecker bump reminder) may already be normalized by its own rules and differ from the real upstream tag and `SRC_URI`; verify the real tag before naming the ebuild.
- Compare upstream release notes, build files, dependency changes, and license changes. Check whether patches, files, services, wrappers, desktop assets, and source archive layout still apply.
- Add new ebuilds and update `SRC_URI`, checksums, and version-specific variables together.
- Not every bump is mechanical: a changed dependency/USE flag, a version-scheme change, a prerelease target on release-only history, a pinned commit/crate var, an applied patch, or a per-version bundled-deps artifact must be decided against upstream evidence. Never guess `RDEPEND`/`IUSE` to force a green build; escalate when the data is not available offline.
- A truncated download still produces a valid-looking Manifest that installs locally but fails CI `VERIFY` on the full bytes. For a large distfile, cross-check its manifested size against the upstream asset before trusting the Manifest.
- A per-version bundled dependency artifact (a `*-deps`/`*-vendor`/`*-crates`/`node_modules` tarball, matched by filename and hosted on GitHub releases, not a Gentoo mirror) must be published upstream for the new version before the bump, or the fetch 404s.
- Drop old versions only when requested or when repository policy makes it appropriate; preserve old revisions still needed for compatibility. For routine bumps, default to add-only.
- pkgcheck `PotentialStable` is informational only and does not gate CI; this overlay uses unstable keywords only.

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

- A rate-limited `--net` scan over-reports `DeadUrl`/`RedirectedUrl` on GitHub. Re-verify a flagged `SRC_URI` before acting, and note that a dead `HOMEPAGE` does not block installation. Overlay distfiles are not mirrored on `distfiles.gentoo.org`, so a genuinely dead `SRC_URI` here is unfetchable.
- Commit with `pkgdev commit --scan false --signoff --gpg-sign` by default.
- If GPG signing is unavailable in the current environment, fall back to `pkgdev commit --scan false --signoff`.

## QA

- Fix the real QA problem at its root; never edit an ebuild just to make a check pass. Do not ignore QA either: fix what is genuine, and keep only a benign or unavoidable notice, with its rationale and risk stated.
- If adding a QA exception, explain why it is correct for this package, not merely convenient.
- Re-run the command that exposed a QA problem after each fix.
- Final reports must include commands run, pass/fail result, checks skipped and why, and any remaining warnings or known limitations.
- Retry at most three times. If the same error repeats twice for the same package, stop, report the failed phase and attempts, and ask before continuing.

## Commit Messages

- Commit with `pkgdev commit`, not raw `git commit`, so the subject follows the repository's `category/package: ...` convention; do not hand-write a divergent subject.
- Land a new package (or one logical change) as a single clean commit; squash incremental fixups before the PR instead of a chain of `fix ...` / `use ...` / `update ...` follow-ups. Keep the history simple.
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
- After opening the PR, watch its CI checks; if one fails, read the CI log and fix the actual cause, never guess.
- Keep generated or mechanical churn out of the PR unless it is directly required by the package change.
