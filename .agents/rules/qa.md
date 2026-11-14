## Commands and QA

Read with: `AGENTS.md` § Ebuild Policy for the install gate; `pr-text.md` before committing.

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
- Retain only a documented false positive or unavoidable notice, with its rationale and remaining risk. Before calling an emerge-on-PR elog notice benign, reproduce the exact condition that produced it, such as a `CONFIG_CHECK` warning with no kernel sources in the container or a foreign-ABI ELF skipped under `ABI_X86=64`; do not maintain a list of ignorable notices.
- Never rewrite working behavior merely to silence a checker.

### Network results

- GitHub rate limits can cause false `DeadUrl` or `RedirectedUrl` results; re-verify flagged URLs.
- A network result is evidence about your host only. An edge that returns 403 here may serve the same URL elsewhere, so re-check from a second vantage point, such as another mirror or a fetch through a different route, before calling a URL dead.
- CI's `pkgcheck` runs without `--net`, so no network keyword fires there.
- A dead `HOMEPAGE` does not block installation. A dead overlay `SRC_URI` is unfetchable because overlay distfiles are not mirrored on `distfiles.gentoo.org`.

### Reviewing the change

- Review the staged diff and diffstat. Reject unrelated hunks, debug output, missing `files/` assets, or unintended `Manifest` entries.
- Verify patches, substitutions, generators, and manual or glob installs against the intended release source and final files, modes, and license notices—not command exit status alone.
