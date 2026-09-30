## New Packages

Read with: `eclass-discovery.md` before choosing an eclass; `prebuilt-binaries.md` for a prebuilt payload; `desktop-integration.md` for a desktop application; `openrc-systemd.md` for a service; `kernels.md` for a kernel package; `pr-text.md` before committing.

- Before drafting, search this overlay and the main tree for the same project, former names, forks, and truly comparable packages.
- Identify its fixed source artifact, license, build system, runtime files, and tested arches before drafting.
- Take the shape from that precedent—metadata order, dependency layout, phase set, eclass stack. When upstream ships several packages, a sibling already in the main tree is the closest precedent.
- Update `.github/workflows/overlay.toml` in the same PR for every new package, inserting the entry in `category/package` alphabetical order.
- A dist-kernel package added at a version must appear in that version's `virtual/dist-kernel-*-r100` `||` list, and a new version needs that virtual created.
- Leaving it out makes Portage satisfy the `PDEPEND` from a provider that is listed and install a second kernel.
- One version's source, binary, and virtual land in one commit. They name each other, so any half alone fails `pkgcheck`.
- List a provider only after its artifact is published. `kernels.md` gives the provider order inside `||` and the two-PR sequence for a `-bin`.
- Add an active `["category/package"]` table in `.github/workflows/overlay.toml` when releases are trackable, otherwise a commented `#["category/package"]` block giving the reason: live-only or synced elsewhere.
- When tracking tags and the repository's tags include other packages or other version schemes, add `use_max_tag = true` and an `include_regex` that matches only this package's versions, as `app-editors/xed` does.
- `acct-*`, `virtual` and `app-alternatives` packages are commented entries too, without a reason.
- Field conventions: `use_latest_release = true` when upstream publishes releases, `use_latest_tag = true` when it only tags; `prefix = "v"` when tags carry a `v` the ebuild version does not; `github_account = "<GitHub login>"` of the packager, so the nvchecker issue reaches them; `autobump = true` only when the packager opts in and a bump is a rename plus `pkgdev manifest`.
- A package whose `SRC_URI` downloads a per-version bundle from `gentoo-zh/gentoo-deps` adds `deps = "<LANG>"` to its table, with `vendordir`, `workdir` or `modules` when the generator needs them; a `gentoo-zh-drafts` producer uses the full `bundle` form. `scripts/autobump.md` describes both.
- Add `files/` assets only when phases cannot generate them cleanly.
- Stop when any of these holds:

  - Licensing or redistribution is unclear.
  - Downloads require credentials or click-through terms.
  - Naming or category is ambiguous.
  - Substantial patching or vendoring needs a maintainer decision.
