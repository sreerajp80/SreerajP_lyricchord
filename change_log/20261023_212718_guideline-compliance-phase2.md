# Change log: Guideline compliance — Phase 2 (Android toolchain upgrade)

Implements Phase 2 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)

## Decisions made with the user during this phase

- **Flutter SDK stays on 3.47.6.** Flutter 3.47.7 is out, but the user chose not to upgrade
  the SDK on the machine now. CI, `CLAUDE.md` and `AGENTS.md` keep 3.47.6. The newer patch
  is a known gap.
- **Plugin upgrades approved.** AGP 9 refuses to build plugins that compile against Android
  API 34. `file_picker` 10.0.0 and `package_info_plus` 8.3.0 do, and the `package_info_plus`
  pin also held `wakelock_plus` at 1.3.3. The user approved upgrading them.

## What changed

### Android build (versions read from a fresh `flutter create` on Flutter 3.47.6, not typed from memory)

- `android/settings.gradle.kts` — Android Gradle Plugin 8.11.1 → 9.1.0; Kotlin Gradle Plugin
  2.2.20 → 2.4.0.
- `android/gradle/wrapper/gradle-wrapper.properties` — Gradle 8.14 → 9.3.1.
- `android/gradle.properties` — unchanged. `android.builtInKotlin=false` and
  `android.newDsl=false` already match what the Flutter template writes.
- `android/app/build.gradle.kts`:
  - `kotlinOptions { }` replaced by the top-level `kotlin { compilerOptions { jvmTarget = JVM_17 } }`.
  - `buildFeatures { resValues = true }` added. AGP 9 turns custom resource values off by
    default, and the `dev` / `prod` flavors use `resValue` for their app names.

### Packages

- `flutter pub upgrade` within the existing ranges (drift 2.35, flutter_riverpod 3.4.3,
  go_router 17.5, pdf 3.13.1 and others). Only two new packages came in: `process` (via
  `native_toolchain_c`, a build-time tool) and `yaml_edit` (via `drift_dev`, dev only).
  Neither does network I/O.
- `file_picker` 10.0.0 → `^13.1.0` and `package_info_plus` 8.3.0 → `^10.2.2`. The exact pins
  are gone; the old `win32` clash that needed them no longer exists. `wakelock_plus` moved to
  1.8.2 within its range. New packages from this: `file_picker`'s own platform parts
  (`android_file_picker`, `file_picker_darwin`, `file_picker_linux`, `windows_file_picker`,
  `file_picker_web`, `file_picker_platform_interface`) and `ffi_leak_tracker`. No network
  packages.
- `intl: any` → `intl: ^0.20.3` (the range `flutter_localizations` already requires; the
  resolved version did not change).
- `dart fix --apply` — nothing to fix.

### Code (file_picker 12+ API)

- `lib/screens/import_export_screen.dart` — import uses the static `FilePicker.pickFiles()`,
  which returns a list (empty = cancelled) and picks several files by default. The size check
  uses `lengthSync()` or `length()`, and the bytes come from `readAsBytes()`; the 5 MB limit
  and the "too large" / "unreadable" messages work as before. Removed the unused `dart:io`
  import.
- `lib/screens/import_export_screen.dart`, `lib/screens/song_list_screen.dart`,
  `lib/screens/song_performance_screen.dart` — the four exports use the static
  `FilePicker.saveFile()`, which now returns a `Uri` (the variable is renamed `savedUri`).
  `type` / `allowedExtensions` were removed from these calls because version 13 ignores them
  in `saveFile()`. The PDF export now passes `mimeType: 'application/pdf'`; the ChordPro
  exports keep the default MIME type.

### Docs

- `docs/dependencies.md` — new versions; note on the static `FilePicker` API and iOS 14.
- `docs/architecture.md` §21 — three new known risks: the Kotlin Gradle Plugin warning
  (the app and `mobile_scanner` 6.x still apply it), iOS 14.0 needed by `file_picker`, and the
  `http` package that `audioplayers` brings in (see below).
- `docs/features.md` — removed the sentence about exact-pinned packages.
- `docs/PROJECT_PROFILE.md`, `README.md`, `CLAUDE.md`, `AGENTS.md` — the iOS deployment
  target must rise to at least 14.0 when iOS is declared. The `ios/` folder was not touched,
  because iOS is not a declared platform.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 985 tests passed.
- `flutter build apk --flavor dev --release` — built.
- `flutter build apk --flavor prod --release --obfuscate
  --split-debug-info=build/symbols/android-prod-2.6.13+37/ --split-per-abi` — built.
  arm64 APK 27.9 MB (the previous 2.6.13 build was about 30 MB); armeabi-v7a 23.8 MB;
  x86_64 30.3 MB. All are within the 50 MB hard limit.
- `aapt2 dump permissions` on the arm64 prod APK: `ACCESS_NOTIFICATION_POLICY`,
  `USE_BIOMETRIC`, `USE_FINGERPRINT`, `CAMERA`, and the app's own
  `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. **No `INTERNET`, no `ACCESS_NETWORK_STATE`.**
- Not debuggable (no `application-debuggable` line); `allowBackup=false`.
- `zipalign -c -P 16 -v 4` — "Verification successful" (16 KB page size).
- `android\gradlew --stop` run; the leftover `GradleDaemon` and `KotlinCompileDaemon`
  processes were ended; none remain.

## Not tested

- The file picker and Save dialog were not tried on a real device. The API calls compile and
  the unit/widget tests pass, but no test drives the real picker. Before release, check on a
  phone: import one and several ChordPro files, a file over 5 MB, cancel; export all songs,
  selected songs, one song as ChordPro and as PDF, including a Malayalam title.

## Findings for later (not changed here)

- **`http` in the app's dependency tree.** `audioplayers` depends on `http` (this was already
  true before Phase 2). `docs/dependencies.md` §4 says HTTP clients must never be added, even
  transitively. Release builds have no `INTERNET` permission, so it cannot reach the network
  on Android. Needs its own decision: accept it with a written exception, or replace
  `audioplayers`.
- **Built-in Kotlin.** Flutter warns that the Kotlin Gradle Plugin will stop working in a
  future release. Moving the app to built-in Kotlin needs every plugin to support it;
  `mobile_scanner` 6.x does not (7.x may). A separate change.
- **Other major updates available** (each to be reviewed on its own, standard §16.6):
  `go_router` 18, `mobile_scanner` 7, `cupertino_icons` 2, `build_runner` 2.17, `qr` 4.
- **Flutter 3.47.7** is available (user chose to stay on 3.47.6 for now).
