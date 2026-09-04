# Plan: Align Code, Project Structure, and Documentation with Guidelines

**Status:** completed

**Date:** 2026-09-04

## 1. What the issue is

The shared guidelines submodule (`docs/guidelines/`) was recently updated. An audit of the project against `docs/guidelines/` revealed several compliance gaps across documentation, project configuration, and code:

1. **Root AI guideline files (`CLAUDE.md` and `AGENTS.md`)**:
   - Missing the mandatory `## Localization rules` section required for every Flutter app by `CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md`.
   - Missing Rule 3 in `## Workflow rules` regarding "Relative paths & privacy only (no local system details)".
   - Missing table references to `CLAUDE_MD_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`, and the baseline project docs.

2. **`docs/` baseline documentation gaps (`DOCS_FOLDER_GUIDELINE.md` §6)**:
   - `docs/GUIDELINES_MANIFEST.md` is outdated compared to the submodule copy.
   - Three mandatory living baseline documents are missing from `docs/`:
     - `docs/workflow_rules.md`
     - `docs/dependencies.md`
     - `docs/project_structure.md`
   - `docs/security.md` title has the repository name instead of the app name (`# Security — LyricChord`).
   - `docs/release_process.md` still lists `1.0.0+1` instead of `2.6.10+34`, and is missing the latest release hardening checks (e.g. `android:allowBackup="false"`, asset leak audits).

3. **Mandatory String Externalization & ARB infrastructure (`flutter_project_engineering_standard.md` §8.2 & `guideline.md` §3/§4)**:
   - `l10n.yaml` does not exist at the project root.
   - `lib/l10n/app_en.arb` does not exist.
   - `flutter_localizations` is not registered in `pubspec.yaml` and `generate: true` is missing.
   - `MaterialApp.router` in `lib/main.dart` lacks `localizationsDelegates` and `supportedLocales`.

4. **Lint & Code standards (`flutter_project_engineering_standard.md` §16.1)**:
   - `analysis_options.yaml` uses the empty starter template with commented rules instead of the recommended baseline lint suite (including `always_use_package_imports: true`, `avoid_print: true`, `prefer_single_quotes: true`, etc.).
   - Several files (`lib/screens/about_screen.dart`, `lib/providers/config_provider.dart`, `lib/core/config/config_service.dart`) use relative imports (`../`) instead of package imports (`package:lyricchord/...`).

5. **Security & Manifest (`release_process.md` §6.4 & `security.md`)**:
   - `android/app/src/main/AndroidManifest.xml` is missing `android:allowBackup="false"` on `<application>`.

## 2. Files to be changed or created

| File | Change |
|---|---|
| `docs/GUIDELINES_MANIFEST.md` | Update to match `docs/guidelines/GUIDELINES_MANIFEST.md` |
| `CLAUDE.md` | Add localization rules, privacy rule in workflow, and docs table links |
| `AGENTS.md` | Match `CLAUDE.md` exactly |
| `docs/workflow_rules.md` (new) | Create living baseline doc for project workflow & privacy rules |
| `docs/dependencies.md` (new) | Create living baseline doc for dependencies & offline boundary |
| `docs/project_structure.md` (new) | Create living baseline doc for folder structure & layer responsibilities |
| `docs/security.md` | Standardize H1 title and document `android:allowBackup="false"` |
| `docs/release_process.md` | Update current version and add production hardening commands |
| `pubspec.yaml` | Add `flutter_localizations`, `intl`, and `flutter: generate: true` |
| `l10n.yaml` (new) | Add standard localization configuration |
| `lib/l10n/app_en.arb` (new) | Add base localization strings with `@key` descriptions |
| `lib/main.dart` | Register `AppLocalizations` delegates and supported locales |
| `analysis_options.yaml` | Add recommended baseline lints from engineering standard §16.1 |
| `lib/screens/about_screen.dart` | Change relative imports to `package:lyricchord/...` |
| `lib/providers/config_provider.dart` | Change relative imports to `package:lyricchord/...` |
| `lib/core/config/config_service.dart` | Change relative import to `package:lyricchord/...` |
| `android/app/src/main/AndroidManifest.xml` | Add `android:allowBackup="false"` to `<application>` |

## 3. Detailed plan for the fix

### 3.1 Update `docs/GUIDELINES_MANIFEST.md`, `CLAUDE.md`, and `AGENTS.md`

