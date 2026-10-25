# CLAUDE.md — LyricChord

This file is read by Claude Code at the start of every session in this repository.
Read it before making any change. This is a **Thin** file — see the docs table
below for the full detail; do not duplicate that detail here.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | LyricChord |
| Type | A lyrics & chords notebook for musicians — write chord sheets, transpose, and auto-scroll while performing |
| Platforms | Android (minSdk 24 / Android 7; compileSdk and targetSdk from Flutter). iOS not decided yet (`ios/` kept; deployment target 13.0 must rise to 14.0+ for `file_picker`). No desktop or web |
| Stores / channels | Android: Google Play and direct APK. iOS: not decided yet |
| Languages | English (`en`, template), Malayalam (`ml`), Sanskrit (`sa`). All three are built — `ml` and `sa` translations need native-reader review |
| Package / org id | `in.sreerajp.lyricchord` |
| Flutter SDK | 3.47.6 (stable) — from `flutter --version`; CI pins the same version |
| Dart SDK | 3.13.5 — from `flutter --version` |
| State management | Riverpod (`flutter_riverpod`) |
| Navigation | go_router |
| Database | drift (SQLite) for songs and setlists; `shared_preferences` for settings |
| Orientation | both |
| Connectivity | **Fully offline — no INTERNET permission, no network packages** |

> This is a like-for-like Flutter port of an existing Android app. Keep this
> table honest and current — it is the fastest way to orient.

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| [docs/PROJECT_PROFILE.md](docs/PROJECT_PROFILE.md) | Always — product brief, platforms, stores, languages, identity, About options, tools |
| [docs/lyriccord_idea.md](docs/lyriccord_idea.md) | Understanding what the app is and which features must exist |
| [docs/architecture.md](docs/architecture.md) | Changing structure, screens, state, services, models, repositories, storage, navigation |
| [docs/security.md](docs/security.md) | Touching permissions, networking, imported files, logging, data retention, or the keystore |
| [docs/release_process.md](docs/release_process.md) | Building, signing, hardening, and releasing production artifacts |
| [docs/workflow_rules.md](docs/workflow_rules.md) | Understanding plan/approve/log, privacy, and communication rules |
| [docs/dependencies.md](docs/dependencies.md) | Checking approved libraries and offline prohibited dependencies |
| [docs/project_structure.md](docs/project_structure.md) | Understanding directory layout and layer boundaries |
| [docs/implementation_plan.md](docs/implementation_plan.md) | Deciding what to build next and when a phase is "done" |
| [docs/glossary.md](docs/glossary.md) | Writing or reviewing Malayalam or Sanskrit text — the approved word for each app term |
| [docs/carnatic_notation.md](docs/carnatic_notation.md) | Touching swaras, `{melody}` lines, talas, ragas, or transcribing published Carnatic notation |
| [docs/GUIDELINES_MANIFEST.md](docs/GUIDELINES_MANIFEST.md) | The shared Flutter guidelines index |
| [docs/guidelines/guideline.md](docs/guidelines/guideline.md) | About-screen config, keystore rules, baseline `lib/` layout |
| [docs/guidelines/flutter_project_engineering_standard.md](docs/guidelines/flutter_project_engineering_standard.md) | Any code change — layers, naming, testing |
| [docs/guidelines/flutter_build_flavors_guide.md](docs/guidelines/flutter_build_flavors_guide.md) | Build config, signing, flavors, Gradle, ProGuard |
| [docs/guidelines/platform_store_readiness.md](docs/guidelines/platform_store_readiness.md) | Before any release; when touching permissions, `Info.plist`, or store-listed behaviour |
| [docs/guidelines/CLAUDE_MD_GUIDELINE.md](docs/guidelines/CLAUDE_MD_GUIDELINE.md) | Writing and maintaining root CLAUDE.md |
| [docs/guidelines/AGENTS_MD_GUIDELINE.md](docs/guidelines/AGENTS_MD_GUIDELINE.md) | Writing and maintaining root AGENTS.md |
| [docs/guidelines/DOCS_FOLDER_GUIDELINE.md](docs/guidelines/DOCS_FOLDER_GUIDELINE.md) | Creating and structuring docs/ folder files |

> `docs/<file>` = this app's filled-in copy (templates such as `architecture.md`,
> `security.md`, `release_process.md`). `docs/guidelines/<file>` = the shared
> reference in the submodule; never copy it into `docs/`.

---

## Hard rules (must follow — these override convenience)

1. **Fully offline.** The app makes no network calls. Never add the `INTERNET`
   permission or any package that performs network I/O. See
   [docs/security.md](docs/security.md).
2. **Like-for-like port.** This re-implements the Android app; it is not a
   redesign. Match the same features, palette, and 600 dp phone/tablet
   breakpoint from [docs/lyriccord_idea.md](docs/lyriccord_idea.md).
