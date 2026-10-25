# Security — LyricChord

This is the security posture for LyricChord. Read it before adding any permission,
package, or feature that touches the network, the file system, or device data.
LyricChord is a fully offline, local-only app, so its security story is small — this
document records the rules that keep it that way.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — project security and offline rules.
- [architecture.md](architecture.md) — §7 Offline Behavior, §14 Persistence.
- [dependencies.md](dependencies.md) — approved packages and offline boundary.
- [guidelines/security.md](guidelines/security.md) — the full Sensitive-Data blueprint template.

---

## 1. Applicability

The `Sensitive Data Extension` **does not apply** to LyricChord. The app stores
user-written song sheets (title, artist, lyrics, key, BPM, favorite flag, notes) in a
local database. There are no secrets, credentials, PII, health, or finance data, and no
encryption requirement.

If the app ever gains user accounts, cloud sync, or sensitive payment features, the full
blueprint from [guidelines/security.md](guidelines/security.md) must be completed.

---

## 2. Offline Boundary

- The app is **fully offline** and makes no network calls.
- The Android release manifest MUST NOT contain
  `<uses-permission android:name="android.permission.INTERNET" />`.
- No package that performs network I/O may be added. Verify on the built artifact:

  ```bash
  aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk
  ```

  The output must not list `android.permission.INTERNET` or
  `android.permission.ACCESS_NETWORK_STATE`.
- **Known source of both:** ML Kit (used by `mobile_scanner` for AirQR) brings in
  Google's usage logger, `com.google.android.datatransport`, which adds both
  permissions. `android/app/src/release/AndroidManifest.xml` removes them, and
  the logger's backend-discovery service, from every release build. Do not delete
  that file. Debug and profile builds keep `INTERNET` for hot reload.
- After adding or updating any package, re-check the merged manifest
  (`build/app/outputs/logs/manifest-merger-<flavor>-release-report.txt`) for new
  network permissions coming from libraries.

> **Rule:** Any change that adds a network permission or a networking package is a
> critical security change. LyricChord has no feature that requires network connectivity.

---

## 3. Minimal Permissions

The app asks for nothing at start-up and nothing during ordinary use. File
import and export use the platform file picker and system share sheet, which
grant scoped access only to the chosen document.

These are the **only** permissions allowed. Each one belongs to a feature the
user turns on themselves:

| Permission | Kind | Feature | When it is used |
|------------|------|---------|-----------------|
| `CAMERA` (Android) / `NSCameraUsageDescription` (iOS) | Runtime prompt | AirQR receive (`mobile_scanner`) | Only when the user opens the AirQR scanner. Frames are read on the device; nothing is saved or sent. |
| Photo picker / `NSPhotoLibraryUsageDescription` (iOS) | System picker | AirQR "scan from photo" (`image_picker`) | Only the one photo the user picks is read, to find a QR code in it. |
| `USE_BIOMETRIC` (Android, added by `local_auth`) / `NSFaceIDUsageDescription` (iOS) | Install-time | Stage Lock (`local_auth`) | Only when unlocking Stage Lock. The check runs on the device; the app never sees fingerprints or the PIN. |
| `ACCESS_NOTIFICATION_POLICY` (Android) | Install-time + a system setting the user grants | Stage Quiet Mode | Lets the user grant "Do Not Disturb access" so Quiet Mode can silence the ringer. Not offered on iOS. |

Rules for these features:

- **Stage Lock must never trap the user.** It guards against accidental touches,
  not against another person. If the check cannot run (no screen lock, no
  hardware, lockout, platform error), the stage unlocks. Only a user who backs
  out of or fails the prompt stays locked.
- **Quiet Mode must never leave the phone silent.** The previous ringer mode is
  saved to disk before it is changed, and put back when Stage Mode ends, when the
  song is left, when the app closes, and on the next start after a crash. The
  Quiet Mode icon shows "on" only when the phone confirmed the ringer is silent.
- Do not add location, contacts, microphone, or storage permissions.
- Any new permission is a security change: add it to this table first, with its
  reason, and get approval.

---

## 4. Input Validation (Imported Files)

The only untrusted input is an imported ChordPro or text file, text shared from
another app, or a scanned AirQR code:

- Parse defensively: treat any unrecognized directive or malformed line as plain lyric
  text; never crash on bad input.
- Missing fields fall back to safe defaults (title "Untitled Song" in the user's
  language, key "C", BPM 120).
