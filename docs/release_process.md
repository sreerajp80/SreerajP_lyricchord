# Release Process — LyricChord

This document defines the app-specific release runbook for LyricChord. It fills in the
shared template at [guidelines/release_process.md](guidelines/release_process.md) with
concrete values, commands, and security hardening checks for this app.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — build/run commands, signing, and security rules.
- [workflow_rules.md](workflow_rules.md) — pre-release planning and verification rules.
- [dependencies.md](dependencies.md) — approved packages and offline boundary.
- [security.md](security.md) — minimal permissions and offline security posture.
- [guidelines/guideline.md](guidelines/guideline.md) §2 — keystore and signing rules.

---

## 1. Release Scope

- App name: **LyricChord**
- Package ID / Application ID: `in.sreerajp.lyricchord` (flavor `prod`)
- Dev Application ID: `in.sreerajp.lyricchord.dev` (flavor `dev`)
- Platforms: **Android** (iOS scheduled for subsequent release)
- Connectivity: **Strictly offline** — zero network permissions or packages.

---

## 2. Versioning

- Version format: `MAJOR.MINOR.PATCH+BUILD`.
- Source of truth: `pubspec.yaml` (`version:`). Currently `2.6.10+34`.
- Increment the build number (`+N`) on every build artifact; bump `PATCH`/`MINOR`/`MAJOR`
  following semantic versioning.
- Git release tag format: `vX.Y.Z` (e.g., `v2.6.10`).

---

## 3. Signing Keystore (One-Time Setup)

Production release artifacts are signed using `android/key.properties`, which points to the
release keystore file. **Both files are git-ignored and must NEVER be committed.**

### 3.1 Create the Keystore

Create the release keystore in the `android/` directory:

```bash
keytool -genkey -v \
  -keystore android/lyricchord-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias lyricchord
```

> **Important:** Store the keystore and passwords in a secure offline vault. Losing the
> keystore means you cannot publish updates to existing users under the same signature.

### 3.2 Create `android/key.properties`

Create `android/key.properties` (stored locally only, never committed):

```properties
storePassword=<store-password>
keyPassword=<key-password>
keyAlias=lyricchord
storeFile=lyricchord-release.jks
```

Verify that git ignores both files:

```bash
git status --porcelain android/key.properties android/*.jks
```

Output must be completely empty.

---

## 4. Pre-Release Verification

Run the complete verification pipeline from the project root:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

All static analysis checks must be clean (0 issues) and all unit/widget tests must pass.

---

## 5. Build Hardened Release Artifacts

Every production release MUST be hardened with `--release`, `--obfuscate`, and
`--split-debug-info`.

### 5.1 Split APKs (Direct Distribution / Sideloading)

**Bash / macOS / Linux:**
```bash
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info="build/symbols/android-prod-$VERSION/" \
  --split-per-abi
```

**PowerShell (Windows):**
```powershell
$VERSION = (Get-Content pubspec.yaml | Select-String '^version:').ToString().Split(' ')[1].Trim()
flutter build apk `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/" `
  --split-per-abi
```

Artifacts are produced in `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-prod-release.apk`
- `app-armeabi-v7a-prod-release.apk`
- `app-x86_64-prod-release.apk`

### 5.2 App Bundle (Google Play Store)

**Bash / macOS / Linux:**
```bash
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2)
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info="build/symbols/android-prod-$VERSION/"
```

**PowerShell (Windows):**
```powershell
$VERSION = (Get-Content pubspec.yaml | Select-String '^version:').ToString().Split(' ')[1].Trim()
flutter build appbundle `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/"
```

Artifact is produced at:
`build/app/outputs/bundle/prodRelease/app-prod-release.aab`

---

## 6. Post-Build Security Audit

### 6.1 Confirm Zero Network Permissions
Verify that no `INTERNET` permission exists in the compiled binary:

```bash
aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk
```
The output must NOT contain `android.permission.INTERNET`.

### 6.2 Confirm Backup and Debug Flags
Verify `android:allowBackup="false"` and `android:debuggable="false"` in the merged manifest:

```bash
aapt2 dump badging build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk | grep -i debuggable
aapt2 dump xmltree build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk --file AndroidManifest.xml | grep -i allowBackup
```

### 6.3 Audit Packaged Assets
Audit the bundled assets to guarantee no secrets, credentials, or unneeded files were packaged:

```powershell
tar -tf build\app\outputs\flutter-apk\app-arm64-v8a-prod-release.apk | Select-String "assets/"
```

---

## 7. Release Checklist

- [ ] `pubspec.yaml` version and build number updated.
- [ ] Keystore verified, backed up offline, and `android/key.properties` ignored by git.
- [ ] `dart format`, `flutter analyze`, and `flutter test` all clean.
- [ ] Built with `--release`, `--obfuscate`, and `--split-debug-info`.
- [ ] `aapt2 dump permissions` confirms zero `INTERNET` permission.
- [ ] Merged manifest verified for `android:allowBackup="false"` and `android:debuggable="false"`.
- [ ] Asset audit passed — no credentials, keys, or unexpected files bundled.
- [ ] Debug symbols in `build/symbols/` archived securely to correspond with this version tag.
- [ ] Git commit tagged `vX.Y.Z` and pushed.
