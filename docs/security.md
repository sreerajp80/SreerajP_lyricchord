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

  The output must not list `android.permission.INTERNET`.

> **Rule:** Any change that adds a network permission or a networking package is a
> critical security change. LyricChord has no feature that requires network connectivity.

---

## 3. Minimal Permissions

- The app requests **zero runtime permissions** during ordinary operation.
- File import and export use the platform file picker and system share sheet, which grant
  scoped access only to the selected document.
- Stage Lock mode utilizes the platform `local_auth` biometric prompt locally on-device.
- Do not add camera, location, contacts, or microphone permissions.

---

## 4. Input Validation (Imported Files)

The only untrusted input is an imported ChordPro or text file:

- Parse defensively: treat any unrecognized directive or malformed line as plain lyric
  text; never crash on bad input.
- Missing fields fall back to safe defaults (title "Untitled Song", key "C", BPM 120).
- Import failures surface as a `SnackBar` and abort cleanly; they never corrupt the
  database.
- File size is capped to prevent out-of-memory errors on massive documents.

---

## 5. Data Handling & Storage

- All song data lives in the local `drift` (SQLite) database; display settings live in
  `shared_preferences`. Nothing leaves the device.
- `android:allowBackup="false"` is set on `<application>` in `AndroidManifest.xml` to
  prevent unencrypted ADB backups of the local database.
- Song content is never logged in release builds; logs are gated behind `kDebugMode`.
- Signing keystores and `android/key.properties` are git-ignored and never committed.

> **Secrets warning:** Keep the release keystore backed up securely offline. Losing it
> means you can no longer publish updates under the same signature.

---

## 6. Security Checklist

- [ ] No `INTERNET` permission in the built release artifact.
- [ ] No networking packages in `pubspec.yaml`.
- [ ] No broad storage or location runtime permissions requested.
- [ ] `android:allowBackup="false"` verified in `AndroidManifest.xml`.
- [ ] ChordPro import handles bad syntax safely without crashing.
- [ ] Keystore and `key.properties` are git-ignored and backed up offline.
