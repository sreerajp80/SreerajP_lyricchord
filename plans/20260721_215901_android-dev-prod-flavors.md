# Plan: Add dev/prod build flavors (Android)

**Status:** completed

## The issue

Running `flutter run --flavor dev` fails with
`Task 'assembleDevDebug' not found`. The project has no product flavors
defined in `android/app/build.gradle.kts`, so the `--flavor` option cannot
be used. The user wants a dev/prod flavor split.

## Scope

Android only. The iOS side needs Xcode (schemes and xcconfig files), which
is not available on this Windows machine. iOS flavor setup is deferred to
when a Mac is available. Until then, iOS builds keep working without
`--flavor`.

## Files to change

1. `android/app/build.gradle.kts`
   - Add `flavorDimensions += "environment"` and two product flavors,
     following `docs/guidelines/flutter_build_flavors_guide.md`:
     - `dev`: `applicationIdSuffix = ".dev"`, `versionNameSuffix = "-dev"`,
       `resValue("string", "app_name", "LyricCord Dev")`
     - `prod`: `resValue("string", "app_name", "LyricCord")`
   - The `.dev` suffix lets dev and prod installs sit side by side on the
     same phone.

2. `android/app/src/main/AndroidManifest.xml`
   - Change `android:label="LyricCord"` to `android:label="@string/app_name"`
     so each flavor shows its own launcher name.

3. `CLAUDE.md`
   - Update the "Build & run commands" section: commands now take
     `--flavor dev` / `--flavor prod`, and remove the note that says no
     flavors are defined.

4. `docs/release_process.md`
   - Update the release build commands to include `--flavor prod`
     (release APK/bundle output paths also change to the `prodRelease`
     folders).

## What is NOT changing

- No signing changes — the existing `key.properties` release-signing logic
  stays as it is and applies to both flavors.
- No flavor-specific icons or resource folders — the `resValue` app name is
  enough for now.
- No Dart code changes — the app does not need to read the flavor at
  runtime yet. If it ever does, `appFlavor` from `package:flutter/services.dart`
  is the way.
- No iOS changes (see Scope).

## Checks after the change

- `flutter run --flavor dev` builds `assembleDevDebug` and installs
  `in.sreerajp.lyriccord.dev` named "LyricCord Dev".
- `flutter analyze` and `flutter test` stay clean (no Dart changes, so
  this is a sanity check only).
