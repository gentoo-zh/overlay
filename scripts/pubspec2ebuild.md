# pubspec2ebuild

Generates the `PUB_HOSTED` / `PUB_GIT` arrays that `dart-pub.eclass` consumes,
from a Flutter app's `pubspec.lock`.

```
scripts/pubspec2ebuild.py path/to/pubspec.lock
```

Requires `dev-python/pyyaml`.

## Regenerating an app's dependencies

1. Get the FOSS `pubspec.lock`. If upstream ships a strip step (e.g. localsend's
   `scripts/remove_proprietary_dependencies.sh`), run it first, then
   `flutter pub get` to resolve. Feed that lock to the generator.

2. If the app builds a Rust plugin through cargokit (rhttp, flutter_rust_bridge),
   the cargokit `build_tool` resolves its own Dart dependencies at build time.
   Those are not in the app's lock, so generate them too from
   `<pub-cache>/hosted/pub.dev/<plugin>-*/cargokit/build_tool/pubspec.lock` and
   merge the hosted entries into `PUB_HOSTED` (versions may differ from the app's;
   pub-cache is versioned, so both coexist).

3. For `dev-util/flutter-bin`, the SDK's `flutter_tools` has its own lock at
   `packages/flutter_tools/pubspec.lock`; that is where its 95 entries come from.

The Rust crates themselves stay a vendored tarball (`cargo vendor`); dart-pub only
covers the Dart side.

## Deriving the LICENSE set

The fetched packages are installed content, so their licences belong in `LICENSE`.
`--urls` prints the archive each entry is fetched from, hosted and git alike:

```
set -o pipefail
scripts/pubspec2ebuild.py --urls pubspec.lock | while read -r url; do
    if ! text=$(curl -sfL "${url}" | tar xzO --wildcards '*LICENSE' 2>/dev/null) ||
            [ -z "${text}" ]; then
        echo "FAILED ${url}"
        continue
    fi
    printf '%s\n' "${text%%$'\n'*}"
done | sort -u
```

`pipefail` matters: a truncated archive prints the licence and *then* fails, so
without it the download error is accepted. It is also why the first line is cut
with a parameter expansion rather than `head`, which exits before `printf` is
done writing and makes the whole command fail with 141 on perfectly good input.

Any `FAILED` line means the archive was not fetched or held no licence, and the
set is incomplete until it is resolved. The exit status does not report that;
the `FAILED` lines do.

Map each distinct licence to the matching name under `licenses/` in the Gentoo
repository, and add anything not already covered to the ebuild.
