# Plan: Robustness and gap fixes (whole-app review)

**Status:** completed

## Background

A review of the whole app against `docs/lyriccord_idea.md`,
`docs/implementation_plan.md`, `docs/features.md`, `docs/security.md` and the
rules in `CLAUDE.md`.

What is already good:

- `flutter analyze`: no issues.
- `flutter test`: all 906 tests pass.
- The critical test areas from `CLAUDE.md` (transpose, ChordPro round-trip,
  `[C]word` parsing, Tempo-Auto math, seeding) all have tests.
- `android:allowBackup="false"` is set. The release manifest has no
  `INTERNET` permission (only the debug and profile manifests do, which is the
  Flutter default for hot reload).

The review found the gaps below. Part A is bugs to fix now. Part B needs a
decision from you. Part C is large, and is proposed as its own later plan.

---

## Part A — Bugs to fix in this plan

### A1. Stage Lock can trap the user in Stage Mode (Android) — serious

**Issue.** `local_auth` 3.x needs the Android activity to be a
`FlutterFragmentActivity` (its README says so). `MainActivity` extends plain
`FlutterActivity`. So on Android `authenticate()` always fails. Stage Lock then
works like this:

1. The user taps the lock icon in the Stage HUD.
2. Back and the "unlock" chip both call `unlockStageWithAuth()`.
3. The device has a screen lock, so `isSecurityAvailable()` is true, but
   `authenticate()` throws. The result is "error", the stage stays locked, and
   nothing is shown.
4. The only way out is to kill the app.

Also:

- `local_auth` 3.x throws `LocalAuthException`, not `PlatformException`. The
  "cancel" / "not enrolled" code checks in `StageSecurityService` never match.
- The launch theme must be a `Theme.AppCompat` theme, or the prompt can crash on
  Android 8 and below (min SDK is 24 = Android 7).
- iOS `Info.plist` has no `NSFaceIDUsageDescription`. Face ID needs it.

**Fix.**

- `MainActivity` extends `FlutterFragmentActivity`. All the existing channel
  code stays the same.
- `LaunchTheme` and `NormalTheme` (`values/` and `values-night/`) use an
  AppCompat parent (`Theme.AppCompat.Light.NoActionBar` /
  `Theme.AppCompat.NoActionBar`), keeping the same window background. Add the
  `androidx.appcompat` dependency in `android/app/build.gradle.kts` only if the
  build needs it.
- `StageSecurityService` catches `LocalAuthException` and maps its codes
  (user cancel, no hardware, not enrolled, no device credential, lockout,
  UI unavailable).
- **Never trap the user:** in `unlockStageWithAuth`, if the result is
  `notAvailable` or `error` (anything that is not a real "wrong user" or
  "cancelled"), unlock anyway. Only a cancelled or failed check keeps the lock.
- Show a `SnackBar` when unlock fails or is cancelled, so the user knows why.
- Add `NSFaceIDUsageDescription` to `ios/Runner/Info.plist`.
- Tests: `stage_security_service_test.dart` for `LocalAuthException` codes;
  `stage_mode_provider_test.dart` for "error → unlocks", "cancel → stays
  locked".

### A2. iOS crashes when AirQR opens the camera or the photo picker

**Issue.** `mobile_scanner` and `image_picker` need
`NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` in
`Info.plist`. Both are missing. iOS kills an app that uses the camera without
the camera key.

**Fix.** Add both keys with short, plain reasons. (This depends on decision B1;
if you choose to remove AirQR, these keys are not needed.)

### A3. Stage Quiet Mode says "on" when the phone was not silenced, and can leave the phone silent

**Issue.**

- `StageModeNotifier.enter()` builds a fresh state, so `isQuietMode` is always
  false there — the quiet check in `enter()` is dead code.
- `toggleQuietMode()` sets `isQuietMode = true` before it knows the result. On
  Android 7+ setting the ringer to silent needs "Do Not Disturb access"
  (notification policy access). Without it Android throws, the Kotlin side
  returns `false`, but the icon still shows quiet. On iOS there is no handler
  at all. A performer would trust the icon and the phone would still ring.
- The previous ringer mode is kept only in memory in `MainActivity`. If the
  app is killed while quiet, the phone stays silent for good.
- Leaving the song screen does not leave Stage Mode, so quiet can stay on.

**Fix.**

