## New Packages

Read with: `eclass-discovery.md` before choosing an eclass; `prebuilt-binaries.md` for a prebuilt payload; `desktop-integration.md` for a desktop application; `openrc-systemd.md` for a service; `kernels.md` for a kernel package; `pr-text.md` before committing.

- Before drafting, search both trees for the project, former names, forks, and comparable packages. Identify fixed source, license, build system, runtime files, and tested arches.
- Base a `::gentoo` fork on its current ebuild, preserving explanatory comments and justifying every difference. Keep patches, USE flags, and workarounds aligned with what the current main-tree ebuild retains.
- Follow precedent for metadata order, dependency layout, phases, and eclasses; a main-tree sibling is closest for multi-package upstreams.
- Apply `kernels.md` for dist-kernel virtuals, provider order, commit grouping, and publication sequence.
- Add every new package to `.github/workflows/overlay.toml` in the same PR, sorted by `category/package`.
- Trackable releases get an active `["category/package"]` table. Live-only or externally synced packages get a commented `#["category/package"]` block with the reason; `acct-*`, `virtual`, and `app-alternatives` get commented entries without a reason.
- For tag repositories mixing packages or version schemes, use `use_max_tag = true` and a package-specific `include_regex`, as in `app-editors/xed`.
- Set `use_latest_release = true` for releases or `use_latest_tag = true` for tags only; `prefix = "v"` strips upstream's tag prefix from ebuild versions. `github_account = "<GitHub login>"` identifies the packager receiving nvchecker issues. `autobump = true` requires opt-in and a rename-plus-Manifest bump; resolve a preceding `# autobump off:` reason before enabling it.
- For per-version `gentoo-zh/gentoo-deps` bundles, set `deps = "<LANG>"` with `vendordir`, `workdir`, or `modules` as needed. For `gentoo-zh-drafts`, use the full `bundle` form. Set these when introducing such downloads on bumps too; `scripts/autobump.md` defines both forms for future bundle preparation. Go vendor bundles unpack to `${P}/vendor/` so go-module finds `${S}/vendor`; top-level `./vendor/` is a layout error.
- Add `files/` assets only when phases cannot generate them cleanly.
- Check version overlap with `::gentoo` before masking. This overlay's `profiles/package.mask` is repository-scoped, so masking a shared version selects the main-tree copy.
- Stop for unclear licensing/redistribution, downloads requiring credentials or click-through terms, ambiguous names/categories, or substantial patching/vendoring needing a maintainer decision.
