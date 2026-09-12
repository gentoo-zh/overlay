## Eclass Discovery

- Prefer the local main tree at `/var/db/repos/gentoo` when present.
- Before inheriting, read each eclass's supported EAPIs, deprecation status, pre-inherit and call-time variables, exports, phases, and defaults.
- On an EAPI bump, re-audit the whole ebuild, including disabled USE branches, generated dependencies, dead helpers, and changed eclass defaults.
- Define phase composition explicitly when eclasses export the same phase.
- An override calls the eclass implementation when its documented behavior must remain. `default` invokes the EAPI default, not an eclass-exported phase.
- Do not inherit an eclass for one helper when clear phase code and current precedent agree.
- Do not repeat an assignment an inherited eclass owns: `git-r3` appends `PROPERTIES="live"`; `cargo` owns `CARGO_HOME`, `go-module` owns `GOCACHE`, `GOMODCACHE`, and `GOPROXY`.
- `cargo.eclass` `GIT_CRATES` writes `[patch.'<git url>']`, which cannot override an upstream `[patch.crates-io] name = { git = … }`. Keep `GIT_CRATES` for `SRC_URI` and rewrite that upstream entry to `path = "${WORKDIR}/<repo>-<commit>"` in `src_prepare`. Write the URL as `Cargo.lock` spells it, even after upstream renamed the organization; cargo resolves offline sources by that string.
- The tree's `metadata/install-qa-check.d/60go-module-eclass` takes the highest `go` directive from every `go.mod` under `${WORKDIR}`, including a sub-module the build never compiles. When no build, test, or install path uses that sub-module, remove it in `src_prepare`; otherwise raise the floor to what it needs.
