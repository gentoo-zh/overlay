## Version Bumps

- Compare existing ebuilds and history with upstream notes and build metadata for dependency, toolchain, option, license, layout, and installed-file changes.
- The `go.mod` `go` directive and `Cargo.toml` `rust-version` are real minimum versions, and no eclass reads them for you.
- When one exceeds what the profile toolchain guarantees, raise the matching `>=dev-lang/go` `BDEPEND` or `RUST_MIN_VER`.
- If the raised floor is not yet in the tree, hand over the compare link stating the PR must be opened as a draft.
- Cite the upstream `go.mod` and the tree state on packages.gentoo.org, for example `>=dev-lang/go-1.26.5` when `go.mod` says `go 1.26.5`.
- The `go.mod` `toolchain` line is only a suggestion under `GOTOOLCHAIN=local` and sets no floor.
- Re-check patches and assets. Update the ebuild, `SRC_URI`, version variables, checksums, and `Manifest` together; stop when required evidence is unavailable.
- A GitHub tag archive has no `.git`, so a build that derives its version with `git describe` fails or gets no usable version. Pass the version explicitly, as `sys-kernel/mkinitcpio` does for `meson.build`.
- A `files/` copy of an upstream hook, unit, or script drifts. On every bump diff it against upstream's current file; `mkinitcpio`'s copied base hook installed `/init` without the executable bit until someone booted the image.
- When the `::gentoo` snapshot emerge-on-PR uses does not yet carry a version the change depends on, keep the atom, open the PR as a draft, and rerun CI once that snapshot carries it.
- When a bump exposes a defect, fix it in the existing ebuild and change only what the new release invalidates. Rewrite it only when the release leaves it unusable, and say what made it so.
- Normalize the ebuild version by Gentoo rules. Preserve the literal upstream tag through `MY_PV` or an equivalent variable when needed.
- Tracker output is only a hint: verify the real tag, artifact, and URL. `-rN` is a Gentoo revision; never derive upstream tags or filenames from `${PVR}` or `${PF}`.
- Never guess `RDEPEND`, `IUSE`, pins, generated dependency sets, build options, or vendor artifacts merely to obtain a green build.
- A versioned deps/vendor/crates/`node_modules` artifact must already exist for the new version, or the fetch 404s.
- That artifact is often not upstream but in an overlay or contributor repo: commonly `gentoo-zh-drafts/<PN>`, sometimes `gentoo-zh/gentoo-deps` or a contributor's repo.
- Reuse the exact host and naming the existing `SRC_URI` uses; do not assume upstream, invent a host, or switch repos on your own. Change host only under a verified, maintainer-directed migration.
- Cross-check a large distfile's size against its source, so a truncated download cannot produce a plausible but invalid `Manifest`.
- When upstream moves, update `HOMEPAGE`, `metadata.xml` `remote-id`, and version-tracking URLs to the current project.
- Keep `SRC_URI` on the real artifact, and provenance variables on the repository that produced that release.
- For an in-place tarball replacement, verify provenance, contents, tag or commit, signatures, and licenses. Use a distinct distfile name and revbump.
- Remove or update only state made obsolete when a version, implementation, USE flag, provider, or package name is removed.
- Scope cleanup to affected ebuild conditionals, assets, metadata and profile entries, reverse-dependency references, and live or twin variants.
- Preserve everything required by surviving ebuilds or providers.

## Keeping Old Versions

A bump replaces the version it supersedes—`add NEW, drop OLD`. Retention is the exception and needs one of the reasons below.

- Keep the prior version across a major version jump, large rewrite, or build-system migration, even for a `-bin` package and even when history rolls the latest. Drop it once the new branch has held.
- Keep any version a reverse-dependency pin, `SLOT`, or profile entry still resolves against. Check the overlay and the main tree per `SLOT` and per retained arch before dropping.
- Keep a version whose replacement is unverified: an arch upstream skipped this release, or a security fix not yet on every keyworded branch.
- Otherwise drop. A package with no cross-version state, no reverse dependencies, and nothing worth downgrading to keeps exactly one version. Being prebuilt is not a reason to keep the old one.
- Follow the package's own history where it shows an explicit pattern; otherwise apply the rules above and state the choice. Never keep a version merely because the previous commit did.
- Stop for direction when an old version loses its immutable source bytes, or when a replacement in place is unexplained.
- `autobump = N` in `.github/workflows/overlay.toml` applies the same policy to autobump: set a number only for a package meeting a reason above, and return it to `true` when the reason lapses.
