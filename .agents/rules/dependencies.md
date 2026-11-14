## Dependencies and Revisions

Read with: `ebuild-construction.md` for USE-controlled dependencies; `qa.md` for scanning.

- Each atom needs linked SONAME, build-file `dependency()`/`find_package`/`pkg-config`, `dlopen`, or executed-program evidence from this package; another distro's control file is not evidence. Declare linked libraries previously supplied only through the toolchain, e.g. libbfd from `sys-libs/binutils-libs`.
- Resolve launcher and `bwrap` commands outside `@system` with `qfile` or repository search. `xdg-user-dir` comes from `x11-misc/xdg-user-dirs`, distinct from `x11-misc/xdg-utils`.
- Declare only dependencies beyond `@system`, inherited-eclass inputs, and profile-guaranteed compiler/libc floors. Combine each package's version, slot, and USE constraints in one atom.
- Carry the build system's stated minimums; upper bounds require verified incompatibility with no available fix.
- Before `:=` or `:slot=`, verify the provider declares a subslot. Otherwise `slot/slot` binding rebuilds on slot changes only, missing ABI breaks within the slot.
- Revbump Gentoo-side changes affecting existing installations or runtime dependency decisions: output, behavior, runtime dependencies, subslot binding, default USE, affected non-free or soon-removed licenses, and non-trivial EAPI changes. Overriding an eclass phase without calling its implementation (e.g. `linux-mod-r1_pkg_postinst`) changes installed behavior and needs a revbump.
- Skip revbumps for descriptive, copyright, keyword, message, test, build-failure, or build-dependency-relaxation changes that cannot leave an installed result wrong. Dropping a dependency whose package already left the tree needs none.
- In EAPI 8+, merge-time host executables such as post-install cache generators belong in `IDEPEND`.
- For direct ABI consumers, apply `:=` or `:slot=` to every `DEPEND`/`RDEPEND` atom modeling that linkage; transitive dependencies stay unbound.
- Immutable prebuilt bytes need verified provider slot/version constraints; reinstalling identical bytes cannot adapt their ABI.
- Keep `:=` and `:slot=` in valid dependency classes outside `PDEPEND` and `|| ( )`. Any-of groups list supported providers in preference order.
- Before adding or retaining any dependency or alternative provider, check removal entries in both trees' `profiles/package.mask`.
- Package removals and renames update atoms and `elog`/`optfeature` recommendations.
- Provider subslots represent consumer-rebuild ABIs. Recheck SONAMEs, private-header ABI, and library renames on every bump.
- Derive sibling versions from `${PV}` only after verifying existence and resolution.
- Preserve `files/` inputs used by surviving ebuilds; give replacements version- or revision-specific names.
- `fowners` targeting an `acct-user` in `src_install` requires that package in both `BDEPEND` and `RDEPEND`, per `acct-user.eclass`.
- On Python bumps, compare wheel core `Requires-Dist` entries (without `extra ==`) with `RDEPEND`/`PDEPEND`.
