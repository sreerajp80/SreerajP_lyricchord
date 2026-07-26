# Security — SreerajP_lyricchord

This is a short security posture for LyricChord. Read it before adding any
permission, package, or feature that touches the network, the file system, or
device data. LyricChord is a fully offline, local-only app, so its security story
is small — this file records the rules that keep it that way.

**Read first**

- [architecture.md](architecture.md) — §7 Offline Behavior, §14 Persistence.
- [guidelines/security.md](guidelines/security.md) — the full Sensitive-Data
  blueprint template. It is **not** filled in for this app (see §1 below).

---

## 1. Applicability

The `Sensitive Data Extension` **does not apply** to LyricChord. The app stores
only user-written song sheets (title, artist, lyrics, key, BPM, favorite flag)
in a local database. There are no secrets, credentials, PII, health, or finance
data, and no encryption requirement. So the full blueprint in
[guidelines/security.md](guidelines/security.md) is not completed; this short
file is the whole security story. If the app ever gains accounts, sync, or
sensitive data, fill in that blueprint at that time.

---

## 2. Offline boundary

- The app is **fully offline** and makes no network calls.
- The Android release manifest MUST NOT contain
  `<uses-permission android:name="android.permission.INTERNET" />`.
- No package that performs network I/O may be added. Verify on the built
  artifact, not just the source:

  ```bash
  aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
  ```

  The output must not list `android.permission.INTERNET`.

> **Rule:** any change that would add a network permission or a networking
> package is a security change. Stop and reconsider — LyricChord has no feature
> that needs the network.

---

## 3. Minimal permissions

- The app needs **no runtime permissions**. Import and export use the system
  file picker / share sheet, which grant access to the chosen file only — no
  broad storage permission is requested.
- Do not add camera, location, contacts, microphone, or storage permissions;
  no feature uses them.

---

## 4. Input validation (imported files)

The only untrusted input is an imported ChordPro/text file.

- Parse defensively: treat any unrecognized directive or malformed line as plain
  lyric text; never crash on bad input.
- Missing fields fall back to safe defaults (title "Untitled Song", key "C",
  BPM 120), matching the Android app.
- Import failures surface as a `SnackBar` and abort the import; they never
  corrupt the existing database.
- Cap the accepted file to a sensible size so a huge file cannot hang the UI.

---

## 5. Data handling & storage

- All song data lives in the local `drift` (SQLite) database; the single setting
  (theme mode) lives in `shared_preferences`. Nothing leaves the device.
- No sensitive data is logged; song content is not logged in release builds
  (see [architecture.md](architecture.md) §17).
- Signing secrets (keystore, `key.properties`) are never committed — see the
  keystore rules in [guidelines/guideline.md](guidelines/guideline.md) §2.

> **Secrets warning:** keep the release keystore backed up offline. Losing it
> means you can no longer publish updates under the same signature. Never commit
> `android/key.properties`, `android/*.jks`, or `android/*.keystore`.

---

## 6. Checklist

- [ ] No `INTERNET` permission in the built release artifact.
- [ ] No networking packages in `pubspec.yaml`.
- [ ] No runtime permissions requested.
- [ ] ChordPro import cannot crash the app or corrupt the database.
- [ ] Keystore and `key.properties` are git-ignored and backed up offline.
