# Release Process — LyricCord

This is the app-specific release process for LyricCord. It fills in the shared
template at [guidelines/release_process.md](guidelines/release_process.md) with the
real values for this app. The local copy wins over the template (CLAUDE.md).

Read alongside:

- [../CLAUDE.md](../CLAUDE.md) — build/run commands, signing, security rules.
- [guidelines/guideline.md](guidelines/guideline.md) §2 — keystore + `key.properties`.
- [security.md](security.md) — the offline (no-INTERNET) posture.

---

## 1. Release scope

- App: **LyricCord** (`in.sreerajp.lyriccord`)
- Release profile: **not yet shipping** (preparing the first release)
- Supported release platforms: **Android** (iOS later)
- Fully **offline**: no INTERNET permission, no network packages (hard rule 1).

---

## 2. Versioning

- Version format: `MAJOR.MINOR.PATCH+BUILD`.
- Source of truth: `pubspec.yaml` (`version:`). Currently `1.0.0+1`.
- Bump the build number (`+N`) on every store upload; bump `PATCH`/`MINOR`/`MAJOR`
  as the change warrants.
- Git tag format: `vX.Y.Z`.

---

## 3. Signing keystore (one-time setup)

The release build is signed from `android/key.properties`, which points to the
keystore. **Both files are git-ignored and must never be committed.** The build
falls back to the debug key only when `android/key.properties` is absent, so a
fresh checkout still builds.

### 3.1 Create the keystore

Choose a filename for the keystore (e.g. `lyriccord-release.jks`) and create it in
the `android/` folder:

```bash
keytool -genkey -v \
  -keystore android/lyriccord-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias lyriccord
```

Answer the prompts and choose strong passwords. **Back the keystore up offline** —
losing it means you can never publish an update under the same signature.

### 3.2 Create `android/key.properties`

Create `android/key.properties` (never commit it):

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=lyriccord
storeFile=lyriccord-release.jks
```

`storeFile` is the keystore filename from §3.1. The Gradle config resolves it with
`rootProject.file(...)`, i.e. relative to the `android/` folder, so the bare
filename is correct when the keystore sits in `android/`.

### 3.3 Verify it is ignored

`.gitignore` already lists `android/key.properties`, `android/*.jks`, and
`android/*.keystore`. Confirm with:

```bash
git status --porcelain android/key.properties android/*.jks
```

Neither file should appear. If either does, stop and fix `.gitignore` first.

---

## 4. Pre-release checks

Run all of these from the project root; every one must pass:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate drift code
dart format --output=none --set-exit-if-changed .          # formatting is clean
flutter analyze                                            # zero warnings
flutter test                                               # all tests pass
```

Then do a manual run of every feature (list, search, star, delete, editor with the
chord inserter, performance view transpose + font + swipe, both auto-scroll modes,
chord reference dialog, import, and both exports).

---

## 5. Build the release artifacts

Split-per-ABI APKs (sideload / direct install):

```bash
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod/ --split-per-abi
```

Play Store app bundle:

```bash
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod/
```

The outputs land in the `prodRelease` folders, e.g.
`build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk` and
`build/app/outputs/bundle/prodRelease/app-prod-release.aab`.

Keep the `build/symbols/` output for de-obfuscating crash traces later (it is
git-ignored).

---

## 6. Verify the offline posture on the artifact (mandatory)

The app must ship with **no INTERNET permission**. Verify it on the built APK:

```bash
aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk
```

The output must **not** contain `android.permission.INTERNET` (nor any other
runtime permission). If it does, stop and find which package pulled it in before
shipping (security.md).

---

## 7. Release checklist

- [ ] `pubspec.yaml` version + build number bumped.
- [ ] Keystore created, backed up offline, and `android/key.properties` in place.
- [ ] `key.properties` / `*.jks` are **not** tracked by git.
- [ ] `dart format`, `flutter analyze`, and `flutter test` all clean.
- [ ] Manual run of every feature passed.
- [ ] Release APK/bundle built with `--obfuscate --split-debug-info`.
- [ ] `aapt2 dump permissions` shows **no INTERNET** (and no runtime permissions).
- [ ] Git tagged `vX.Y.Z`; `build/symbols/` archived for this version.