3. **No AI features.** The Android project declared Gemini/Firebase AI but never
   used it. The Flutter app has no AI feature. If AI is ever wanted, it is a new
   project.
4. **Never crash on bad input.** The untrusted inputs are an imported
   ChordPro/text file and a scanned AirQR code. Parse defensively, fall back to
   safe defaults, and surface failures as a `SnackBar` — never corrupt the
   database.
5. **Scoped storage only.** Import/export use the system file picker / share
   sheet. Never request a broad storage permission. The only allowed runtime
   permission is the camera, asked only when the user opens the AirQR scanner
   (see [docs/security.md](docs/security.md) §3).

---

## Architecture rules

- **Layout:** Tier 1 layer-first under `lib/` — `core/` (`config/`, `constants/`,
  `errors/`, `utils/`), `models/`, `services/`, `repositories/`, `data/`,
  `providers/`, `screens/`, `widgets/`, `theme/`, `l10n/`, `main.dart`. Do not restructure
  or promote to feature-first without instruction.
- **Dependency direction:**
  `Widget → Provider (state) → Service / Repository → drift DAO → SQLite`.
- **Layer boundaries:** widgets must not know SQL, ChordPro syntax, or PDF
  drawing. Services must not know navigation or UI strings.
- **Models are immutable** (`copyWith`, never mutate in place).
- Full detail is in [docs/architecture.md](docs/architecture.md) and [docs/project_structure.md](docs/project_structure.md).

---

## Build & run commands

```bash
flutter pub get                        # install dependencies
dart run build_runner build --delete-conflicting-outputs   # generate drift code
flutter run --flavor dev               # daily development run
flutter run --flavor prod              # production config, debug tooling
flutter analyze                        # static analysis (must be clean)
flutter test                           # run all tests
dart format .                          # format before committing

# Production release APK (split per ABI)
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/ --split-per-abi

# Production Play Store bundle
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod-<version>/

# iOS (on a Mac; no flavor schemes yet)
flutter build ipa --release \
  --obfuscate --split-debug-info=build/symbols/ios-<version>/
```

> `<version>` is the full `pubspec.yaml` version, e.g. `2.6.13+37`. Size analysis
> (`--analyze-size`) is a separate throw-away build: run it before the release
> build, never ship it ([docs/release_process.md](docs/release_process.md) §6.3).
> After any Android build, run `android\gradlew --stop` and end leftover Gradle /
> Kotlin daemons.

> Android defines flavors, so a bare `flutter run` fails on Android — always pass `--flavor`.

---

## Build flavors

| Flavor | App ID | Display name | Signing |
|--------|--------|--------------|---------|
| dev | `in.sreerajp.lyricchord.dev` | LyricChord Dev | Debug keystore (automatic) |
| prod | `in.sreerajp.lyricchord` | LyricChord | Release keystore (`android/key.properties`) |

> Android uses `--flavor <name>` (Gradle product flavors, dimension `environment`).
> iOS has no flavor schemes yet — run and build iOS without `--flavor` until they
> are set up on a Mac. Never pass `FLUTTER_APP_FLAVOR` with `--dart-define`. Details:
> [docs/guidelines/flutter_build_flavors_guide.md](docs/guidelines/flutter_build_flavors_guide.md).

---

## Signing / keystore

- Create `android/key.properties` (gitignored — **never** commit it). It points to
  the release keystore in `android/`.
- `.gitignore` must include: `android/key.properties`, `android/*.jks`,
  `android/*.keystore`, and `build/` (which also holds the debug symbols).
- Keep the release keystore backed up offline — losing it means you can no longer
  publish updates under the same signature. Follow the keystore rules in
  [docs/guidelines/guideline.md](docs/guidelines/guideline.md) §2.
- Apple certificates and provisioning profiles live outside the repo
  ([docs/guidelines/guideline.md](docs/guidelines/guideline.md) §2.5). Never commit them.

---

## Security rules

- Never log secrets or song content. Log only through `AppLogger`
  (`lib/core/logging/app_logger.dart`) — never `print` or `debugPrint`. It writes
  `trace`/`debug` in the dev flavor only and logs errors by type only in prod releases.
- Never add the `INTERNET` permission; verify the built artifact has none:
  `aapt2 dump permissions build/app/outputs/flutter-apk/app-arm64-v8a-prod-release.apk`.
- Request **no** runtime permissions except the camera for the AirQR
  scanner — no location, contacts, microphone, or storage. The full list of
  allowed permissions and why is in [docs/security.md](docs/security.md) §3.
- Validate imported ChordPro defensively (see Hard rule 4).
- Ensure `android:allowBackup="false"` in `android/app/src/main/AndroidManifest.xml`.
- Full posture: [docs/security.md](docs/security.md).

