# Release Process — LyricChord

This is the release runbook for LyricChord. Read it before building, signing or shipping a
release. It fills in the shared template
[guidelines/release_process.md](guidelines/release_process.md) with this app's values; the
section numbers match the template.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — build/run commands, signing, and security rules.
- [PROJECT_PROFILE.md](PROJECT_PROFILE.md) — platforms, stores, languages, identity.
- [security.md](security.md) — permissions, offline boundary, backup choice, data retention.
- [guidelines/guideline.md](guidelines/guideline.md) §2 — keystore and signing rules.
- [guidelines/platform_store_readiness.md](guidelines/platform_store_readiness.md) — the store gates.

---

## 1. Release Scope

- App: **LyricChord**
- Release profile: `public` (Google Play and direct APK)
- Supported release platforms (from [PROJECT_PROFILE.md](PROJECT_PROFILE.md) §3):
  - `Android` — channels: Google Play, direct APK
  - `iOS` — not decided yet (no channel)
- Store gates in force: [platform_store_readiness.md](guidelines/platform_store_readiness.md) §1
  and §2 (Google Play).
- Engineering standard profiles in force:
  - `Core Baseline`
  - `Production App Extension`
  - `Sensitive Data Extension` — **not** in force ([security.md](security.md) §1)
- Application id: `in.sreerajp.lyricchord` (`prod`); `in.sreerajp.lyricchord.dev` (`dev`)
- Connectivity: **strictly offline** — no network permission or package in a release build.

---

## 2. Roles And Responsibilities

| Role | Responsibility | Owner |
|------|----------------|-------|
| Release owner | Readiness and final sign-off | The app owner |
| Engineering | Code freeze, fixes, validation | The app owner |
| QA | Test execution and regression sign-off | The app owner |
| Store or distribution owner | Uploads artifacts and manages release metadata | The app owner |

---

## 3. Versioning Policy

- Version format: `MAJOR.MINOR.PATCH+BUILD`.
- Source of truth: `pubspec.yaml` (`version:`). `assets/config/app_config.json` `version` and
  `build` are kept equal to it.
- Build-number rule: `+BUILD` goes up by one for every artifact given to anyone, and is never
  reused — not even for a rejected or rolled-back build.
- Git tag format: `vX.Y.Z` (for example `v2.6.13`).

---

## 4. Branch And Merge Policy

- Release branch strategy: `master` only.
- Hotfix strategy: fix on `master`, bump `PATCH` and `BUILD`, release again.
- Required checks before merge: the CI checks in `.github/workflows/ci.yml` (format, analyze,
  test, generated files current). Every change follows plan → approve → log
  ([workflow_rules.md](workflow_rules.md)).

---

## 5. Environment And Flavor Matrix

| Flavor | Mode | Purpose | Example command |
|--------|------|---------|-----------------|
| `dev` | `debug` | Local development | `flutter run --flavor dev` |
| `dev` | `release` | Release-like QA, installs next to prod | `flutter build apk --flavor dev --release` |
| `prod` | `release` | Final release artifact | §9 (all hardening flags) |

- Android passes the flavor with `--flavor <name>` (Gradle product flavors, dimension
  `environment`).
- iOS has no flavor schemes yet. Build iOS without `--flavor` until the schemes are set up on a
  Mac.
- Never pass `FLUTTER_APP_FLAVOR` yourself.

---

## 6. Release Build Hardening

### 6.1 Obfuscation And Debug Symbols

Every production build uses `--release`, `--obfuscate` and
`--split-debug-info=build/symbols/<platform>-<flavor>-<version>/` (for example
`build/symbols/android-prod-2.6.13+37/`).

- Right after each build, copy the symbols folder to a secure archive **outside the repository**,
  next to the release artifact. Record where in §14.
- Keep the symbols for as long as that version is in use. Without them, stack traces from it can
  never be decoded (`flutter symbolize`).
- `build/` is git-ignored, so the symbols are never committed.

### 6.2 ProGuard / R8 (Android)

R8 runs on every Android release build. The app has no `android/app/proguard-rules.pro` today;
if one is added, it holds only rules a package documents. After adding any dependency, build and run a full release build:
classes reached only by reflection can be removed by R8 and fail only in release.

### 6.3 App Size Analysis

1. Record the size of every artifact you ship (and the download size the store reports).
2. Optional breakdown — a separate, throw-away build. Run it **before** the hardened build; never
   ship it:

```bash
flutter build apk --flavor prod --release --target-platform android-arm64 \
  --analyze-size --code-size-directory=build/size-analysis/android/
```

Budgets (engineering standard §10.7): APK arm64 < 30 MB (hard limit 50 MB); AAB download
< 20 MB (40 MB); iOS download < 40 MB (80 MB).

### 6.4 Debuggable And Backup Verification (Android)

The backup choice is recorded in [security.md](security.md) §5: `android:allowBackup="false"`.

```bash
# bash
APK="build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk"
aapt2 dump badging "$APK" | grep -i debuggable
aapt2 dump xmltree "$APK" --file AndroidManifest.xml | grep -i allowBackup
```

