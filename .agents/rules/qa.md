## Commands and QA

Read with: `AGENTS.md` § Ebuild Policy for the install gate; `pr-text.md` before committing.

- Require `dev-util/pkgdev` and `dev-util/pkgcheck`. If either is missing, stop and ask the human to emerge it; never substitute `git commit`, a hand-written Manifest, or a custom lint. `dev-util/github-cli` is optional: without `gh`, hand over the compare link for the human to open. Apply `pr-text.md` for commits.
- Before attributing findings, read package history, the previous version's result, and the PR pkgcheck report's commit, packages, and status. Report pre-existing findings as such.
- `ebuild <file> install` resolves no dependencies and cannot expose missing `BDEPEND`; apply `dependencies.md` for `fowners` inputs.
- Iterate with the narrowest relevant checks; rerun the command exposing a failure. Reuse passes on the same tree. A rebase or new commit invalidates the commit scan; retain every gate in `AGENTS.md` § Ebuild Policy.

### Install and CI

- emerge-on-PR clears elog after `--onlydeps`, then fails on every `qa`, `warn`, or `error` elog from the package emerge, including dependencies built in that step. Elog from a dependency is not a defect in the change: report it and leave the ebuild unchanged.
- After every push, emerge-on-PR installs on amd64 OpenRC and systemd, plus arm64 systemd for arm64-keyworded packages. arm64 OpenRC and other arches remain unverified; local install obligations remain in `AGENTS.md` § Ebuild Policy.

### Manifest

- Never write a hand-made Manifest; run `pkgdev manifest` when distfiles change, with `--distdir <writable-dir>` when system `DISTDIR` is unwritable.
- Before the first package-payload download in a work item (distfile, vendor bundle, or release asset), report its URL and upstream-stated size and wait for approval.

### Scanning

- After required installs pass, scan the explicit merge-base-to-HEAD range against `<canonical>/master` with `--net` and `--git-remote <canonical>`. The range selects targets; the remote selects commit-check provenance. Bare `--commits` uses `origin`, which may differ from the branch base.

  ```bash
  pkgcheck scan --git-remote <canonical> --commits="$(git merge-base <canonical>/master HEAD)..HEAD" --net
  ```
- Resolve cross-package noise with a package-scoped network scan as ground truth, alongside the required commit scan.

### Tests

- Exercise every affected USE state; run available upstream tests with `FEATURES=test`. Tests use the build tree, with test-only inputs, dependencies, and resources declared and gated.
- Keep the largest reliable test subset; skip individual failures with reasons. `RESTRICT=test` requires proof that no reliable subset remains and a recorded reason.
- Use `PROPERTIES="test? ( test_network )"` only with `IUSE=test`; otherwise use `PROPERTIES="test_network"`.

### QA notices

- Fix genuine defects at their cause; preserve working behavior when a checker is wrong.
- Retain only documented false positives or unavoidable notices, with rationale and residual risk. Reproduce each exact condition before calling an emerge-on-PR elog benign, e.g. `CONFIG_CHECK` without kernel sources or foreign-ABI ELF skipped under `ABI_X86=64`; keep no list of ignorable notices.

### Network results

- Reverify `DeadUrl`/`RedirectedUrl`, including GitHub rate limits. A result describes one host's route; verify a second mirror or route before declaring a URL dead, including HTTP 403.
- CI pkgcheck omits `--net`, so network keywords stay untested there.
- A dead `HOMEPAGE` leaves installation possible. A dead overlay `SRC_URI` prevents fetching because `distfiles.gentoo.org` does not mirror overlay distfiles.

### Reviewing the change

- Review staged diff and diffstat for intended changes, clean output, complete `files/` assets, and intended Manifest entries. Apply `AGENTS.md` § Git Workflow for unrelated changes.
- Verify patches, substitutions, generators, and manual/glob installs against release source and final files, modes, and license notices; require file evidence beyond exit status.
