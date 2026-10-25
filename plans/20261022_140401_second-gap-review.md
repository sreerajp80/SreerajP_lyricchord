# Plan: Second whole-app gap review

**Status:** completed

## Background

A second review after
[20261022_115802_robustness-gap-fixes.md](20261022_115802_robustness-gap-fixes.md)
and
[20261022_133507_remove-mlkit-internet-permission.md](20261022_133507_remove-mlkit-internet-permission.md).

What is already good:

- `flutter analyze`: no issues. `flutter test`: 943 tests, all pass.
- No stubs in the Dart code. A search for `TODO`, `FIXME`, `UnimplementedError`,
  empty button handlers and "coming soon" text found only:
  - `databaseProvider` and `themeModeProvider` throw `UnimplementedError`. This
    is the normal Riverpod pattern: `main.dart` always overrides them with the
    real database and settings. Not a stub.
  - The word "stub" in two comments in `app_database.dart`, about the old
    sample song text that a past migration already replaced.
- Every feature in `docs/lyriccord_idea.md` §2 has code and tests (songbook,
  editor, performance view, transpose, auto-scroll, chord reference, ChordPro
  and PDF import/export, theme, tablet dual pane at 600 dp).

The gaps found are below.

---

## Part A — Fix in this plan

### A1. AirQR receiver hides a failed transfer

**Issue.** When all blocks arrive but the song cannot be rebuilt,
`AirQrService` returns `AirQrStatus.error` with an `errorMessage`. The receiver
screen never shows it: the status line falls back to "POINT AT ANIMATED QR CODE
STREAM" and the bar sits at 100 %. Every later frame gives the same error, so
the user is stuck and does not know why, or that they must tap Reset.

**Fix.**

- The HUD shows a clear error line in red when the status is `error` ("Transfer
  failed. Tap reset and scan again.").
- Show a `SnackBar` once with a **Reset** action that calls `resetStream()`.
- Widget test: an error state shows the message and Reset clears it.

### A2. File-picker import skips unreadable files without saying so

**Issue.** In `import_export_screen.dart`, if a chosen file cannot be read
(`catch (_) {}`), or the picker gives no bytes and no path, the file is skipped
silently. With several files chosen, the user is not told that one was left out.

**Fix.** Collect those file names and show them in a `SnackBar` ("Could not
read: …"), the same way files over the size limit are already reported. New
string in `app_en.arb`.

### A3. Feature doc contradicts the code

**Issue.** `docs/features.md` §2.8 says the shake mark `~` is "still drawn but
silent", and that slide and shake "are not yet sounded (phase 3)". Phase 3 is
done: `MelodyPlayerService` sounds both slides and shakes.

**Fix.** Update the two bullets to say both marks are sounded, and how.

### A4. Progress doc is out of date

**Issue.** `docs/implementation_progress.md` still says the no-`INTERNET`
check on a release artifact is not done. It was done today on the prod release
APK (see the ML Kit change log).

**Fix.** Tick that item and note the date and how it was checked. Leave
"signed build" and "run on a device" open, because those still need you.

---

## Part B — Needs your decision

### B1. Localization is mostly not done (largest gap)

`CLAUDE.md` says every user-visible string must come from `lib/l10n/*.arb`.
Today `app_en.arb` has 24 keys. About **400 hard-coded UI strings** remain in
45 screen and widget files. The biggest:

| File | Strings |
|------|---------|
| `song_performance_screen.dart` | 41 |
| `song_list_screen.dart` | 26 |
| `pitch_drone_settings_screen.dart` | 25 |
| `setlist_detail_screen.dart` | 24 |
| `import_preview_screen.dart` | 18 |
| `melody_keypad_sheet.dart`, `import_export_screen.dart` | 17 each |

Plus all of `help_content.dart` (about 1,100 lines of help text), and English
messages built inside services and exceptions.

The app still ships only English, so users see no difference. But it breaks a
project rule. Choose one:

1. **Separate plans, in batches** (recommended): one plan per group of screens
   (songbook, editor, performance, settings, metronome/drone, import/AirQR,
   help), each small enough to review.
2. **One big plan now.** Many files at once; harder to review.
3. **Change the rule** to "new code only" and leave old strings as they are.

### B2. PDF export file name (old plan still open)

[20260724_214500_pdf-save-dialog-filename.md](20260724_214500_pdf-save-dialog-filename.md)
is still `approval_pending`. Malayalam PDF names still show as `%E0%B4…` when
shared. Approve it, or mark it `dropped`.

---

## Part C — Known iOS gaps (need a Mac; only noted here)

- No iOS flavor schemes (`dev` / `prod`). Run iOS without `--flavor`.
- iOS cannot open a `.chordpro` file from the Files app ("Open in
  LyricChord"); `Info.plist` has no document types and `AppDelegate` has no
  file handler. Import through the in-app file picker works.
- Stage Quiet Mode is hidden on iOS (iOS does not let apps change the ringer).
  This is a platform limit, not a bug.

These need a Mac to build and test, so they are not in this plan.

---

## Files to change (Part A)

- `lib/screens/air_qr_receiver_screen.dart` (A1)
- `lib/screens/import_export_screen.dart` (A2)
- `lib/l10n/app_en.arb` + regenerated `lib/l10n/app_localizations*.dart` (A1, A2)
- `test/screens/air_qr_receiver_screen_test.dart` (new, A1)
- `docs/features.md` (A3)
- `docs/implementation_progress.md` (A4)

No files in the `docs/guidelines/` submodule are touched.

## Checks after the change

- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass).
- No Gradle build is needed (no Android or Kotlin change).

## Change log

`change_log/<timestamp>_second-gap-review.md` after the work.
