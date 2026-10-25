# LyricChord

A lyrics & chords notebook for musicians — write chord sheets, transpose, and auto-scroll while
performing. LyricChord is a Flutter port of an existing Android app. It is **fully offline**: it
has no network permission and sends nothing anywhere.

- Product idea and features: [docs/lyriccord_idea.md](docs/lyriccord_idea.md),
  [docs/features.md](docs/features.md)
- Project choices (platforms, stores, languages): [docs/PROJECT_PROFILE.md](docs/PROJECT_PROFILE.md)
- Rules for contributors and AI agents: [CLAUDE.md](CLAUDE.md), [AGENTS.md](AGENTS.md)
- Privacy: [PRIVACY.md](PRIVACY.md)

---

## 1. Prerequisites

| Tool | Version |
|------|---------|
| Flutter | 3.47.6 (stable) — the version CI uses |
| Dart | 3.13.5 (comes with Flutter) |
| Java (JDK) | 17 or later, for the Android build |
| Android SDK | The `compileSdk` / `targetSdk` that Flutter sets (`flutter.compileSdkVersion`); `minSdk 24` |
| iOS | Not declared yet. Needs a Mac with a current Xcode; the deployment target must be raised from 13.0 to at least 14.0 (needed by `file_picker`) |

Check your setup with `flutter doctor`.

## 2. Setup from a clean clone

```bash
git clone --recurse-submodules <repository-url>
```

The `docs/guidelines/` folder is a read-only git submodule with the shared Flutter guidelines.
If you cloned without `--recurse-submodules`, fill it with:

```bash
git submodule update --init
```

Then install the packages:

```bash
flutter pub get
```

## 3. Run the app

Android has two flavors, so a bare `flutter run` fails on Android — always pass `--flavor`:

```bash
flutter run --flavor dev
```

The `dev` flavor installs as `in.sreerajp.lyricchord.dev` ("LyricChord Dev") next to the
production app. iOS has no flavor schemes yet; run iOS without `--flavor`.

No `--dart-define` values are needed.

## 4. Tests and checks

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
bash tool/check_sanskrit_hindi_markers.sh   # no Hindi in Sanskrit text
```

CI runs the same checks on every pull request (`.github/workflows/ci.yml`). CI never builds or
signs release artifacts.

## 5. Code generation

Run this after changing a drift table or query in `lib/data/`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run this after changing `lib/l10n/app_en.arb`:

```bash
flutter gen-l10n
```

**Generated files are committed** (engineering standard §12.2, Option A): `*.g.dart` and the
generated `lib/l10n/app_localizations*.dart`. Regenerate and commit them with every change to
their source. CI fails if they are stale. Never edit them by hand.

`lib/core/constants/app_version.g.dart` and `build_date.g.dart` are written by
`tool/generate_app_version.dart` and `tool/generate_build_date.dart`; the Android Gradle build
runs both automatically.

## 6. Add a database migration

1. Change the table in `lib/data/app_database.dart`.
2. Raise `schemaVersion` by one.
3. Add an `if (from < <new version>) { ... }` step in `onUpgrade`. Never change a step that has
   already shipped.
4. Run `build_runner` (§5).
5. Extend `test/data/app_database_migration_test.dart` so it upgrades from version 1 to the new
   version.
6. Update the schema table in [docs/architecture.md](docs/architecture.md) §11.

## 7. Release builds

Release builds are made locally, never in CI. Full runbook: [docs/release_process.md](docs/release_process.md).

```bash
# Android split APKs
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/ --split-per-abi

# Android App Bundle (Google Play)
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/

# iOS (on a Mac)
flutter build ipa --release \
  --obfuscate --split-debug-info=build/symbols/ios-<version>/
```

`<version>` is the full `pubspec.yaml` version, for example `2.6.13+37`. Signing needs
`android/key.properties` and the release keystore, which are never committed.
