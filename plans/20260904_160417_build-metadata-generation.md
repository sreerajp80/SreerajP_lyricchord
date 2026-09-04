# Build metadata generation (version + build date) and About screen date

**Status:** completed

## Issue

1. The About screen shows the app version from `assets/config/app_config.json`.
   That file is edited by hand, so it can drift away from the real version in
   `pubspec.yaml` (`2.6.10+34`).
2. There is no build date anywhere in the app, so a tester cannot tell which
   build they are holding.
3. A build prints nothing about version or date, unlike the sister project
   `sreerajp_todo`, which prints:
   ```
   app_version.g.dart updated → 1.12.7+28
   build_date.g.dart updated → 2026-08-29
   ```

## Plan for the fix

Copy the proven approach from `sreerajp_todo`:

- Add two small Dart generator scripts under `tool/`. One reads the `version:`
  line from `pubspec.yaml`, the other takes today's date. Each writes a tiny
  generated Dart constant file and prints the line shown above.
- Hook them into the Android Gradle build so **every** `flutter build` /
  `flutter run` regenerates them before Dart is compiled. No extra command to
  remember.
- Use the generated version as the truth on the About screen, and add a new
  "Build date" row.
- Keep `app_config.json` `version` / `build` as a fallback only (used if the
  generated value is somehow empty), so nothing breaks and existing tests keep
  working.

### Files to change

| File | Change |
|------|--------|
| `tool/generate_app_version.dart` | **New.** Reads `version:` from `pubspec.yaml`, writes `lib/core/constants/app_version.g.dart` with `kAppVersion` (full string, e.g. `2.6.10+34`), prints `app_version.g.dart updated → …`. |
| `tool/generate_build_date.dart` | **New.** Writes `lib/core/constants/build_date.g.dart` with `kBuildDate` (`YYYY-MM-DD`), prints `build_date.g.dart updated → …`. |
| `lib/core/constants/app_version.g.dart` | **New (generated, committed).** So `flutter test` and iOS builds work without running Gradle. |
| `lib/core/constants/build_date.g.dart` | **New (generated, committed).** Same reason. |
| `android/app/build.gradle.kts` | Add a `generateBuildMetadata` task that runs both scripts with the Dart from the Flutter SDK (`local.properties` `flutter.sdk` or `FLUTTER_ROOT`); make `preBuild` and `compileFlutterBuild*` depend on it. |
| `lib/screens/about_screen.dart` | Show `Version <kAppVersion>` (split into version + build for display), and add a "Build date" `ListTile` showing `kBuildDate`. Fall back to the config values when the generated string is empty. |
| `test/screens/about_screen_test.dart` | **New.** Widget test: the About screen shows the generated version and the build date. |
| `docs/architecture.md` | Short note about the generated build metadata and where it comes from. |

### Details

- The generated files are committed (not git-ignored), the same as in
  `sreerajp_todo`, so a fresh checkout compiles without running Gradle first.
- Gradle task inputs include `pubspec.yaml`, both scripts, and today's date as a
  property, so the task re-runs when the date changes but stays up-to-date
  within a day.
- Nothing here touches networking, permissions, or the database, so the hard
  rules are unaffected.
- Windows is handled: the script picks `bin\dart.bat` on Windows and `bin/dart`
  elsewhere.

## Verify

- `flutter analyze` clean.
- `flutter test` passes.
- `flutter build apk --flavor prod --release --split-per-abi` prints the two
  generator lines.
- About screen shows version, build number, and build date.
