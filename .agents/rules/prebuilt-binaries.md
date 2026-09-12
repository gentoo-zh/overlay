## Bundled and Prebuilt Binaries

- For each upstream binary artifact, whitelist only shipped arches (for example `KEYWORDS="-* ~amd64 ~arm64"`) and use per-arch `SRC_URI`. Do not keyword or reference unpublished artifacts.
- Set `RESTRICT` from verified stripping and redistribution needs; `strip` and `splitdebug` are distinct.
- `QA_PREBUILT` suppresses broad checks, including DT_NEEDED, executable-stack, textrel/W+X, flags, pre-stripped files, and SONAME.
- Use `QA_PREBUILT` only for manually reviewed, immutable upstream blobs, scoped to exact installed paths. `RESTRICT=strip`, not `QA_PREBUILT`, prevents stripping.
- Audit every installed object: ELF class and machine, interpreter, `NEEDED`, SONAME, RPATH, installed path, required libc/libstdc++ symbol floors, and CPU ISA baseline.
- Smoke-test amd64. If upstream ships an `arm64` artifact for the same release, add `~arm64` untested. Record the unverified arch in the completion report and fix arch-specific problems on report.
- Depend only on what blobs actually link or invoke.
- An unresolved `NEEDED` entry is a runtime defect even when QA is suppressed. Resolve it through a verified bundled layout or genuine system `RDEPEND`; never suppress it.
- A private module may legitimately lack SONAME, but every unusual RPATH needs object-specific justification.
- For source-built objects, fix the build, link, and install system first. Use `patchelf` only as an evidence-backed fallback and add it to `BDEPEND`.
- A retained private blob may use a verified literal `'$ORIGIN/...'` RPATH.
- Replace a bundled component with a system one only after verifying ABI, functionality, and launcher or configuration integration; otherwise stop.
