## Version Bumps

Read with: `pr-text.md` before committing; `prebuilt-binaries.md` when the package installs a prebuilt payload; `kernels.md` for a kernel package; `openrc-systemd.md` when a unit or init script changes; `desktop-integration.md` when a desktop file or launcher changes; `eclass-discovery.md` when the bump changes EAPI or an eclass.

- Compare ebuilds/history with release notes and build metadata for dependency, toolchain, option, license, layout, and installed-file changes. Recheck bundled/vendor components every bump, including static libraries, amalgamations such as `sqlite3.c`, and header-only copies; apply `ebuild-construction.md` license policy.
- Read `go.mod` `go` and `Cargo.toml` `rust-version` as minimums yourself. Raise `>=dev-lang/go` in `BDEPEND` or `RUST_MIN_VER` above the profile guarantee when required. Cite upstream `go.mod` and packages.gentoo.org tree state. Under `GOTOOLCHAIN=local`, `toolchain` is a suggestion only. Every cargo ebuild sets `RUST_MIN_VER` at least as high as the highest `rust-version` across unpacked workspace members and vendored crates.
- If a raised floor is absent from the tree, the PR must be a draft: hand over the compare link and say so. If emerge-on-PR's `::gentoo` snapshot lacks a dependency version, retain its atom, open as draft, and rerun CI when that snapshot catches up. Apply the same draft policy to eclass-required provider slots absent from `::gentoo`, e.g. zig or opencc; preserve eclass-managed dependencies and `*_OPTIONAL` settings when resolving `NonexistentDeps`.
- Recheck patches and assets; update ebuild, `SRC_URI`, version variables, checksums, and Manifest together under `AGENTS.md` § Git Workflow. Stop when required evidence is unavailable. Diff old/new `PATCHES`: every `files/*.patch` has a surviving consumer and every entry resolves. Carry downstream-only patches forward; remove backports only after confirming their fixes in the release. Rebased patches get new version-prefixed filenames.
- Pass versions explicitly for tag archives lacking `.git`, e.g. `sys-kernel/mkinitcpio`'s Meson build; `git describe` cannot recover the release there.
- Diff copied upstream hooks, units, and scripts in `files/` against the new release on every bump.
- For library bumps, compare dependency minimums with available overlay/`::gentoo` versions and check in-overlay reverse dependencies. emerge-on-PR installs only: it neither runs the package nor rebuilds consumers, so passing CI can miss an unmet minimum.
- Fix exposed defects within the existing ebuild, changing what the release invalidates. Rewrite only when the release leaves it unusable, with the reason.
- Normalize Gentoo versions and preserve literal upstream tags through `MY_PV` or equivalent. Verify tracker hints against real tags, artifacts, and URLs; derive upstream tags and filenames from upstream versions, never from `${PVR}` or `${PF}`, which carry Gentoo revisions.
- Take `RDEPEND`, `IUSE`, pins, generated dependencies, build options, and vendor artifacts from release evidence; never guess them to get a green build.
- Versioned deps/vendor/crates/`node_modules` bundles exist before use. Common producers are `gentoo-zh-drafts/<PN>`, `gentoo-zh/gentoo-deps`, or contributor repositories. Apply `new-packages.md` for bundle tracking fields.
- Preserve existing `SRC_URI` host and naming; change host only for a verified, maintainer-directed migration. Cross-check large distfile sizes against the source before manifesting.
- On upstream moves, update `HOMEPAGE`, `metadata.xml` `remote-id`, and tracking URLs. Keep artifact URLs and provenance variables tied to the actual release and its producing repository.
- For in-place tarball replacements, verify provenance, contents, tag/commit, signatures, and licenses; use a distinct distfile name and revbump.
- Removing versions, implementations, USE flags, providers, or names cleans up only obsolete ebuild conditionals, assets, metadata/profiles, reverse dependencies, and live/twin variants. Preserve inputs required by surviving ebuilds/providers; apply `dependencies.md` for replacement filenames.

## Keeping Old Versions

A bump normally replaces its superseded version: `add NEW, drop OLD`. Retention requires a reason below.

- Keep the prior version through major jumps, large rewrites, or build-system migrations, including `-bin` and packages normally rolling latest. Drop it after the new branch has held.
- Retain versions resolving reverse-dependency pins, slots, or profile entries. Before dropping, check both trees per slot and retained arch.
- Retain versions with unverified replacements, including skipped upstream arches and security fixes absent from a keyworded branch.
- Otherwise drop the old version: with no cross-version state, reverse dependencies, or useful downgrade target, keep exactly one. Apply an explicit package-history pattern where present; otherwise apply these criteria and state the choice. A previous retention or prebuilt format alone is insufficient.
- Stop for direction when immutable old source bytes disappear or an in-place replacement is unexplained.
- Set `autobump = N` in `.github/workflows/overlay.toml` only for a retention reason above; restore `true` when it lapses.
- Apply `kernels.md` for expected `-kernel-bin` lag and catch-up sequence.
