## Ebuild Construction

Read with: `AGENTS.md` § Ebuild Policy for install, keyword and precedent gates; `dependencies.md` for atoms and revbumps.

- Keep release and `9999` behavior distinct. Port applicable dependency, QA, EAPI, and phase fixes to the live ebuild.
- A live ebuild must sort above every release the package has. `9999` is lower than a date version, so a package versioned `20240203` needs `99999999`; confirm with `python3 -c 'from portage.versions import vercmp; print(vercmp("9999", "20240203"))'` before naming the file.
- Every `${FILESDIR}` reference must name a committed file.
- If `PATCHES` coexists with a custom `src_prepare`, call `default` or apply the patches explicitly. `eapply_user` alone does not apply `PATCHES`.
- Keep global scope metadata-invariant and side-effect-free. Do not run external programs, emit uncaptured output, modify system state, or depend on system, profile, repository, or phase data.
- Do not use pipes, process substitution, heredocs, or herestrings there. Bash may back the latter two with temporary files that the metadata sandbox forbids.
- Deterministic package-manager helpers and pure shell expansion are valid in global scope. Put work requiring declared build context in phases.
- Declare external build and test inputs through `SRC_URI`/`Manifest` or an eclass vendor mechanism. Enforce offline operation without warm caches.
- Each USE state must control every applicable option, dependency, source selection, and install cleanup consistently. Disable automagic.
- When a package adds, removes, or renames a local USE flag, update its `metadata.xml` flag description in the same change.
- Prune only what `src_install` would otherwise install. Deleting a path it never reaches is dead code, as is a branch that only removes files that USE state does not install.
- `${ED}` already carries the offset; never append `${EPREFIX}` to it. `${D}` does not carry it. Use a bare `${EPREFIX}` only in installed content read at runtime, and only where that consumer runs under Prefix.
- Verify package and bundled-component licenses, Gentoo license names, and redistribution terms; they determine `RESTRICT=mirror` or `bindist`. Separately, `LICENSE` must list the license of every component compiled or statically linked into installed files, not only the top-level project.
- A license absent from `::gentoo` needs its full text in `licenses/` and `RESTRICT` set from its own distribution terms. One that forbids redistribution sets both `mirror`, which covers the distfile, and `bindist`, which covers what is built from it. Add it to `profiles/license_groups` when it belongs to one of those groups; a license that fits none stays ungrouped.
- A backport records its upstream commit, PR, or bug URL and applicable and tested versions.
- A security fix covers every still-keyworded vulnerable branch and relevant sibling or fork. Revbump when installed content or behavior changes.
- A package move updates `profiles/updates` atomically with every affected reference.

### Code Style

- Keep code concise. Prefer clear naming, established helpers, direct control flow, and simple structure over explanatory comments or complex shell code.
- Implement logic near the relevant code rather than adding a separate script. Use functions only when they materially reduce local complexity or duplication.
- Keep comments only when they explain non-obvious intent, constraints, trade-offs, or workarounds that the code cannot express and a future maintainer needs to preserve.
- Do not add comments that restate eclass-documented variable assignments, configuration, declarations, option values, function calls, commands, or standard settings.
- Do not add comments to justify QA suppressions, including `QA_PREBUILT` and `QA_SONAME`.
- Preserve existing useful comments unless they are outdated or incorrect.
