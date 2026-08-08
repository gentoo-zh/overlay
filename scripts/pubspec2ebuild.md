# pubspec2ebuild

Generates the `PUB_HOSTED` / `PUB_GIT` arrays that `dart-pub.eclass` consumes,
from a Flutter app's `pubspec.lock`. The pub.dev equivalent of pycargoebuild.

```
scripts/pubspec2ebuild.py path/to/pubspec.lock
```

## Regenerating an app's dependencies

1. Get the FOSS `pubspec.lock`. If upstream ships a strip step (e.g. localsend's
   `scripts/remove_proprietary_dependencies.sh`), run it first, then
   `flutter pub get` to resolve. Feed that lock to the generator.

2. If the app builds a Rust plugin through cargokit (rhttp, flutter_rust_bridge),
   the cargokit `build_tool` resolves its **own** Dart dependencies at build time.
   Those are not in the app's lock, so generate them too from
   `<pub-cache>/hosted/pub.dev/<plugin>-*/cargokit/build_tool/pubspec.lock` and
   merge the hosted entries into `PUB_HOSTED` (versions may differ from the app's;
   pub-cache is versioned, so both coexist).

3. For `dev-util/flutter-bin`, the SDK's `flutter_tools` has its own lock at
   `packages/flutter_tools/pubspec.lock`; that is where its 95 entries come from.

The Rust crates themselves stay a vendored tarball (`cargo vendor`); dart-pub only
covers the Dart side.