1. Copy the updated contents of `docs/guidelines/GUIDELINES_MANIFEST.md` to `docs/GUIDELINES_MANIFEST.md`.
2. Update `CLAUDE.md` and `AGENTS.md`:
   - Add `docs/guidelines/CLAUDE_MD_GUIDELINE.md`, `docs/guidelines/AGENTS_MD_GUIDELINE.md`, and `docs/guidelines/DOCS_FOLDER_GUIDELINE.md` to the "Read these docs before working" table.
   - Add `docs/workflow_rules.md`, `docs/dependencies.md`, and `docs/project_structure.md` to the table and "Where things live".
   - Add the mandatory `## Localization rules` section:
     - All user-visible text comes from `lib/l10n/*.arb` via `AppLocalizations`.
     - `l10n.yaml` and `lib/l10n/app_<base>.arb` must exist.
     - Every ARB key needs an `@key` description.
     - Narrow exceptions for literals (logs, non-UI exceptions, asset paths, route names, map/JSON keys).
   - Update `## Workflow rules` with Rule 3:
     "3. Relative paths & privacy only. `plans/` and `change_log/` files are committed and may become public on the internet. They MUST use relative repository paths only (never absolute system paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any **local system details** — OS user name, computer/host name, home or drive-letter paths, network share names, LAN/internal IP addresses, local server URLs with ports, device serial numbers, personal email addresses — or any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII). Write them as if a stranger will read them; nothing should reveal the machine they came from."

### 3.2 Add missing baseline documents to `docs/`

3. Create `docs/workflow_rules.md`:
   - Follow `DOCS_FOLDER_GUIDELINE.md` anatomy.
   - Detail the 3 workflow rules: plan before changing, approval gate, log after changing.
   - Detail the privacy & relative paths policy (no local system details, bad -> good table).
   - Document the simple English rule.
4. Create `docs/dependencies.md`:
   - Follow `DOCS_FOLDER_GUIDELINE.md` anatomy.
   - Detail the offline boundary (no INTERNET, no network packages).
   - Categorize approved and integrated packages: state management, local database, audio synthesis, PDF export, device controls.
   - List prohibited dependencies (HTTP clients, cloud/BaaS, crash reporting, ads, AI/LLM).
5. Create `docs/project_structure.md`:
   - Follow `DOCS_FOLDER_GUIDELINE.md` anatomy.
   - Full directory layout and layer rules: `core/`, `data/`, `models/`, `providers/`, `repositories/`, `screens/`, `services/`, `theme/`, `widgets/`, `l10n/`.
   - Detail the architecture flow: `Widget -> Provider -> Service / Repository -> drift DAO -> SQLite`.
6. Update `docs/security.md` and `docs/release_process.md`:
   - Title in `docs/security.md`: `# Security — LyricChord`.
   - Update version in `docs/release_process.md` to `2.6.10+34`.
   - Document `android:allowBackup="false"` and production release build commands with `--release`, `--obfuscate`, and `--split-debug-info`.

### 3.3 Set up localization (ARB) infrastructure

7. Update `pubspec.yaml`:
   - Add `flutter_localizations: sdk: flutter` and `intl: any` under `dependencies:`.
   - Set `generate: true` under `flutter:`.
8. Create `l10n.yaml` at project root:
   ```yaml
   arb-dir: lib/l10n
   template-arb-file: app_en.arb
   output-localization-file: app_localizations.dart
   nullable-getter: false
   ```
9. Create `lib/l10n/app_en.arb` with baseline application strings and context descriptions (`@key`).
10. Update `lib/main.dart`:
    - Import `package:flutter_localizations/flutter_localizations.dart` and `package:lyricchord/l10n/app_localizations.dart` (or generated accessor).
    - Supply `localizationsDelegates: AppLocalizations.localizationsDelegates` and `supportedLocales: AppLocalizations.supportedLocales` to `MaterialApp.router`.
11. Run `flutter gen-l10n` to generate localizations code.

### 3.4 Adopt recommended lints and fix imports

12. Update `analysis_options.yaml` to include recommended linter rules from §16.1 of the engineering standard.
13. Replace relative imports (`../`) with package imports (`package:lyricchord/...`) in:
    - `lib/screens/about_screen.dart`
    - `lib/providers/config_provider.dart`
    - `lib/core/config/config_service.dart`

### 3.5 Update Android manifest

14. In `android/app/src/main/AndroidManifest.xml`, add `android:allowBackup="false"` to the `<application>` tag.

## 4. Verification

1. Run `dart format .`.
2. Run `flutter analyze` to ensure zero warnings/errors.
3. Run `flutter test` to ensure all 903+ tests pass.
4. Verify `git status` for clean repository state.
