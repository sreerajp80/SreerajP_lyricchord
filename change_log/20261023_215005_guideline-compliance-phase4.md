# Change log: Guideline compliance — Phase 4 (start-up, logging, errors, lifecycle)

Implements Phase 4 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gaps D1–D5 and C4).

## What changed

### New code (target layer in brackets)

- `lib/core/config/app_flavor_config.dart` [core/config] — `AppFlavorConfig`: reads
  `APP_FLAVOR`, then `FLUTTER_APP_FLAVOR` (engineering standard §5.2). Unknown or missing
  means `prod`.
- `lib/core/logging/app_logger.dart` [core/logging, new folder] — `AppLogger` over the
  `logger` package:
  - dev flavor: every level, with error detail and stack traces;
  - prod flavor: `info` and up (`trace`/`debug` print nothing);
  - prod **release** builds: an error is logged by its type only, never its message or
    stack trace, so song text or file names cannot reach the release log;
  - console only (logcat); no log file.
- `lib/core/errors/global_error_handlers.dart` [core/errors] — `installGlobalErrorHandlers()`:
  `FlutterError.onError` and `PlatformDispatcher.instance.onError` log through `AppLogger`;
  release builds set `ErrorWidget.builder` to `SafeErrorFallback`.
- `lib/widgets/safe_error_fallback.dart` [widgets] — calm message + icon, no error detail;
  shows the icon alone if the app's strings are not reachable.
- `lib/screens/startup_error_screen.dart` [screens] — `StartupErrorApp` /
  `StartupErrorScreen`, shown when start-up fails: explanation, **Try again**, **Copy details**
  (standard §11.4).
- `lib/services/app_lifecycle_service.dart` [services] — `AppLifecycleService`:
  - `detached` → write-ahead-log checkpoint (new `AppDatabase.checkpointWal()`,
    `PRAGMA wal_checkpoint(PASSIVE)`). The database is **not** closed, because on Android a
    detached engine can be shown again and a closed drift database cannot be reopened;
  - memory pressure → clear the image cache.

### Changed code

- `lib/main.dart` — start-up follows standard §4.5: bindings → logger + error handlers →
  (no FFI, no secure storage) → database → saved settings → lifecycle service → `runApp`.
  Steps 5–8 are wrapped so a failure shows `StartupErrorApp` instead of a blank app. Logs
  "App start" with the flavor and version.
- `lib/data/app_database.dart` — new `checkpointWal()`.
- All 10 `debugPrint` calls replaced with `AppLogger` (none are left in `lib/`):
  `config_service.dart` (debug), `air_qr_frame.dart` (debug, error type only),
  `import_preview_screen.dart` (error; logs the real cause of an `AppException`),
  `song_performance_screen.dart` ×2 (error), `air_qr_service.dart` (warning),
  `melody_audio_service.dart`, `pitch_drone_audio_service.dart` (error),
  `metronome_audio_service.dart` ×3 (error / warning). The `kDebugMode` gates and the
  unused `foundation.dart` imports are gone; `lib/` no longer uses `kDebugMode`.
- `lib/l10n/app_en.arb` (+ generated files) — new keys, already in the guideline's prefix
  style: `errorWidgetFailed`, `titleStartupFailed`, `descStartupFailed`,
  `actionCopyDetails`, `bodyDetailsCopied`. The existing `tryAgain` is reused.

### Package

- `logger: ^2.8.0` — MIT licence; depends only on `meta` and `clock`; no build hooks;
  `dart:io` is used only by its file outputs, which the app does not use. No network code.

### Tests (23 new, all passing)

- `test/core/config/app_flavor_config_test.dart` — flavor parsing, defaults.
- `test/core/logging/app_logger_test.dart` — dev keeps debug; prod drops trace/debug;
  prod release logs the error type and not the message ("Amazing Grace" never appears).
- `test/core/errors/global_error_handlers_test.dart` — framework and async errors are
  logged; release uses `SafeErrorFallback`; debug keeps Flutter's error widget.
- `test/widgets/safe_error_fallback_test.dart` — message + icon; icon only without strings.
- `test/services/app_lifecycle_service_test.dart` — `detached` runs the checkpoint; other
  states do not; a failing checkpoint does not throw; memory pressure clears the cache.
- `test/screens/startup_error_screen_test.dart` — no technical detail shown; Try again;
  Copy details copies the error and shows "Details copied".
- `test/data/app_database_checkpoint_test.dart` — checkpoint on a real WAL database file.

### Docs

- `docs/architecture.md` — §4 tree and table (`core/logging`, `AppFlavorConfig`), §5 start-up
  table, §6 lifecycle, §10 error handling, §17 logging, §20 two new decisions (shutdown
  handling, console-only logs).
- `docs/project_structure.md`, `docs/security.md` §5, `docs/dependencies.md` (new `logger`
  entry), `CLAUDE.md` / `AGENTS.md` security rule (log only through `AppLogger`).

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1009 tests passed.
- Hardened prod build (`--flavor prod --release --obfuscate
  --split-debug-info=build/symbols/android-prod-2.6.13+37/ --split-per-abi`) — built;
  arm64 APK 28.1 MB (+0.2 MB, the `logger` package).
- `aapt2 dump permissions` — no `INTERNET`, no `ACCESS_NETWORK_STATE`.
- `android\gradlew --stop` run; no Gradle or Kotlin daemon left.

## Not tested

- Not run on a device. Worth checking with `adb logcat` on a prod release build that an
  "App start" line appears and that a failed PDF export logs only the error type.
- The start-up failure screen was tested as a widget only; a real start-up failure was not
  forced on a device.