```powershell
# PowerShell
$APK = "build\app\outputs\flutter-apk\app-arm64-v8a-prod-release.apk"
aapt2 dump badging $APK | Select-String -Pattern "debuggable"
aapt2 dump xmltree $APK --file AndroidManifest.xml | Select-String -Pattern "allowBackup"
```

Expected: no `application-debuggable` line; `allowBackup` is false.

### 6.5 Network Permissions And Cleartext Traffic

The app is offline, so the rule is stronger than the template: **no network permission at all**.

```bash
aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk
```

The output must not list `android.permission.INTERNET` or
`android.permission.ACCESS_NETWORK_STATE`. Both come from ML Kit's usage logger (through
`mobile_scanner`) and are removed by `android/app/src/release/AndroidManifest.xml`. If either
shows up, check that file and the merge report in `build/app/outputs/logs/`.

### 6.6 Pre-Release Asset And Secret Leak Audit

```bash
# bash
unzip -l build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk "assets/*"
```

```powershell
# PowerShell
tar -tf build\app\outputs\flutter-apk\app-arm64-v8a-prod-release.apk | Select-String "assets/"
```

- [ ] No `.env`, keys, `.pem`, `.p12` or keystores in `assets/`.
- [ ] Only the expected assets: `assets/config/app_config.json`, `assets/fonts/`, Flutter's own files.

### 6.7 Exported Component Audit

In the app's own manifest only `MainActivity` is exported (it receives shared ChordPro/text
files). Check the merged release manifest: any component a plugin adds must not be exported
unless the plugin needs it, and nothing exported may accept data without validation.

---

## 7. Signing And Secret Handling

> Keystore location, `key.properties` naming and the `.gitignore` rules: see
> [guidelines/guideline.md](guidelines/guideline.md) §2 (the source of truth).

- Signing config: `android/key.properties` on the release owner's machine only. Never in git,
  never in CI.
- Rules:
  - Back up the keystore in at least two separate secure, offline places. Losing it means you can
    no longer publish updates under the same signature.
  - GitHub CI runs only checks and Dependabot; it never holds signing secrets.
  - Apple certificates and provisioning profiles follow the same rules
    ([guidelines/guideline.md](guidelines/guideline.md) §2.5).

### 7.1 Create the keystore (one time)

```bash
keytool -genkey -v \
  -keystore android/lyricchord-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias lyricchord
```

### 7.2 Create `android/key.properties` (one time)

```properties
storePassword=<store-password>
keyPassword=<key-password>
keyAlias=lyricchord
storeFile=lyricchord-release.jks
```

Check that git ignores both files — this must print nothing:

```bash
git status --porcelain android/key.properties android/*.jks
```

---

## 8. Release Checklist

### Code And Quality

- [ ] CI checks passed.
- [ ] `dart format --output=none --set-exit-if-changed .` passed.
- [ ] `flutter analyze` — zero issues.
- [ ] `flutter test` passed.
- [ ] Generated files current (`dart run build_runner build --delete-conflicting-outputs`,
      `flutter gen-l10n`).
- [ ] Release artifacts built locally, not in CI.
- [ ] Licenses checked if the release adds dependencies (engineering standard §16.6).

### Performance

- [ ] Primary flow (song list → performance view with auto-scroll) checked for jank in profile mode.
- [ ] App size recorded and within budget (§6.3).
- [ ] Cold start under 2 seconds on a mid-range device.

### Security

- [ ] `--obfuscate` and `--split-debug-info` on every release build.
- [ ] No `--analyze-size` build shipped or archived.
- [ ] Debug symbols archived for this version.
- [ ] No `INTERNET` / `ACCESS_NETWORK_STATE` permission (§6.5).
- [ ] `android:debuggable` absent/false and `android:allowBackup="false"` (§6.4).
- [ ] Asset audit passed (§6.6). Export audit passed (§6.7).
- [ ] Only the permissions in [security.md](security.md) §3 appear in the merged manifest and
      `Info.plist`.
- [ ] Data retention and purge behaviour matches [security.md](security.md) §6.

### Localization

Declared languages: English, Malayalam, Sanskrit ([PROJECT_PROFILE.md](PROJECT_PROFILE.md) §4).

- [ ] `app_en.arb`, `app_ml.arb` and `app_sa.arb` exist; the translation parity test passes.
- [ ] No English value left in `app_ml.arb` or `app_sa.arb`.
- [ ] Language pack checklist passes
      ([guidelines/language_packs/sanskrit_malayalam.md](guidelines/language_packs/sanskrit_malayalam.md) §7),
      including the Hindi-marker gate on Sanskrit (`bash tool/check_sanskrit_hindi_markers.sh`).
- [ ] New or changed Malayalam and Sanskrit strings reviewed by a fluent reader.
- [ ] Short labels within budget (20 characters English, 22 Malayalam and Sanskrit).
- [ ] Every screen opened in all three languages on a clean device — no boxes, no clipped
      Malayalam or Devanagari, no overflow.
- [ ] Language picker works: System default + `English` / `മലയാളം` / `संस्कृतम्`, persists, applies
      without restart.
