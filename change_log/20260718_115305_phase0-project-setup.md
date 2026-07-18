# Change log — Phase 0: Project setup

**Implements plan:** [../plans/20260718_113528_phase0-project-setup.md](../plans/20260718_113528_phase0-project-setup.md)

**Date:** 2026-07-18

## Summary

Scaffolded the LyricCord Flutter app and put the fixed project conventions in
place. The app now launches to a placeholder home screen and has a working,
data-driven About screen. This is Phase 0 from the implementation plan.

## What changed

### App scaffolding
- Ran `flutter create . --org in.sreerajp --project-name lyriccord
  --platforms=android,ios`.
- Confirmed Android `namespace` and `applicationId` are `in.sreerajp.lyriccord`.
- Confirmed the source `AndroidManifest.xml` has **no** permissions (no INTERNET).

### Dependencies (`pubspec.yaml`)
- Runtime: `flutter_riverpod`, `drift`, `sqlite3_flutter_libs`,
  `shared_preferences`, `go_router`, `pdf`, `printing`, `file_picker`,
  `package_info_plus`, `url_launcher`.
- Dev: `drift_dev`, `build_runner`.
- Pinned `package_info_plus` to the 8.x line so a modern `file_picker` (10.x)
  resolves. The two disagreed over `win32` (a Windows-only transitive that does
  not affect the android/ios build): file_picker 8.3.3+ wants win32 ^5.9.0 while
  package_info_plus 10.x wants win32 ^6. Pinning package_info_plus to 8.3.0
  resolved the conflict.
- Registered `assets/config/` under `flutter: assets:`.

### Baseline `lib/` layout (architecture §4)
- Created the layer folders: `core/config`, `core/constants`, `core/errors`,
  `core/utils`, `models`, `services`, `repositories`, `data`, `providers`,
  `screens`, `widgets`, `theme`. Empty folders hold a `.gitkeep`.

### About-screen config (guideline §1)
- `assets/config/app_config.json` — LyricCord About values (version 1.0.0,
  build 1, details: Author, Email, License, AI used, IDE used).
- `lib/core/config/app_config.dart` — `AppConfig` model with `fromJson` +
  `fallback`.
- `lib/core/config/config_service.dart` — `ConfigService` with `load()` and
  `loadAndVerify()`.
- `lib/providers/config_provider.dart` — Riverpod `configServiceProvider` and
  `appConfigProvider` (FutureProvider) to feed the About screen.

### Constants
- `lib/core/constants/app_constants.dart` — `AppConstants`: db name
  (`lyriccord.db`), theme-mode pref key, 600 dp tablet breakpoint.

### Screens and entry point
- `lib/screens/home_screen.dart` — placeholder home with an About action.
- `lib/screens/about_screen.dart` — data-driven About screen; loops
  `config.details`, skips empty rows, makes the email row tappable via
  `mailto:`; no hard-coded field names.
- `lib/main.dart` — thin entry: `WidgetsFlutterBinding.ensureInitialized()`,
  `ProviderScope`, `MaterialApp` with a default Material 3 seed theme (violet
  `#6750A4`) and the home screen.

### Housekeeping
- `test/widget_test.dart` — replaced the default counter test with a home-screen
  smoke test.
- `.gitignore` — added `android/key.properties`, `android/*.jks`,
  `android/*.keystore`, and `build/symbols/`.

## Verification
- `dart format` — clean.
- `flutter analyze` — **No issues found.**
- `flutter test` — **All tests passed** (1 test).
- `flutter build apk --debug` — built `app-debug.apk` successfully, confirming
  the Android app compiles and launches to the placeholder home.

## Definition of Done (Phase 0)
- [x] App launches to a placeholder home screen (Android build verified; iOS not
      buildable on Windows but shares the same Dart/Flutter code).
- [x] About screen reads from `ConfigService` and renders `details` dynamically.
- [x] `flutter analyze` is clean.

## Notes / follow-ups
- `web_socket_channel` appears as a transitive dependency of the Flutter test
  tooling, not of any app runtime package. The app adds no network package and
  has no INTERNET permission.
- Deferred to Phase 1: drift database + DAO + first-run seeding, the full violet
  Material 3 theme, and the saved theme-mode preference.
- iOS build not verified (no macOS/Windows cannot build iOS). Verify on a Mac
  before an iOS release.
