# Build metadata generation (version + build date) and About screen date

Implements [plans/20260904_160417_build-metadata-generation.md](../plans/20260904_160417_build-metadata-generation.md).

## What changed

### New generator scripts

- `tool/generate_app_version.dart` — reads the `version:` line from
  `pubspec.yaml` and writes `lib/core/constants/app_version.g.dart`
  (`kAppVersion`, e.g. `2.6.10+34`). Prints
  `app_version.g.dart updated → 2.6.10+34`.
- `tool/generate_build_date.dart` — writes
  `lib/core/constants/build_date.g.dart` (`kBuildDate`, `YYYY-MM-DD`). Prints
  `build_date.g.dart updated → 2026-09-04`.

Both generated files are committed, so `flutter test` and iOS builds work
without running Gradle first. They must never be hand-edited.

### Gradle wiring

`android/app/build.gradle.kts`:

- Loads `android/local.properties` to find the Flutter SDK (falls back to the
  `FLUTTER_ROOT` environment variable), and picks `bin/dart.bat` on Windows.
- Registers two `Exec` tasks, `generateAppVersion` and `generateBuildDate`,
  grouped under an umbrella `generateBuildMetadata` task.
- `preBuild` and every `compileFlutterBuild*` task depend on it, so any
  `flutter run` or `flutter build` regenerates the metadata before the Dart code
  is compiled.
- Task inputs include `pubspec.yaml`, the script, and today's date, so the task
  re-runs when the version or the day changes and is skipped otherwise.
- `Exec` tasks are used instead of `project.exec { }` so the build produces no
  Gradle deprecation warnings from this script.

### About screen

`lib/screens/about_screen.dart`:

- The version line now comes from the generated `kAppVersion`, shown as
  `Version 2.6.10 (build 34)`. It can no longer drift from `pubspec.yaml`.
- The `app_config.json` `version` / `build` values remain only as a fallback if
  the generated string is ever empty.
- New "Build date" row showing `kBuildDate`.
- The open-source licence page uses the same version text.

### Tests and docs

- New `test/screens/about_screen_test.dart` — checks the screen prefers the
  generated version over a deliberately stale config value, and shows the build
  date.
- `docs/architecture.md` §15 documents the generated build metadata.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 903 tests pass.
- `flutter build apk --flavor prod --release --split-per-abi` — prints:
  ```
  app_version.g.dart updated → 2.6.10+34
  build_date.g.dart updated → 2026-09-04
  ```
  and builds all three ABI APKs.
