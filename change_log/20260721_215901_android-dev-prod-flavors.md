# Change log: Add dev/prod build flavors (Android)

**Plan:** [plans/20260721_215901_android-dev-prod-flavors.md](../plans/20260721_215901_android-dev-prod-flavors.md)

## Why

`flutter run --flavor dev` failed with `Task 'assembleDevDebug' not found`
because no product flavors were defined.

## What changed

1. `android/app/build.gradle.kts` — added the `environment` flavor dimension
   with two flavors:
   - `dev`: app id `in.sreerajp.lyriccord.dev`, version name suffix `-dev`,
     launcher name "LyricCord Dev". Installs side by side with the prod app.
   - `prod`: app id unchanged, launcher name "LyricCord".
   Each flavor sets the name through `resValue("string", "app_name", ...)`.

2. `android/app/src/main/AndroidManifest.xml` — `android:label` now points at
   `@string/app_name` so each flavor shows its own launcher name.

3. `CLAUDE.md` — build/run commands now use `--flavor dev` / `--flavor prod`;
   removed the "no flavors yet" note and documented the iOS gap.

4. `docs/release_process.md` — release commands now pass `--flavor prod`;
   output paths updated to the `prodRelease` folders (including the
   `aapt2 dump permissions` check path).

## Not changed

- Signing: the existing `key.properties` logic applies to both flavors.
- iOS: no flavor schemes yet — needs Xcode on a Mac. Run iOS without
  `--flavor` until then.
- No Dart code changes.

## Verification

- `flutter build apk --flavor dev --debug` — built
  `build/app/outputs/flutter-apk/app-dev-debug.apk` successfully.
- `flutter analyze` — no issues.
- `flutter test` — all 174 tests passed.
