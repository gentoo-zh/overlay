## Bundled and Prebuilt Binaries

Read with: `version-bumps.md` or `new-packages.md` for the change; `dependencies.md` for linkage evidence; `desktop-integration.md` for desktop apps; `openrc-systemd.md` for services; `kernels.md` for `-kernel-bin`.

- Whitelist published artifact arches, e.g. `KEYWORDS="-* ~amd64 ~arm64"`, with per-arch `SRC_URI`. Never keyword or reference an unpublished artifact.
- Set `RESTRICT` from verified stripping and redistribution needs; `strip` and `splitdebug` differ.
- Scope `QA_PREBUILT` to exact installed paths of manually reviewed, immutable blobs. It suppresses DT_NEEDED, executable-stack, textrel/W+X, flags, pre-stripped-file, and SONAME checks; `RESTRICT=strip` controls stripping.
- Audit each installed object's ELF class/machine, interpreter, `NEEDED`, SONAME, RPATH, installed path, libc/libstdc++ floors, and CPU ISA baseline. Inspect every arch's archive layout and linkage separately; same-release builds may differ, including OpenSSL linkage.
- Smoke-test amd64. Add untested `~arm64` when upstream ships that release's arm64 artifact; report it unverified and fix arch-specific problems on report.
- Apply `dependencies.md` for evidence-backed dependencies and immutable-byte ABI constraints.
- Set per-arch `RDEPEND` glibc floors as `>=sys-libs/glibc-X` from the highest binary `GLIBC_` symbol version. Static-PIE has no such symbols and needs no floor. Express glibc needs through dependencies, leaving `elibc_glibc` out of `REQUIRED_USE`: musl profiles otherwise produce error-level `RequiredUseUnsatisfiableInDev` and fail new-package CI.
- Resolve every `NEEDED` through verified bundled layout or genuine system `RDEPEND`, including QA-suppressed objects. An unresolved entry is a runtime defect.
- Private modules may lack SONAME; justify unusual RPATH per object. A retained private blob may use verified literal `'$ORIGIN/...'`.
- For source-built objects, fix build/link/install behavior first. Use evidence-backed `patchelf` only as fallback, with `BDEPEND`.
- Replace bundled components with system ones only after verifying ABI, functionality, and launcher/configuration integration; otherwise stop.
- `REQUIRES_EXCLUDE` filters metadata only. Use it for verified unresolved-soname false positives: an `RDEPEND` provider installs the requested filename with a different SONAME (`app-arch/bzip2` provides `libbz2.so.1.0`), or an optional plugin stays unloaded without its provider. Otherwise fix the dependency or layout; never patch the binary to hide the notice.
- Exclude runtime self-hashing files from stripping individually with `dostrip -x <path>`, as `net-proxy/flclash-bin` does; retain stripping for the rest of the package.
- For prebuilt `dotnet-pkg-base` payloads, match `DOTNET_PKG_COMPAT` to each `*.runtimeconfig.json` framework.
