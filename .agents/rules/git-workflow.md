## Git Workflow

Read with: `AGENTS.md` § Git Workflow for the PR-scope rules; `pr-text.md` before committing.

Complete preflight before the first edit, and repeat it only if the state is no longer known.

Treat `master` only as an upstream-sync branch.

- Start with `git status --short --branch`.
- Use one topic branch per logical PR. Create new work from local `master` freshly synced with `<canonical>/master`; prefer `category-package-version` for bumps.
- When resuming, reuse the correct topic branch.
- Before preparing a PR, fetch the canonical remote and rebase the topic branch onto `<canonical>/master`. A stale base makes GitHub report the PR out of date.
- Re-fetch the canonical remote before stating that a commit or PR is merged, and before basing follow-up work on it. A stale ref reports the opposite.
- Compare and open against `<canonical>/master`, never the personal fork's `master`. The fork lags and inflates the diff with unrelated commits.
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
- For non-ebuild changes, check `scripts/emerge-targets.sh` `ignore_list` so paths are not interpreted as package atoms.
- Stop before editing if any of these holds:

  - The canonical remote is ambiguous.
  - A required `master` sync fails.
  - A branch cannot be created safely.
  - Unrelated changes make staging ambiguous.
  - The request spans unrelated PRs.