- A binary file (a photo, a PDF, an archive) is refused as unreadable, never saved
  as a song. `looksLikeBinary` in `lib/core/utils/text_decoding.dart` checks the
  first 8 KB: a zero byte, or more than 10 % of the text failing to decode, means
  binary. A UTF-16 file with a byte-order mark is text.
- The app is offered for opening only ChordPro and text files: the by-name
  intent filter has `host="*"` (without a host Android ignores path rules and the
  filter matches every file) and uses `pathPattern` (works from Android 7).
- Text shared from another app (`EXTRA_TEXT`) and several shared files
  (`SEND_MULTIPLE`) go through the same size limit and checks as a single file;
  several files are joined with `{new_song}`, and the limit applies to the total.
- Import failures surface as a `SnackBar` and abort cleanly; they never corrupt the
  database.
- File size is capped at 5 MB (`AppConstants.maxImportFileBytes`, and the same
  value in `MainActivity` for files opened from other apps). Larger files are
  refused with a `SnackBar`. Files opened from other apps are read off the main
  thread.
- Text is decoded as UTF-8 or UTF-16 (with a byte-order mark) without ever
  throwing (`lib/core/utils/text_decoding.dart`).
- **AirQR codes** are untrusted too. A frame is accepted only when its block
  count is 1–4096, every index is inside the stream, and its checksum matches;
  anything else is ignored (`AirQrFrame.isValid`).

---

## 5. Data Handling & Storage

- All song data lives in the local `drift` (SQLite) database; display settings live in
  `shared_preferences`. Nothing leaves the device.
- `android:allowBackup="false"` is set on `<application>` in `AndroidManifest.xml` to
  prevent unencrypted ADB backups of the local database.
- Song content is never logged. All logging goes through `AppLogger`: `trace`/`debug`
  only in the dev flavor, and prod release builds log an error by its type only, never
  its message. Logs go to the console only; nothing is written to disk.
- Signing keystores and `android/key.properties` are git-ignored and never committed.

> **Secrets warning:** Keep the release keystore backed up securely offline. Losing it
> means you can no longer publish updates under the same signature.

---

## 6. Data Retention And Purge Policy

This is the retention policy the engineering standard asks for in §15.4 (template section 13).

### 6.1 Retention Schedule

| Data | Where | How long it is kept | What deletes it |
|------|-------|---------------------|-----------------|
| Songs, setlists, notes | drift database in the app documents folder | Until the user deletes them | Deleting the song/setlist in the app; uninstalling the app |
| Settings | `shared_preferences` | Until changed | Uninstalling the app |
| Audio clips for the metronome, pitch drone and melody player | App temp folder | Rewritten on next use; the OS may clear them any time | The OS; uninstalling the app |
| PDF / ChordPro export files | Handed to the share sheet or file picker | Not kept by the app after the share | The receiving app or the user |
| Logs | Not written to disk | — | — |

### 6.2 Purge Implementation

- Uninstalling the app removes the database, preferences and temp files (Android and iOS app
  sandbox).
- **Settings → Delete all data** (standard §15.4) removes everything the app keeps, after a
  confirm dialog with a "Delete everything" button. `DataPurgeService`
  (`lib/services/data_purge_service.dart`) closes the database, deletes the database file
  (with its `-wal`, `-shm` and `-journal` files), clears every saved setting, and empties the
  temporary folder (audio clips, export files). Every step runs even if an earlier one fails;
  any failure is logged and shown as a message. The app then starts again as on first
  install, with its sample songs. There are no log files and no secure storage to clear.

### 6.3 Backup

- Android: `android:allowBackup="false"`, so the data is not in Android cloud backup.
- iOS: the database lives in the documents folder, which the user's own iCloud or computer
  backup may include. No sensitive data is stored, so this is accepted.

---

## 7. Security Checklist

- [ ] No `INTERNET` permission in the built release artifact.
- [ ] No networking packages in `pubspec.yaml`.
- [ ] No broad storage or location runtime permissions requested.
- [ ] Only the permissions in §3 appear in the merged manifest and `Info.plist`.
- [ ] `android:allowBackup="false"` verified in `AndroidManifest.xml`.
- [ ] ChordPro import handles bad syntax safely without crashing.
- [ ] Keystore and `key.properties` are git-ignored and backed up offline.
- [ ] Data retention and purge behaviour still matches §6.