---

## Localization rules

- Declared languages (from [docs/PROJECT_PROFILE.md](docs/PROJECT_PROFILE.md)):
  **English (`en`, template), Malayalam (`ml`), Sanskrit (`sa`)**. Every feature and every
  screen must work in every declared language. `app_en.arb`, `app_ml.arb` and `app_sa.arb`
  all exist; `test/l10n/locale_smoke_test.dart` opens the main screens in each language.
- Language pack in force:
  [docs/guidelines/language_packs/sanskrit_malayalam.md](docs/guidelines/language_packs/sanskrit_malayalam.md).
  Sanskrit is pure Sanskrit, never Hindi (it must pass the Hindi-marker gate); Malayalam is
  natural Malayalam, not English transliteration; use the pack's glossary. Flag any
  translation you are unsure of as "needs native-reader review" in the change log.
- All user-visible text comes from `lib/l10n/*.arb` via `AppLocalizations` — never a raw string
  literal in a widget.
- `l10n.yaml` (project root) and one ARB file per declared language (`app_<code>.arb`) must
  exist. Run `flutter gen-l10n` after editing any `.arb` file.
- Every new key goes into **every** declared language's file with a real translation. Never
  leave the English value sitting in another language's file.
- Every ARB key needs an `@key` description entry in the template file.
- Every ARB key starts with its category (engineering standard §8.6): short UI text uses
  `action…` (buttons, menu items), `label…` (field, row, chip, switch labels), `title…`
  (screen, dialog, section titles), `tab…`, `nav…`, `tooltip…`; long text uses `desc…`
  (subtitles, hints, screen-reader text), `help…`, `empty…`, `error…`, `body…`
  (snackbar messages), `aboutDetail…`. Example: `actionSave`, `titleSettings`,
  `errorSongListExportFailed`.
- `supportedLocales` equals the declared languages (`AppLocalizations.supportedLocales`);
  a fallback delegate serves English framework strings for `sa` (never Hindi). Format dates
  and numbers with the `formattingLocale(...)` helper (engineering standard §8.3.2).
- The language is user-selectable in Settings → Language (System default, then each
  language by its own name from `lib/l10n/language_names.dart`), saved under `app_language`
  by `localeProvider`, and applied without restarting the app. The picker lists only
  languages that have an ARB file.
- Sanskrit framework strings come from English through `lib/l10n/fallback_localizations.dart`.
  Show numbers with `formatFixed(...)` (`lib/core/utils/formatting_locale.dart`), never
  `toStringAsFixed` or `toString()`.
- Use the terms in [docs/glossary.md](docs/glossary.md) and the language pack glossary.
  `bash tool/check_sanskrit_hindi_markers.sh` must pass.
- Menu, button, label, tab and tooltip strings stay short: 1–2 words, at most 20
  characters in English and 22 in Malayalam and Sanskrit. Only descriptive text (help,
  empty states, errors, About rows) may be long (engineering standard §8.6).
  `test/l10n/label_length_test.dart` enforces the budget and the key prefixes.
- Every icon-only control (`IconButton`, FAB, `PopupMenuButton`, icon-only gesture) has a
  localized `tooltip:` (engineering standard §7.8). Put it on the button's own
  `tooltip:`, not a wrapping `Tooltip` widget, and call
  `expectAllIconButtonsHaveTooltips(tester)` (`test/helpers/tooltip_expectations.dart`)
  in the widget test of any screen with icon buttons.
- Material comes from the `material_ui` package (caret `^` constraint): import
  `package:material_ui/material_ui.dart`, never `package:flutter/material.dart` or
  `package:flutter/cupertino.dart` (engineering standard §6.1). The app uses no Cupertino
  widgets, so `cupertino_ui` is only a transitive package. `MaterialApp` and widget tests use
  `appLocalizationsDelegates` (`lib/l10n/app_localizations_delegates.dart`), never the
  generated `AppLocalizations.localizationsDelegates` list (it names the SDK delegates).
- The About screen is data-driven from `assets/config/app_config.json`; it must not
  hard-code About text ([docs/guidelines/guideline.md](docs/guidelines/guideline.md) §1).
  The profile turns the signature badge on: the About screen must end with it once its
  wording is set in [docs/PROJECT_PROFILE.md](docs/PROJECT_PROFILE.md) §5 (still TODO).
- Literals are allowed only for logs, non-UI exception messages, asset paths, route names, and
  map/JSON keys.
- `test/l10n/no_hard_coded_ui_text_test.dart` fails on new hard-coded UI text in
  `lib/screens/`, `lib/widgets/` and `lib/main.dart`. Fix the code; the allow-list in
  that test is only for notation (e.g. swara names), never for words.
- `l10n.yaml` has `use-escaping: true`: write an apostrophe as `''` and wrap literal
  braces in single quotes (`'{melody}'`).
