## Ebuild Construction

Read with: `AGENTS.md` § Ebuild Policy for install, keyword and precedent gates; `dependencies.md` for atoms and revbumps.

- Prefer the package and its history, a comparable current package, eclass and upstream source, then official Gentoo documentation and gentoo.git. Never substitute memory or superficial similarity for evidence.
- Preserve package-local style and user/toolchain flags. Keep patches and refactors narrow; remove forced optimization, hardening, LTO, stripping, and blanket `-Werror`. Go builds leave stripping and debug splitting to Portage: `-ldflags` carries no `-s` or `-w`, and keeps its `-X` flags.
- Keep release and live behavior distinct; port applicable dependency, QA, EAPI, and phase fixes to the live ebuild.
- A live version sorts above every release: date-versioned `20240203` needs `99999999`, because `9999` sorts lower. Verify ordering with Portage's `vercmp` before naming it.
- Every `${FILESDIR}` reference names a committed file.
- With `PATCHES` and custom `src_prepare`, call `default` or apply patches explicitly; `eapply_user` handles user patches only.
- Global scope is metadata-invariant and side-effect-free: deterministic package-manager helpers and pure shell expansion only. External programs, uncaptured output, state changes, system/profile/repository/phase-dependent work, pipes, process substitution, heredocs, and herestrings belong in phases. Bash can back heredocs and herestrings with files forbidden by the metadata sandbox.
- Declare external build/test inputs through `SRC_URI`/`Manifest` or an eclass vendor mechanism. Operation stays offline with cold caches.
- Each USE state controls its options, dependencies, sources, and install cleanup consistently; disable automagic. Update `metadata.xml` descriptions when adding, removing, or renaming local USE flags.
- Prune only paths the selected USE state would install through `src_install`; remove unreachable cleanup.
- `${ED}` includes the Prefix offset; `${D}` excludes it. Use bare `${EPREFIX}` only in installed runtime content whose consumer runs under Prefix.
- Verify package and bundled-component licenses, Gentoo license names, and redistribution terms. Set `RESTRICT=mirror`/`bindist` from those terms; `LICENSE` includes every component compiled or statically linked into installed files.
- For licenses absent from `::gentoo`, add full text under `licenses/` and apply their distribution terms. A redistribution ban requires both `mirror` for distfiles and `bindist` for built output. Add fitting licenses to `profiles/license_groups`; leave others ungrouped.
- Backports record the upstream commit, PR, or bug URL and applicable/tested versions.
- Security fixes cover every still-keyworded vulnerable branch and relevant sibling or fork; apply `dependencies.md` for revbumps.
- Package moves update `profiles/updates` and all affected references atomically.

### Code Style

- Prefer concise code, clear names, established helpers, direct control flow, and simple structure. Keep logic near its use; functions justify their cost by reducing complexity or duplication.
- Keep useful, accurate comments explaining non-obvious intent, constraints, trade-offs, or workarounds a maintainer must preserve. Code and eclass documentation carry ordinary assignments, configuration, declarations, options, calls, commands, and standard settings. Record QA-suppression rationale in review text, outside code comments.
- Cargo ebuilds installing ELF binaries set `QA_FLAGS_IGNORED` for those binaries; recheck when a bump adds one. Go ebuilds use go-module.eclass's existing `QA_FLAGS_IGNORED='.*'`.
- Gate ISA-dependent binaries with `REQUIRED_USE="amd64? ( cpu_flags_x86_* )"` following `::gentoo` precedent. Retain the gate when baseline CI cannot satisfy it; CI gives the target package the runner's CPU flags.
- Follow `skel.ebuild` variable order: `DESCRIPTION`, `HOMEPAGE`, `SRC_URI`, `S`, `LICENSE`, `SLOT`, `KEYWORDS`, `IUSE`, `REQUIRED_USE`, `RESTRICT`, then dependencies. Reordering alone needs no revbump.