- [ ] `bundle { language { enableSplit = false } }` is set in `android/app/build.gradle.kts`.
- [ ] Date picker and dialogs work under `sa` (fallback delegate).
- [ ] `test/l10n/no_hard_coded_ui_text_test.dart` passes.
- [ ] Every icon-only control has a localized tooltip.
- [ ] The About screen ends with the signature badge, localized and centered.

### Store Readiness (Every Declared Channel)

- [ ] [platform_store_readiness.md](guidelines/platform_store_readiness.md) §1 passes
      (privacy policy URL, support contact, data disclosure).
- [ ] Google Play: §2 gate — target API level re-checked, `versionCode` increased,
      App Bundle + Play App Signing, Data safety, listing and screenshots in English and
      Malayalam (`ml-IN`), internal testing and pre-launch report clean, staged rollout planned.
- [ ] Direct APK: signed with the release keystore; the same §1 rules (privacy policy, support
      contact) hold.

### Product And Documentation

- [ ] Version in `pubspec.yaml` and `assets/config/app_config.json` updated.
- [ ] Release notes written.
- [ ] User-visible behaviour changes reflected in Help and [features.md](features.md).

### Artifact Validation

- [ ] Artifact installs and launches on a clean device.
- [ ] Correct flavor: the prod app is named "LyricChord", not "LyricChord Dev".
- [ ] Version name and build number correct (About screen).
- [ ] Release build tested end to end, not only the debug build.

---

## 9. Android Release Steps

1. Pull the release commit; `git status` is clean.
2. Check the version in `pubspec.yaml`.
3. Run the checks below.
4. Optional: size-analysis build (§6.3) — before the hardened build.
5. Build the hardened artifacts; record their sizes.
6. Verify §6.4–§6.7.
7. Install and test on a device.
8. Archive `build/symbols/android-prod-<version>/` securely.
9. Complete the Google Play gate before uploading to Play.
10. Upload; tag the release: `git tag v<version>` and push.

**Bash:**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | tr -d '\r')

# Split APKs (direct distribution)
flutter build apk \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info="build/symbols/android-prod-$VERSION/" \
  --split-per-abi

# App Bundle (Google Play)
flutter build appbundle \
  --flavor prod \
  --release \
  --obfuscate \
  --split-debug-info="build/symbols/android-prod-$VERSION/"
```

**PowerShell:**

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

$VERSION = (Get-Content pubspec.yaml | Select-String '^version:').ToString().Split(' ')[1].Trim()

flutter build apk `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/" `
  --split-per-abi

flutter build appbundle `
  --flavor prod `
  --release `
  --obfuscate `
  --split-debug-info="build/symbols/android-prod-$VERSION/"
```

Artifacts:

- `build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk` (and the other ABIs)
- `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

After every build, stop the Gradle daemons (`android\gradlew --stop`) and end any leftover
`GradleDaemon` / `KotlinCompileDaemon` process.

---

## 10. iOS Release Steps

Status: iOS is not decided yet ([PROJECT_PROFILE.md](PROJECT_PROFILE.md) §3). These steps apply
only once it is declared.
iOS needs a Mac with the Xcode version App Store Connect currently requires.

1. Pull the release commit; `git status` is clean.
2. Check signing (Apple Distribution certificate, App Store profile for `in.sreerajp.lyricchord`).
3. Run the checks from §9.
4. Build (no `--flavor` until iOS schemes exist):

   ```bash
   flutter build ipa \
     --release \
     --obfuscate \
     --split-debug-info=build/symbols/ios-<version>/
   ```

5. Check `Info.plist` usage strings (camera, photo library, Face ID) against
   [security.md](security.md) §3, and the privacy manifest.
6. Archive the symbols; upload with Xcode Organizer or Transporter; test through TestFlight.
7. Complete the App Store gate, submit, and tag the release.

---

## 12. Distribution Channels

| Channel | Artifact | Audience | Notes |
|---------|----------|----------|-------|
| Google Play | `.aab` | Public | Staged rollout; gate §2 |
| Direct APK | split `.apk` | Users who install outside Play | Signed with the release keystore |

---

## 13. Rollback And Hotfix Process

- Rollback trigger: a crash or data-loss bug in the primary flow (songbook, editor, performance view).
- Rollback method: halt the staged rollout (Play) and ship a hotfix release; for direct APKs,
  publish the fixed APK with a higher build number.
- Verification: the full §8 checklist runs for hotfixes too, and their symbols are archived.

---

## 14. Release Evidence

Record after each release (locations only — no local machine paths in committed files):

- CI run:
- Test report:
- Size figures:
- Debug symbols archive:
- Built artifact:
- Release notes:
- Store submission or rollout record:

---

## 15. Post-Release Checks

- [ ] Post-install test of the shipped artifact on a clean device (offline app — no crash monitoring).
- [ ] User-reported issues triaged.
- [ ] Release tag created and pushed: `git tag v<version> && git push origin v<version>`.
- [ ] Debug symbols confirmed in the secure archive.
- [ ] Follow-up tasks recorded.