- `toggleQuietMode()` sets `isQuietMode` from the real result. If it failed,
  show a `SnackBar`: on Android, explain that LyricChord needs "Do Not Disturb
  access" and offer a button that opens that system page
  (`Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS`). This is a system
  settings page the user grants themselves — not a runtime permission prompt.
  The manifest needs `ACCESS_NOTIFICATION_POLICY` (a normal, install-time
  permission). On iOS, hide the quiet button (iOS does not let apps change the
  ringer).
- Kotlin: check `isNotificationPolicyAccessGranted` first; save the previous
  ringer mode in the app's own `SharedPreferences`; on app start, if a saved
  mode is still there, restore it and clear it.
- Remove the dead code in `enter()`.
- The performance screen's `dispose()` restores quiet mode (calls the quiet
  service's disable) so leaving the song never leaves the phone silent.
- Tests in `stage_mode_provider_test.dart` with a fake quiet service: failure
  keeps `isQuietMode` false; exit restores.

> This also touches decision B1 (it changes a system setting). If you choose to
> remove Quiet Mode in B1, this item becomes "remove it".

### A4. Import "Overwrite" loses the raga, tala and tradition

**Issue.** In `ImportService.importContent`, the `overwrite` strategy and the
"user typed the same name" path copy only title, artist, lyrics, key and bpm.
Importing a Carnatic song over an existing Western song keeps the old
`tradition` (Western) and empty raga/tala. The transposer can then treat the
swaras as chords.

**Fix.** Copy `raga`, `tala` and `tradition` too. Tests for both paths.

### A5. Import preview formats songs to text and parses them again (lossy)

**Issue.** `ImportPreviewScreen._performImport` turns the selected songs back
into ChordPro text with `formatMultiple`, then `ImportService` parses that text
again. Anything the format/parse round trip does not keep exactly (for example
a `tradition` decided by the first parse, or text that looks like a directive)
can change between the preview and what is saved.

**Fix.** Add `ImportService.importSongs(List<SongNote> songs, …)` that saves
the already-parsed songs. `importContent` becomes "parse, then
`importSongs`". The preview calls `importSongs` with the songs the user saw.
Tests.

### A6. UTF-16 file import can crash

**Issue.** `decodeImportedBytes` (in `import_export_screen.dart`) uses
`Uint16List.view(buffer, offsetInBytes + 2, …)`. A `Uint16List` view must start
on an even byte offset. If the picker hands over bytes at an odd offset, this
throws, and the import fails. It also depends on the phone's byte order.

**Fix.** Decode UTF-16 LE by hand (like the BE branch already does). Move the
function to `lib/core/utils/text_decoding.dart` (it is not UI code) and add
`test/core/utils/text_decoding_test.dart`: UTF-8, UTF-8 BOM, UTF-16 LE/BE, odd
offset, odd length, empty.

### A7. No size limit on imported files

**Issue.**

- The picker import (`withData: true`) and the file-open import (Kotlin
  `readText()`) read the whole file, however big. The file-open intent filter
  also accepts `application/octet-stream` and `*/*`, so any large file can be
  sent in. A big file can run the app out of memory.
- The Kotlin side reads the file on the main thread, which can freeze the app
  (ANR) for a slow or large file.
- `FileIntentListener` swallows every error, so a failed open shows nothing.

**Fix.**

- One limit, `AppConstants.maxImportFileBytes` = 5 MB (a chord sheet is a few
  KB; 5 MB is very generous).
- Picker import: skip files over the limit and show a `SnackBar` naming them.
- Kotlin: read on a background thread, stop after the limit, and return
  `{"error": "too_large"}` or `{"error": "unreadable"}`; reply on the main
  thread.
- `FileIntentListener`: show a `SnackBar` for those errors and for "no songs
  found", using a root `ScaffoldMessengerKey` added to `MaterialApp.router`.
- Tests for the size check helper and the listener's error handling.

### A8. AirQR accepts frames with impossible numbers

**Issue.** `AirQrFrame.parse` trusts `totalBlocks`, the sequence index and
parity indices from the QR code. A bad or foreign code with an index outside
`0..totalBlocks-1`, or a huge `totalBlocks`, can make the receiver count junk
blocks as received ("complete" but reassembly fails, so it gets stuck), or
loop over a huge range.

**Fix.** Reject a frame unless `1 <= totalBlocks <= 4096` (well above any song
size), every index is in range, the degree matches the index count, and the
payload is not empty. Tests in `air_qr_service_test.dart`.

---

## Part B — Needs your decision (not changed until you choose)

### B1. Camera, biometric and ringer features vs the project rules

`CLAUDE.md` says: "Request **no** runtime permissions — no camera …", and
`docs/security.md` says "Do not add camera … permissions". But the app now has:

- **AirQR receive** — uses the camera (`mobile_scanner`, a runtime camera
  permission) and the photo picker (`image_picker`).
- **Stage Lock** — `local_auth` (biometric, install-time permission).
- **Stage Quiet Mode** — changes the phone's ringer (a system setting).

The code and the rules disagree. Choose one:

1. **Keep the features, update the docs** — I update `docs/security.md`,
   `docs/dependencies.md` and the security section of `CLAUDE.md`/`AGENTS.md`
   to say exactly which permissions are allowed and why (camera only for
   AirQR, asked only when the user opens the scanner).
2. **Remove the features** — take out AirQR receive, Stage Lock and/or Quiet
   Mode and their packages, to match the current rules.

### B2. Palette described differently in the docs

`docs/lyriccord_idea.md` and the `CLAUDE.md` table say a violet palette
(`#6750A4` / `#D0BCFF`). The code and `docs/features.md` use blue `#0052CC`
(light) and amber `#FFD54F` (dark). I think the code is the intended current
look, so I would update `docs/lyriccord_idea.md` §4 to match. Please confirm.

---

## Part C — Proposed as separate later plans (not in this one)

### C1. Localization is mostly not done

`CLAUDE.md` says every user-visible string must come from `lib/l10n/*.arb`.
`app_en.arb` has about 11 keys. About 280 raw UI strings remain across ~40
screens and widgets (biggest: `song_performance_screen.dart` 31,
`song_list_screen.dart` 24, `setlist_detail_screen.dart` 17), plus all of
`help_content.dart`. This is a large, mostly mechanical change. I suggest its
own plan, done screen by screen.

### C2. PDF export file name (old plan still waiting)

`plans/20260724_214500_pdf-save-dialog-filename.md` is still
`approval_pending`. Malayalam PDF names still show as `%E0%B4…`. It should be
approved or dropped separately.

---

## Files to change (Part A)

- `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt` (A1, A3, A7)
- `android/app/src/main/res/values/styles.xml`, `values-night/styles.xml` (A1)
- `android/app/src/main/AndroidManifest.xml` (A3: `ACCESS_NOTIFICATION_POLICY`)
- `android/app/build.gradle.kts` (A1, only if AppCompat is missing)
- `ios/Runner/Info.plist` (A1, A2)
- `lib/services/stage_security_service.dart` (A1)
- `lib/services/stage_quiet_mode_service.dart` (A3)
- `lib/providers/stage_mode_provider.dart` (A1, A3)
- `lib/screens/song_performance_screen.dart` (A1 SnackBar, A3 dispose)
- `lib/widgets/scroll_gesture_layer.dart`, `lib/widgets/stage_hud.dart` (A1, A3 feedback / hide on iOS)
- `lib/services/import_service.dart` (A4, A5)
- `lib/screens/import_preview_screen.dart` (A5)
- `lib/screens/import_export_screen.dart` (A6, A7)
- `lib/core/utils/text_decoding.dart` (new, A6)
- `lib/core/constants/app_constants.dart` (A7)
- `lib/widgets/file_intent_listener.dart` (A7)
- `lib/main.dart` or `lib/core/router/app_router.dart` (A7: root messenger key)
- `lib/models/air_qr_frame.dart`, `lib/services/air_qr_service.dart` (A8)
- `lib/l10n/app_en.arb` (+ regenerated l10n files) — all new messages go here
- Tests: `test/services/stage_security_service_test.dart`,
  `test/providers/stage_mode_provider_test.dart`,
  `test/services/import_service_test.dart`,
  `test/core/utils/text_decoding_test.dart` (new),
  `test/services/air_qr_service_test.dart`,
  a file-intent listener test (new), `test/screens/import_preview_screen_test.dart`
- Docs: `docs/security.md`, `docs/features.md` (describe the new limits and
  behaviour; B1/B2 doc edits only if you approve them)

No files in the `docs/guidelines/` submodule are touched.

## Checks after the change

- `dart run build_runner build` is not needed (no drift schema change).
- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass).
- `flutter build apk --flavor dev --debug` to prove the Kotlin and theme
  changes compile; then `gradlew --stop` and end any leftover Gradle/Kotlin
  daemons.
- Note: the Stage Lock prompt, Quiet Mode and AirQR camera need a manual check
  on a real phone (I cannot run those here). iOS changes need a Mac to build.

## Change log

`change_log/<timestamp>_robustness-gap-fixes.md` after the work.
