## Dependencies and Revisions

Read with: `ebuild-construction.md` for USE-controlled dependencies; `qa.md` for scanning.

- Every atom traces to evidence here: a linked SONAME, a build-file `dependency()`, `find_package`, or `pkg-config` call, a `dlopen`ed library, or a program a phase runs.
- A launcher or `bwrap` script's external commands outside `@system` count as that evidence: find each command's provider with `qfile` on an installed system or by searching the repository. `xdg-user-dir` belongs to `x11-misc/xdg-user-dirs`, not `x11-misc/xdg-utils`.
- Another distro's control file is not evidence.
- Do not declare what the environment provides: `@system` members, tools an inherited eclass pulls in, or a compiler or libc floor the profile guarantees.
- One atom per package: fold the version bound, `SLOT`, and USE constraints into a single entry.
- Carry the build system's own version floors into the atom, and do not invent floors it does not state. Add an upper bound only for a verified incompatibility with no available fix.
- Before adding a slot operator (`:=` or `:slot=`), check that the provider declares a subslot. Without one it binds `slot/slot`, so consumers rebuild when the slot changes but never on an ABI break inside it.
- Revbump when a Gentoo-side change can alter an existing installation or runtime dependency decision.
- That includes installed output or behavior, runtime dependencies, subslot binding, and default USE changes.
- Also revbump for an affected non-free or soon-to-be-removed license and for a non-trivial EAPI change.
- Skip the revbump when a descriptive, copyright, keyword, message, test, build-failure, or build-dependency-relaxation change cannot leave an installed result wrong.
- In EAPI 8+, put host tools that must execute while the package is merged, such as post-install cache generators, in `IDEPEND`.
- For a verified direct ABI consumer, put `:=` or `:slot=` on every `DEPEND` or `RDEPEND` atom that models that linkage. Never copy it to transitive dependencies.
- Identical prebuilt bytes cannot adapt to a new ABI. Constrain verified provider slots or versions instead of assuming a reinstall fixes them.
- `:=` and `:slot=` are invalid in `PDEPEND` and must stay outside `|| ( )`. Inside an any-of group, list only supported providers, preferred first.
- Before adding or retaining any dependency or alternative provider, check removal entries in both this overlay's and the main Gentoo tree's `profiles/package.mask`.
- When a package is removed or renamed, update dependency atoms plus `elog` and `optfeature` recommendation strings.
- A provider subslot represents an ABI that requires consumer rebuilds. Re-check SONAMEs, private-header ABI, and library renames on every bump.
- Never derive a sibling package version from `${PV}` without verifying that it exists and resolves.
- Never replace a `files/` input still referenced by a surviving ebuild; give its replacement a version- or revision-specific name.
