# Change Log: Align Code, Project Structure, and Documentation with Guidelines

**Date:** 2026-09-04

**Plan Reference:** [../plans/20260904_163000_guidelines-compliance-alignment.md](../plans/20260904_163000_guidelines-compliance-alignment.md)

## 1. What Changed

1. **Updated Guideline Pointer and AI Agent Instructions**:
   - `docs/GUIDELINES_MANIFEST.md`: Synced with `docs/guidelines/GUIDELINES_MANIFEST.md`.
   - `CLAUDE.md` and `AGENTS.md`:
     - Added the mandatory `## Localization rules` section.
     - Added Rule 3 under `## Workflow rules` ("Relative paths & privacy only — no local system details").
     - Added references to `CLAUDE_MD_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`, and project baseline documents.
     - Synchronized both files for 100% parity.

2. **Created Missing Mandatory Baseline Documents**:
   - Created `docs/workflow_rules.md` detailing the plan-approve-log workflow, approval gate, relative paths and privacy rule, and simple English standard.
   - Created `docs/dependencies.md` detailing the strict offline posture, categorized third-party packages, and the list of prohibited dependencies.
   - Created `docs/project_structure.md` detailing the project tree, layer responsibilities, and directional data flow.

3. **Updated Existing Security and Release Documentation**:
   - `docs/security.md`: Standardized the H1 title and documented `android:allowBackup="false"`.
   - `docs/release_process.md`: Updated current version to `2.6.10+34`, documented production hardening flags (`--release`, `--obfuscate`, `--split-debug-info`), and added verification checks.

4. **Added ARB Localization Architecture**:
   - Added `flutter_localizations` SDK dependency and `intl: any` to `pubspec.yaml`, and enabled `generate: true` under `flutter:`.
   - Created `l10n.yaml` with standard localization options.
   - Created `lib/l10n/app_en.arb` containing baseline application strings and context descriptions (`@key`).
   - Wired `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales` into `MaterialApp.router` in `lib/main.dart`.
   - Generated localization classes using `flutter gen-l10n`.

5. **Updated Static Analysis and Code Standards**:
   - Updated `analysis_options.yaml` to enable recommended baseline linter rules (`always_use_package_imports`, `avoid_print`, `prefer_single_quotes`, `prefer_const_constructors`, `prefer_final_fields`, `prefer_final_locals`, `use_decorated_box`, `cancel_subscriptions`, `close_sinks`, etc.).
   - Replaced relative imports with package imports (`package:lyricchord/...`) in `lib/screens/about_screen.dart`, `lib/providers/config_provider.dart`, and `lib/core/config/config_service.dart`.
   - Fixed minor lint issues in screens, services, widgets, and tests to achieve zero analyzer warnings.

6. **Hardened Android Manifest**:
   - Added `android:allowBackup="false"` to `<application>` in `android/app/src/main/AndroidManifest.xml` to prevent unencrypted ADB database extraction.

## 2. Files Changed or Created

| File | Status | Description |
|---|---|---|
| `docs/GUIDELINES_MANIFEST.md` | Modified | Synced with submodule manifest |
| `CLAUDE.md` | Modified | Added localization and privacy rules |
| `AGENTS.md` | Modified | Added localization and privacy rules |
| `docs/workflow_rules.md` | Created | Living baseline doc for workflow and privacy |
| `docs/dependencies.md` | Created | Living baseline doc for packages and offline boundary |
| `docs/project_structure.md` | Created | Living baseline doc for directory layout and layers |
| `docs/security.md` | Modified | Standardized title and added backup setting |
| `docs/release_process.md` | Modified | Updated version and release hardening commands |
| `pubspec.yaml` | Modified | Added `flutter_localizations`, `intl`, and `generate: true` |
| `l10n.yaml` | Created | Configuration for Flutter localization generator |
| `lib/l10n/app_en.arb` | Created | Base English ARB strings file with descriptions |
| `lib/main.dart` | Modified | Configured `AppLocalizations` delegates in `MaterialApp` |
| `analysis_options.yaml` | Modified | Adopted recommended baseline lint rules |
| `android/app/src/main/AndroidManifest.xml` | Modified | Added `android:allowBackup="false"` |
| `lib/screens/about_screen.dart` | Modified | Used package imports and const constructors |
| `lib/providers/config_provider.dart` | Modified | Used package imports |
| `lib/core/config/config_service.dart` | Modified | Used package import |
| `lib/screens/chord_settings_screen.dart` | Modified | Added const constructor |
| `lib/screens/home_shell.dart` | Modified | Added const constructor |
| `lib/screens/metronome_settings_screen.dart` | Modified | Added const constructor |
| `lib/services/carnatic_notation_import_service.dart` | Modified | Added const constructor |
| `lib/services/pdf_export_service.dart` | Modified | Swapped double quotes for single quotes |
| `lib/widgets/metronome_tempo_sheet.dart` | Modified | Swapped double quotes for single quotes |
| `test/data/app_database_connection_test.dart` | Modified | Added const constructors |
| `test/data/app_database_migration_test.dart` | Modified | Used single quotes on SQL prefixes |
| `plans/20260904_163000_guidelines-compliance-alignment.md` | Modified | Updated status to completed |

## 3. Verification

- `flutter gen-l10n`: Generated `lib/l10n/app_localizations.dart` and `lib/l10n/app_localizations_en.dart`.
- `dart format .`: Formatted all files with zero required changes.
- `flutter analyze`: Passed with 0 issues across the entire project.
- `flutter test`: All 903 tests passed.
