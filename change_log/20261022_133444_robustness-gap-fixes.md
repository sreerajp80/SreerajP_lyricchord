# Change log: Robustness and gap fixes (whole-app review)

Implements [plans/20261022_115802_robustness-gap-fixes.md](../plans/20261022_115802_robustness-gap-fixes.md)
(Part A, plus decisions B1 = keep the features and update the docs, and
B2 = document the blue/amber palette). Part C (localization, PDF file name) is
not part of this change.

## A1. Stage Lock can no longer trap the user

- `MainActivity` now extends `FlutterFragmentActivity`, which `local_auth`
  needs to show its prompt. Before, every unlock failed on Android and the user
  could only leave Stage Mode by killing the app.
- `LaunchTheme` / `NormalTheme` (light and night) now use AppCompat parents;
  `androidx.appcompat:appcompat:1.7.0` added in `android/app/build.gradle.kts`.
- `StageSecurityService` handles `LocalAuthException` (local_auth 3.x) and maps
  its codes with `outcomeForLocalAuthCode`. New `StageAuthResult.isDenied`.
- `StageModeNotifier.unlockStageWithAuth` now returns the `StageAuthResult` and
  unlocks unless the user cancelled or failed the check.
- New `lib/widgets/stage_feedback.dart`: Back and the "Stage Locked" chip show a
  `SnackBar` when the stage stays locked, or when it unlocked without a check.
- iOS: `NSFaceIDUsageDescription` added.

## A2. iOS camera and photo keys

- `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` added to
  `ios/Runner/Info.plist` for AirQR.

## A3. Stage Quiet Mode tells the truth and never leaves the phone silent

- Android: checks Do Not Disturb access first, saves the previous ringer mode to
  disk before changing it, restores it on disable, when the app finishes, and on
  the next start after a crash (only if the ringer is still silent). New
  `openQuietModeAccessSettings` channel call. Manifest gains
  `ACCESS_NOTIFICATION_POLICY` (install-time).
- `StageQuietModeService.enableQuietMode` returns a `QuietModeResult`
  (`on`, `needsAccess`, `unsupported`, `failed`); not offered on iOS.
- `toggleQuietMode` sets `isQuietMode` only when the phone really went silent;
  dead code in `enter()` removed. The HUD shows a `SnackBar` for each result,
  with an **Open settings** action when access is needed. The bell is hidden on
  iOS.
- Leaving the song screen restores the ringer and leaves Stage Mode.

## A4 / A5. Import keeps every field and saves what was previewed

- `ImportService` "overwrite" and "same name typed" paths now carry raga, tala
  and tradition, and keep the song's star and scroll settings.
- New `ImportService.importSongs`; the import preview saves its parsed songs
  directly instead of formatting them to text and parsing again.

## A6. Safe text decoding

- `decodeImportedBytes` moved to `lib/core/utils/text_decoding.dart` and
  decodes UTF-16 byte by byte (no more `Uint16List.view` crash on odd offsets).

## A7. Import size limit and visible errors

- `AppConstants.maxImportFileBytes` = 5 MB. The picker import no longer loads
  every file into memory (`withData: false`), skips files over the limit and
  names them in a `SnackBar`.
- Android file-open: read on a background thread, stops at 5 MB, and sends raw
  bytes (so UTF-16 works there too) or an error code.
- `FileIntentListener.readPayload` turns that into a preview or a problem;
  problems show a `SnackBar` through the new `rootScaffoldMessengerKey`.

## A8. AirQR frame checks

- `AirQrFrame.isValid`: block count 1–4096, indices in range and unique, degree
  matches, payload not empty. Invalid frames are dropped by `parse`.
- `AirQrService` ignores frames whose block count or block size disagree with
  the stream, checks parity checksums, and caps pending parity frames.

## Docs (B1, B2)

- `CLAUDE.md` / `AGENTS.md`: hard rules 4 and 5 and the security rules now
  allow only the AirQR camera permission, and point to `docs/security.md` §3.
- `docs/security.md` §3: table of the allowed permissions and the Stage Lock /
  Quiet Mode safety rules; §4: size limit, decoding, AirQR checks.
- `docs/dependencies.md`, `docs/features.md`: AirQR, Stage Lock, Quiet Mode and
  import details. `docs/lyriccord_idea.md` §4: blue/amber palette.
- In-app Help (Full screen topic): Stage Lock and Quiet Mode text updated.

## Strings

- 13 new keys in `lib/l10n/app_en.arb`, all with descriptions;
  `flutter gen-l10n` re-run.

## Tests

- Rewritten / extended: `test/providers/stage_mode_provider_test.dart`,
  `test/services/stage_security_service_test.dart`,
  `test/services/import_service_test.dart`,
  `test/services/air_qr_service_test.dart`.
- New: `test/core/utils/text_decoding_test.dart` (moved from
  `line_break_utils_test.dart` and extended),
  `test/widgets/file_intent_listener_test.dart`.

## Checks

- `dart format`, `flutter analyze`: no issues.
- `flutter test`: 943 tests, all pass.
- `flutter build apk --flavor dev --debug`: builds. Gradle daemons stopped.
- Not checked here: the Stage Lock prompt, Quiet Mode and the AirQR camera on a
  real phone; iOS needs a Mac to build.

## Found during this work (not changed here)

- The production release APK gets the `INTERNET` and `ACCESS_NETWORK_STATE`
  permissions from Google `datatransport` (ML Kit telemetry), which comes in
  through `mobile_scanner`. This breaks hard rule 1 and needs its own plan.
