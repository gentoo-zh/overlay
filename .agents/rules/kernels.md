## Kernel Packages

Read with: `version-bumps.md` for release, source-host, and retention policy; `new-packages.md` for tracking entries; `prebuilt-binaries.md` for `-kernel-bin`; `pr-text.md` before committing.

The seven kernel packages below inherit `cjktty`, carry `CJKTTY_PV`, and share its live patch bytes. `gentoo-cjk-*` are source, self-built, and prebuilt dist-kernel forms; CachyOS, XanMod, and Liquorix provide downstream sources; `xanmod-kernel` builds a dist-kernel from XanMod patches.

- Follow each package's upstream: `gentoo-cjk-*` uses `::gentoo`'s `gentoo-kernel`/`gentoo-sources` on existing overlay branches; `cachyos-sources` uses CachyOS, `xanmod-*` XanMod, and `liquorix-sources` Liquorix. Choose that upstream's newest release on the branch.
- `CJKTTY_PV` is the applied patch filename's version suffix; update it when the patch changes, including within a branch.
- On point releases, derive touched paths from the cjktty patch and intersect them with upstream's incremental `.../incr/patch-A-B.xz`. Reuse the patch and `CJKTTY_PV` only for an empty intersection.
- `cjktty.eclass` fetches raw `cjktty-patches` `master` bytes. A change stales every referencing Manifest: regenerate them together after verifying cached distfiles equal current `master`. `pkgdev manifest` rehashes the distdir copy, and mirrors can cache old bytes.
- Pin downstream bytes: CachyOS patch/config/rebase inputs by commit, XanMod SourceForge `patch-<ver>-xanmod<N>.xz`, and Liquorix zen-kernel `v<ver>-lqx<N>.patch.xz`. Apply `version-bumps.md` source-host policy.
- For `-bin` gpkg Manifests, use a real download and verify each size against HTTP `content-length`; never paste a hash from elsewhere; apply `qa.md` § Manifest.
- Because gpkg follows the source build, land source, kernel, and virtual first with only the source provider listed. Add published `-bin` and its virtual entry in a second PR. A one-point-release lag is expected retention.
- Each new dist-kernel appears in that version's `virtual/dist-kernel-*-r100` `||` list; create the virtual for new versions. Otherwise Portage can satisfy `PDEPEND` by installing a second kernel. List only published providers, in order: `-bin`, source, then other providers such as `xanmod-kernel`.
- One version's source, binary, and virtual land in one commit because their mutual references must resolve for pkgcheck.
- Match the model below for new kernels: `kernel-2` + `cjktty` for `-sources`, `kernel-build` for self-built dist-kernels, `kernel-install` for `-bin`. Add a table row and tracking entry per `new-packages.md`; apply the virtual-provider rule above.
- Personal Gentoo mirrors (`dev.gentoo.org/~<dev>`) may lag `distfiles.gentoo.org` for new genpatches; verify the primary mirror before acting on `DeadUrl`.

### What each bump checks

Copy variable values from the same-version upstream ebuild or release on every bump; `PATCHSET` can lag its branch. The final column changes only with upstream's scheme.

| Package | Check against the same version of | Variables | Fixed by design |
| --- | --- | --- | --- |
| `gentoo-cjk-sources` | `gentoo-sources` | `K_GENPATCHES_VER`, `K_WANT_GENPATCHES`, `CJKTTY_PV` | the all-arch `KEYWORDS` |
| `gentoo-cjk-kernel` | `gentoo-kernel` | `PATCHSET`, `CONFIG_VER`, `GENTOO_CONFIG_P`, `SHA256SUM_DATE`, `DEBIAN_COMMIT`, `CJKTTY_PV` | |
| `gentoo-cjk-kernel-bin` | `gentoo-kernel-bin`; gpkg on `distfiles.gentoozh.org/gentoo-cjk-kernel/amd64/<major.minor>/` | `PATCHSET`, `SHA256SUM_DATE`, `CJKTTY_PV`; gpkg checks above | |
| `cachyos-sources` | CachyOS repositories; `gentoo-sources` for genpatches | `CACHYOS_PATCHES_COMMIT`, `CACHYOS_CONFIGS_COMMIT`, `CACHYOS_PR`, `ZFS_COMMIT`, `K_GENPATCHES_VER`, `CJKTTY_PV`; the version path embedded in the rebase URI | `UNIPATCH_EXCLUDE`, `K_NO_VERSION_CHECK` |
| `xanmod-sources` | XanMod on SourceForge; `gentoo-sources` for genpatches | `K_GENPATCHES_VER`, `CJKTTY_PV`, `XANMOD_VERSION` (the spin number in `patch-<PV>-xanmod<N>.xz`) | |
| `xanmod-kernel` | `gentoo-kernel` on the same branch; XanMod on SourceForge | `PATCHSET`, `CJKTTY_PV`, `XV` (the XanMod spin number), `LLVM_COMPAT` when upstream's clang support changed; the matching `virtual/dist-kernel` entry | |
| `liquorix-sources` | zen-kernel releases; `gentoo-sources` for genpatches | `K_GENPATCHES_VER`, `K_WANT_GENPATCHES`, `CJKTTY_PV`, the `lqx<N>` suffix in `SRC_URI` and `UNIPATCH_LIST_DEFAULT` | `K_NOSETEXTRAVERSION`, `K_EXP_GENPATCHES_NOUSE` |
