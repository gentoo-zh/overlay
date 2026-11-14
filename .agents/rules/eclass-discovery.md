## Eclass Discovery

Read with: `AGENTS.md` § Ebuild Policy for how to find precedent; `version-bumps.md` when an EAPI bump rides on a version bump.

- Prefer the local main tree when available; resolve it with `portageq get_repo_path / gentoo`.
- Search current eclass/construct usage and gentoo.git pickaxe (`-S`) history for adoption or removal; the skill supplies runnable searches.
- Before inheriting, read supported EAPIs, deprecation status, pre-inherit/call-time variables, exports, phases, and defaults.
- On EAPI bumps, audit the whole ebuild, including disabled USE branches, generated dependencies, dead helpers, and changed eclass defaults.
- Compose overlapping exported phases explicitly. Overrides call the eclass implementation where its behavior must remain; `default` invokes the EAPI implementation.
- Prefer clear phase code over inheriting an eclass for one helper when current precedent agrees. Leave eclass-owned assignments to the eclass: `git-r3` appends `PROPERTIES="live"`; `cargo` owns `CARGO_HOME`; `go-module` owns `GOCACHE`, `GOMODCACHE`, and `GOPROXY`.
- `cargo.eclass` `GIT_CRATES` writes `[patch.'<git url>']`, which cannot override upstream `[patch.crates-io] name = { git = … }`. Keep `GIT_CRATES` for `SRC_URI`; rewrite that upstream entry to `path = "${WORKDIR}/<repo>-<commit>"` in `src_prepare`. Match `Cargo.lock`'s URL exactly, including renamed organizations and `RedirectedUrl` findings: Cargo keys offline sources by that string.
- `metadata/install-qa-check.d/60go-module-eclass` takes the highest `go` directive across all `${WORKDIR}` modules. Remove an unused sub-module in `src_prepare` only when no build, test, or install path uses it; otherwise raise the floor.
