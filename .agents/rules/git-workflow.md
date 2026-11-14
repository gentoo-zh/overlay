## Git Workflow

Read with: `AGENTS.md` § Git Workflow for the PR-scope rules; `pr-text.md` before committing.

Complete preflight before editing; repeat when state becomes uncertain. `master` is an upstream-sync branch.

- Start with `git status --short --branch`. Use one topic branch per logical PR from local `master` freshly synced to `<canonical>/master`; prefer `category-package-version` for bumps. Resume on the existing correct topic branch.
- Before preparing a PR, fetch canonical and rebase onto `<canonical>/master`. Fetch again before declaring a commit/PR merged or basing follow-up work on it. Compare and open against `<canonical>/master` so a stale personal fork cannot inflate the diff.
- Resolve an existing canonical remote by case-insensitive GitHub owner/repository match: `gentoo-zh/overlay` or `microcai/gentoo-zh`, using SSH or HTTPS.
- Reuse that remote's name in both fork and direct clones. If absent, add `upstream` at `https://github.com/gentoo-zh/overlay.git`.
- Fetch before using canonical state. Ensure `<canonical>/HEAD` resolves; set it with `git remote set-head <canonical> master` if needed. pkgcheck requires that head independently of the scan range. On fetch failure, stop and report the existing URL and error; do not rewrite or bypass the remote.
- Apply `AGENTS.md` § Git Workflow for push targets; use `--force-with-lease` after rebasing. A missing or ambiguous personal fork blocks publishing only; local editing may continue.
- Repository metadata lives in `metadata/` and `profiles/`; CI lives in `.github/`. For non-ebuild changes, check `scripts/emerge-targets.sh` `ignore_list` so paths stay outside package targets.
- Stop before editing on an ambiguous canonical remote, failed required `master` sync, unsafe branch creation, ambiguous staging caused by unrelated changes, or a request spanning unrelated PRs.