- Screen names for model enums live in `lib/l10n/l10n_labels.dart`, not in the models.

---

## Code style / naming

- Files `snake_case.dart`; classes `PascalCase`; variables/methods `camelCase`;
  providers `camelCase` + `Provider` suffix.
- Use `package:` imports, not relative. Prefer `const` constructors, `final`
  locals, single quotes.
- Run `dart format .` and keep `flutter analyze` at zero warnings before every
  commit.
- Never hand-edit generated files (`*.g.dart`, drift-generated `*.drift.dart` /
  `*.g.dart`). Change the source and re-run `build_runner`. Generated files are
  committed (see [README.md](README.md) §5).

---

## Testing rules

- Mirror the `lib/` structure in `test/` (`test/services/`, `test/repositories/`,
  `test/widgets/`, plus `helpers/` and `fixtures/`).
- Add or update a test whenever you add or change a service, DAO, or repository.
- Critical areas that must be covered:
  - Chord transposition (sharps/flats, slash chords, wrap-around).
  - ChordPro import/export round-trip.
  - Chord-over-lyric line parsing (the `[C]word` renderer).
  - Tempo-Auto scroll math (ends exactly at song end).
  - Database seeding on first run, and migrations from version 1 to the current version.
- Detail: [docs/architecture.md](docs/architecture.md) §18.

---

## Dependency constraints

- **Blocked (never add, never accept as a transitive dep):** any HTTP client,
  cloud/BaaS, analytics, crash reporting, ads, AI/LLM, or network-status package
  — this is a fully offline app.
- Before adding any package: check its `pubspec.yaml` for networking deps, state
  why it is needed, and confirm it fits the hard rules.
- See [docs/dependencies.md](docs/dependencies.md) for approved and prohibited libraries.

---

## Where things live

```
CLAUDE.md            # this file — project rules
AGENTS.md            # AI agent instructions (mirrors CLAUDE.md)
README.md            # setup, run, test, build
PRIVACY.md           # privacy policy draft
l10n.yaml            # localization configuration
.github/             # CI checks only
docs/                # design docs (profile, architecture, security, release, idea, plan)
docs/guidelines/     # shared Flutter guidelines submodule (read-only)
plans/               # one plan per change (see workflow rules)
change_log/          # one log per implemented change
lib/                 # app source (see architecture rules)
test/                # tests (mirrors lib/)
```

---

## Workflow rules (mandatory)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to
   change, the issue, and the fix. Then **STOP and get explicit approval** before
   editing/creating/deleting any project file (other than the plan). A question or
   ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to
   `change_log/` named `yyyymmdd_hhMMss_<short-slug>.md` describing what changed
   and referencing its plan.
3. **Relative paths & privacy only.** `plans/` and `change_log/` files are committed and may become
   public on the internet. They MUST use relative repository paths only (never absolute system
   paths like `C:\...`, `l:\...`, or `file:///...`). They MUST NOT contain any **local system
   details** — OS user name, computer/host name, home or drive-letter paths, network share names,
   LAN/internal IP addresses, local server URLs with ports, device serial numbers, personal email
   addresses — or any secret (API keys, tokens, passwords, keystore passphrases, credentials, PII).
   Write them as if a stranger will read them; nothing should reveal the machine they came from.
4. **The guidelines submodule is read-only.** `docs/guidelines/` is read-only. Never edit, pull,
   check out or commit the submodule or its version. If a guideline needs a change, write a note
   for the user instead (`docs/guidelines/DOCS_FOLDER_GUIDELINE.md` §1.1). If the folder is empty
   or missing, stop and ask the user.
5. **CI is checks only.** GitHub CI runs only `flutter pub get`, code generation, the
   generated-file check, the format check, `flutter analyze` and `flutter test`. CI never
   builds release artifacts, signs, holds signing secrets, uploads, or publishes. Release
   builds are done locally (`docs/guidelines/flutter_project_engineering_standard.md` §19).
   Dependabot is not used (no `.github/dependabot.yml`), even though engineering standard
   §19.2 asks for it; dependencies are updated by hand, each with its own plan.

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and
  explanations in plain, simple English. Short sentences, common words. Explain
  any jargon you must use.

---

## What Claude must always / never do

**Always:** read this file first; state the target layer before adding a class;
keep `main.dart` thin; run `flutter analyze` and `flutter test` after changes;
put user-visible strings in `lib/l10n/*.arb` via `AppLocalizations`; give every
icon-only control a localized tooltip; match the Android app's behaviour and palette.

**Never:** put business logic in a widget; call a DAO or touch SQL from a widget;
edit generated `*.g.dart` / drift files; add a networking, cloud, analytics, or
AI package; add the `INTERNET` permission; log song content in release builds;
change the `docs/guidelines/` submodule.
