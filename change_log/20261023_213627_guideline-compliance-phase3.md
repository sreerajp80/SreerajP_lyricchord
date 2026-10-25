# Change log: Guideline compliance — Phase 3 (material_ui migration)

Implements Phase 3 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)

## What changed

### Imports and packages

- `dart fix --apply --code=migrate_design_widgets` changed 92 files in `lib/` and `test/`
  from `package:flutter/material.dart` to `package:material_ui/material_ui.dart`. No
  generated file was touched. No `package:flutter/material.dart` or
  `package:flutter/cupertino.dart` import is left.
- `pubspec.yaml` — added `material_ui: ^1.8.0` (the tool wrote `any`; replaced with a caret
  range). The app uses no Cupertino widgets, so `cupertino_ui` is not a direct dependency
  (it comes in through `material_ui`).
- `go_router` `^17.3.0` → `^18.1.1`. **Why:** go_router decides the page type by looking for
  a `MaterialApp` above it. Version 17 looks for the SDK's `MaterialApp`, which is a
  different class from the `material_ui` one, so it fell back to pages with **no transition
  animation**. Version 18's only breaking change is "Migrates to material_ui and
  cupertino_ui", which fixes this. The app's routes use plain `builder:`, so no route code
  changed. This is a major-version update made because the approved migration would
  otherwise change how the app looks.

### Localization delegates

- New `lib/l10n/app_localizations_delegates.dart` with `appLocalizationsDelegates`:
  `AppLocalizations.delegate` plus `material_ui`'s `GlobalMaterialLocalizations.delegates`
  (which also holds the Cupertino and Widgets delegates), as engineering standard §8.1 asks.
  The generated `AppLocalizations.localizationsDelegates` list names the SDK's Material
  delegates, so it is no longer used.
- `lib/main.dart` and 27 widget-test files now use `appLocalizationsDelegates`, so tests
  build screens the same way the app does.

### Compatibility bridge — not needed

The runtime packages that still import the SDK Material library are `printing`,
`qr_flutter`, `mobile_scanner` and `flutter_riverpod`. In the parts the app uses, they only
use colour and icon constants (`Colors.black`, `Icons.error`), never `Theme.of` or Material
localizations, so `MaterialUiCompatibilityBridge` is not added. This is recorded in
`docs/architecture.md` §16.

### Tests

- `test/widget_test.dart` — new test: the app's current route is a `MaterialPage`, so
  screens keep their transition. It guards against the go_router problem above coming back.

### Docs

- `CLAUDE.md` / `AGENTS.md` — the `material_ui` rule is now in force (no longer "pending"),
  and says to use `appLocalizationsDelegates`.
- `docs/dependencies.md` — `go_router` 18 and a new `material_ui` entry.
- `docs/architecture.md` §16 — the Material library choice and why no bridge is used.
- `docs/features.md` — Flutter 3.47.6 / Dart 3.13.5, `go_router` 18, `material_ui`.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 986 tests passed (985 before + 1 new).
- `flutter build apk --flavor prod --release --obfuscate
  --split-debug-info=build/symbols/android-prod-2.6.13+37/ --split-per-abi` — built; arm64
  APK 27.9 MB, the same as after Phase 2.
- `aapt2 dump permissions` — still no `INTERNET` and no `ACCESS_NETWORK_STATE`.
- `android\gradlew --stop` run; no Gradle or Kotlin daemon left.

## Not tested

- The app was not run on a device. Widget tests cover the screens, but please look at a few
  screens on a phone (song list, performance view, settings, a dialog and a bottom sheet) to
  confirm the theme, colours and page transitions look the same as before.
