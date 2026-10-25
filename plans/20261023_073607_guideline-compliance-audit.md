# Make the project follow the shared guidelines strictly

**Status:** partial_completion

Progress:

- Phase 1 was approved and is done —
  [../change_log/20261023_075312_guideline-compliance-phase1.md](../change_log/20261023_075312_guideline-compliance-phase1.md).
- The user then answered Q1–Q8 (see "Answers"). The answers were written into the docs as part
  of Phase 1. They add new work (Malayalam and Sanskrit UI, renaming all ARB keys), so the
  phases below were revised and are presented again for approval. Each phase still needs its
  own approval before it starts.
- Phase 2 approved and done —
  [../change_log/20261023_212718_guideline-compliance-phase2.md](../change_log/20261023_212718_guideline-compliance-phase2.md).
  During it the user chose to stay on Flutter 3.47.6 and approved upgrading `file_picker`
  and `package_info_plus` (needed by AGP 9).
- Phase 3 approved and done —
  [../change_log/20261023_213627_guideline-compliance-phase3.md](../change_log/20261023_213627_guideline-compliance-phase3.md).
  `go_router` was moved to 18 so page transitions survive the migration.
- Phase 4 approved and done —
  [../change_log/20261023_215005_guideline-compliance-phase4.md](../change_log/20261023_215005_guideline-compliance-phase4.md).
  Added a start-up failure screen (standard §4.5 and §11.4) as part of it.
- Phase 5 approved and done —
  [../change_log/20261023_220118_guideline-compliance-phase5.md](../change_log/20261023_220118_guideline-compliance-phase5.md).
  It found 55 short-category English strings over the 20-character limit; Phase 6 must
  shorten or re-categorise them (an English text change, so it needs approval).
- Phase 6 approved and done —
  [../change_log/20261023_221456_guideline-compliance-phase6-part1.md](../change_log/20261023_221456_guideline-compliance-phase6-part1.md)
  (tooltips, tooltip helper, length test) and
  [../change_log/20261023_222501_guideline-compliance-phase6-part2.md](../change_log/20261023_222501_guideline-compliance-phase6-part2.md)
  (the approved shorter texts).
- Phase 7 approved and done —
  [../change_log/20261023_223346_guideline-compliance-phase7.md](../change_log/20261023_223346_guideline-compliance-phase7.md).
  Still waiting: the signature badge (needs its wording) and the privacy-policy row (needs
  the URL).
- Phase 8 approved and done —
  [../change_log/20261023_224319_guideline-compliance-phase8.md](../change_log/20261023_224319_guideline-compliance-phase8.md).
  Start-up steps 5–8 moved to `lib/core/startup/app_startup.dart` so the app can restart
  fresh after the delete.
- Phase 9 approved and done —
  [../change_log/20261025_100123_guideline-compliance-phase9.md](../change_log/20261025_100123_guideline-compliance-phase9.md).
  Noto Sans Devanagari was downloaded and bundled with the user's approval.
- Phase 10 approved on 2026-10-25 and done, in 11 batches —
  [../change_log/20261025_103810_guideline-compliance-phase10.md](../change_log/20261025_103810_guideline-compliance-phase10.md).
  All Malayalam and Sanskrit strings need a native reader's review before a release.
- Not done, waiting on the user: the About signature badge (needs its wording), the
  privacy-policy row (needs the URL), and the publisher, website, copyright and licence.

## What the issue is

The shared guidelines in `docs/guidelines/` were updated to `34dfd4a`. I checked the project
against every rule in:

- `docs/guidelines/AI_AGENT_START_HERE.md`
- `docs/guidelines/guideline.md`
- `docs/guidelines/flutter_project_engineering_standard.md`
- `docs/guidelines/CLAUDE_MD_GUIDELINE.md` and `AGENTS_MD_GUIDELINE.md`
- `docs/guidelines/DOCS_FOLDER_GUIDELINE.md`
- `docs/guidelines/platform_store_readiness.md`

Most rules already pass (offline stance, ARB strings, the hard-coded-text test, `l10n.yaml`,
`allowBackup="false"`, flavors, keystore layout, drift WAL and foreign keys, migration tests,
UIScene on iOS). The gaps below do not pass. They are listed by phase. Each phase is small
enough to build, test and log on its own.

Nothing inside `docs/guidelines/` will be changed (it is read-only).

---

## Gaps found

### A. Missing project files and docs

| # | Rule | Gap |
|---|---|---|
| A1 | Standard §1.2.1, guideline §3 (MUST) | `docs/PROJECT_PROFILE.md` does not exist. |
| A2 | DOCS_FOLDER §1 | `docs/GUIDELINES_MANIFEST.md` differs from the submodule copy. It must be an unchanged copy. |
| A3 | Standard §19.1, §19.2 (MUST) | No `.github/workflows/ci.yml` and no `.github/dependabot.yml`. |
| A4 | Standard §21.3, §12.2 | `README.md` is still the default Flutter text. It must have prerequisites, setup, tests, code generation, build commands, how to add a migration, and the generated-file policy. |
| A5 | Standard §15.4, DOCS_FOLDER §6 | `docs/security.md` has no data retention and purge section (§13). |
| A6 | DOCS_FOLDER §6, release template | `docs/release_process.md` does not follow the template's numbering (§1 scope … §8 checklist, §9 Android, §10 iOS). |
| A7 | Standard §21.1 | No `PRIVACY.md` and no privacy policy URL. Needed before any public store release. |
| A8 | CLAUDE_MD_GUIDELINE §3–§5, §8 | `CLAUDE.md` and `AGENTS.md` miss: workflow rule 4 (submodule read-only) and rule 5 (CI checks + Dependabot only); Stores and Languages rows; `PROJECT_PROFILE.md` and `platform_store_readiness.md` in the docs table; tooltip and short-label rules; About-screen rule; `material_ui` rule; symbol folder name with `<version>`. The Flutter version in the identity table (3.44.8) does not match the installed toolchain (3.47.6). |

### B. Plans and change logs

| # | Rule | Gap |
|---|---|---|
| B1 | Standard §21.1.1 (MUST) | `change_log/20260808_214800_swara_notation_engine.md` has absolute `file:///` links. |
| B2 | Standard §21.1.1 (MUST) | `plans/20260803_130629_fix-features-doc.md` and `change_log/20260803_130800_fix-features-doc.md` contain a personal email address. Allowed only if the profile says it is the public support contact (question Q4). **Closed:** Q4 confirmed it is the public support contact. |
| B3 | Global naming rule | 8 files are named `20260822_<slug>.md` with no `hhMMss` part. |
| B4 | Status values | `plans/20260903_072500_pitch-drone-playback-fixes.md` (`Proposed`), `plans/20260903_202800_fix_text_import_line_breaks.md` (`complete`) use values that are not allowed. `plans/20260724_214500_pdf-save-dialog-filename.md` is still `approval_pending`. |

### C. About screen (`guideline.md` §1)

| # | Gap |
|---|---|
| C1 | `AppConfig` has no `LocalizedText` type; `appName`, `description` and `details` are plain strings. |
| C2 | `app_config.json` detail keys are labels (`Author`, `AI used`) instead of `lowerCamelCase` ids (`author`, `aiUsed`). |
| C3 | The About screen shows the raw JSON key as the row label. It must use ARB keys `aboutDetail<Key>`. |
| C4 | `ConfigService.loadAndVerify()` uses `debugPrint`. It must use `AppLogger.debug`. |
| C5 | No privacy-policy row (store apps SHOULD show one). Depends on A7. |

### D. App start-up, logging and errors (standard §4.5, §11, §14)

| # | Gap |
|---|---|
| D1 | No `AppLogger`. 10 `debugPrint` calls in `lib/` (banned in committed code). |
| D2 | No global error handlers: `FlutterError.onError`, `PlatformDispatcher.instance.onError`, and a release-only `ErrorWidget.builder` with a safe fallback widget. |
| D3 | No `AppFlavorConfig` that reads `APP_FLAVOR` then `FLUTTER_APP_FLAVOR`. Logging should be gated by flavor, not only by `kDebugMode`. |
| D4 | No app-level lifecycle observer (memory pressure → clear image cache; close the database on `detached`). |
| D5 | `main.dart` does not follow the init order (logger + handlers first, then DB, config, lifecycle). |

### E. Accessibility and localization

| # | Gap |
|---|---|
| E1 | Standard §7.8 (MUST): 3 `IconButton`s in `lib/screens/air_qr_receiver_screen.dart` have no tooltip (back, torch, switch camera). |
| E2 | Standard §7.8: no shared test helper that fails when an `IconButton` / FAB has no tooltip. |
| E3 | Standard §8.6: no label-length test. 524 of 941 ARB keys do not use the `action…`/`label…`/`title…`/`tooltip…`/`help…` prefixes, so the budget cannot be checked by key name. |
| E4 | Standard §8.1: `CFBundleLocalizations` is missing from `ios/Runner/Info.plist`. **Deferred:** iOS is not a declared platform yet (Q1), and only declared platforms may be touched. Do it when iOS is declared. |
| E5 | Standard §8.1: `localizationsDelegates` uses the generated list. After the `material_ui` move it must list `AppLocalizations.delegate` + `GlobalMaterialLocalizations.delegates` from `material_ui`. |

### F. Toolchain and build (standard §5.3, §6.1, §20.4)

| # | Gap |
|---|---|
| F1 | §5.3 (MUST): latest stable Flutter is 3.47.6 (installed). Project pins 3.44 (`pubspec.lock`, `CLAUDE.md`). |
| F2 | §5.3 (MUST): `android/app/build.gradle.kts` uses `kotlinOptions { }`. Must be `kotlin { compilerOptions { } }`. |
| F3 | §5.3: AGP 8.11.1 / Gradle 8.14 are behind what Flutter 3.47 writes. The Flutter migrator must update them (no versions typed by hand). |
| F4 | §6.1 (MUST): 91 files import `package:flutter/material.dart`. Must move to `material_ui` with `dart fix --apply --code=migrate_design_widgets`, and add `material_ui: ^<current>` (and `cupertino_ui` if used). |
| F5 | §16.1: `analysis_options.yaml` lacks `prefer_const_declarations`, `avoid_redundant_argument_values`, `noop_primitive_operations`, `use_enums`. |
| F6 | §20.4: `.gitignore` lacks `*.apk`, `*.aab`, `*.ipa`, `*.p12`, `*.pfx`, `*.p8`, `*.mobileprovision`, `*.provisionprofile`, `.flutter-plugins`. |
| F7 | `intl: any` — every dependency should have a caret constraint. |

### G. Product feature required by the standard

| # | Gap |
|---|---|
| G1 | Standard §15.4 (MUST): no "Delete all data" action in Settings (database, preferences, cache, temp files). |

### H. Malayalam and Sanskrit (new — from the answer to Q2)

The user declared `en`, `ml` and `sa`. The language pack
`docs/guidelines/language_packs/sanskrit_malayalam.md` is now mandatory.

| # | Rule | Gap |
|---|---|---|
| H1 | Standard §8.2, §8.7 | No `app_ml.arb` / `app_sa.arb`. About 941 keys (417 of them help text) need real translations in both languages. |
| H2 | Standard §8.4 | No language picker, no `LocaleController`, no `app_language` preference; `MaterialApp.locale` is not driven by app state. |
| H3 | Standard §8.3.1, pack §1.1 | No fallback delegates for `sa` (Flutter has no Sanskrit framework strings), and no widget test opening a date picker and a dialog under `sa`. |
| H4 | Standard §8.3.2, pack §1.2 | No `formattingLocale(...)` helper; any `intl` date/number format under `sa` would throw. |
| H5 | Standard §8.3.3, pack §2 | Malayalam fonts are bundled for lyrics, but there is no Devanagari font and no `fontFamilyFallback` for the UI text. |
| H6 | Standard §8.1 | `android/app/build.gradle.kts` lacks `bundle { language { enableSplit = false } }`. |
| H7 | Standard §8.7 | No translation parity test (keys, no copied English values, `app_config.json`, the badge `{heart}` marker). |
| H8 | Pack §4.1 | No Hindi-marker gate for Sanskrit (a CI check script). |
| H9 | Standard §8.5 | No `docs/glossary.md` for app-specific terms (chord, transpose, setlist, swara, raga, tala…) that the pack glossary does not cover. |
| H10 | Standard §8.5 | No named native-reader reviewers. All Malayalam and Sanskrit written by an AI agent is a draft and must be listed as "needs native-reader review". |
| H11 | Guideline §1.2 | `app_config.json` display values need `en` / `ml` / `sa` entries (folds into Phase 7). |

---

## Answers (2026-10-23)

| # | Question | Answer | Effect |
|---|---|---|---|
| Q1 | Stores | Android: Google Play and direct APK. iOS: not decided yet | Play gate (store readiness §2) applies. iOS is not declared, so `ios/` is not touched (E4 deferred) |
| Q2 | Languages | English, Malayalam, Sanskrit | New gaps H1–H11; the language pack is mandatory |
| Q3 | Privacy policy URL | Not yet | Stays `TODO`; blocks the first Google Play release |
| Q4 | Email public | Yes | Gap B2 closed: the address stays in `app_config.json` and the two old files |
| Q5 | Publisher, website, copyright, licence | Later | Stay `TODO` in `docs/PROJECT_PROFILE.md` |
| Q6 | About badge | On; wording later | The badge part of Phase 7 waits for the wording |
| Q7 | ARB key prefixes | Rename all keys now | New Phase 5 |
| Q8 | Delete all data | Yes | Phase 8 |

---

## Plan for the fix (phases)

Each phase gets its own approval and change log. After each code phase I run `dart format .`,
`flutter analyze` and `flutter test`; after any Android build I run `android\gradlew --stop`
and end leftover Gradle/Kotlin daemons.

**Phase 1 — Docs and repository hygiene** — done (see Progress at the top).

**Phase 2 — Flutter upgrade to the latest stable** (F1–F3, F7; own change, as §5.3 requires)
- `flutter pub upgrade`, `flutter pub outdated`, `dart fix --apply`.
- Let the Flutter migrator update AGP / KGP / Gradle; keep the `gradle.properties` flags it writes.
- Replace `kotlinOptions` with `kotlin { compilerOptions { } }`.
- Give `intl` a caret constraint.
- Build dev and prod release APKs; check permissions with `aapt2` (no `INTERNET`).

**Phase 3 — `material_ui` / `cupertino_ui` migration** (F4, E5)
- `dart fix --apply --code=migrate_design_widgets`; set caret constraints.
- Use `AppLocalizations.delegate` + `GlobalMaterialLocalizations.delegates`.
- Add `MaterialUiCompatibilityBridge` if a plugin still uses the SDK Material library, and
  record it in `docs/architecture.md` §21.

**Phase 4 — Start-up, logging, errors, lifecycle** (D1–D5, C4)
- Add `lib/core/config/app_flavor_config.dart`, `lib/core/logging/app_logger.dart`
  (using the `logger` package — offline, no network deps; checked before adding), a
  `SafeErrorFallback` widget, and an app lifecycle service.
- Replace all `debugPrint` calls with `AppLogger`.
- Reorder `main.dart` to the §4.5 sequence (the saved app language is read here once Phase 9
  adds it). Update `docs/architecture.md` §5, §17.
- Tests for `AppFlavorConfig` and the error fallback.

**Phase 5 — Rename ARB keys to the guideline prefixes** (E3, Q7) — before any translation
- Give every key one of `action…`, `label…`, `title…`, `tab…`, `nav…`, `tooltip…` (short) or
  `desc…`, `help…`, `empty…`, `error…`, `body…`, `aboutDetail…` (long), chosen by how the
  string is used.
- A script in `tool/` does the rename in `app_en.arb` and every call site in `lib/` and
  `test/`; then `flutter gen-l10n`. The rename table goes in the change log.
- Done in batches by screen area if the diff is too large to review in one go.

**Phase 6 — Accessibility and l10n checks** (E1–E3)
- Add localized tooltips to the 3 AirQR receiver buttons.
- Add `test/helpers/tooltip_expectations.dart` and call it from the screen tests.
- Add `test/l10n/label_length_test.dart` using the prefixes (20 characters `en`, 22 `ml`/`sa`).

**Phase 7 — About screen to the standard** (C1–C5, H11)
- Add `LocalizedText`; change `AppConfig` and `app_config.json` to the §1.2 shape with
  `lowerCamelCase` keys and `en` / `ml` / `sa` entries; add `aboutDetail<Key>` ARB keys and the
  label lookup.
- Privacy-policy row once the URL exists (Q3).
- Signature badge (`lib/widgets/made_with_love.dart`, `AppColors.heart`, ARB `madeWithLove` /
  `madeWithLoveA11y`) once the wording is in the profile (Q6). If it is still missing, this
  part waits and the rest of the phase goes ahead.
- About JSON config test from standard §8.7. Update `test/screens/about_screen_test.dart`.

**Phase 8 — Delete all data** (G1)
- A service that closes the DB and deletes the DB file, preferences, cache and temp files;
  a provider; a Settings row with a destructive confirm dialog; tests; help text in ARB.

**Phase 9 — Multi-language foundation** (H2–H9), still English-only on screen
- `LocaleController` provider (`app_language` = `system` | `en` | `ml` | `sa`), read before the
  first frame; `MaterialApp.locale` driven by it; `localeResolutionCallback`.
- Language picker in Settings: System default, `English`, `മലയാളം`, `संस्कृतम्`. It offers
  `ml` / `sa` only once Phase 10 finishes.
- Fallback delegates for `sa` (`lib/l10n/fallback_localizations.dart`) and a widget test that
  opens a date picker and a dialog under `sa`.
- `formattingLocale(...)` helper; route every `intl` call through it.
- Bundle Noto Sans Devanagari (OFL, subset if possible) and set a UI `fontFamilyFallback`
  chain for Malayalam and Devanagari; register its licence like the lyric fonts.
- `bundle { language { enableSplit = false } }` in `android/app/build.gradle.kts`.
- `test/l10n/translation_parity_test.dart` (standard §8.7) and
  `tool/check_sanskrit_hindi_markers.sh` (pack §4.1), added as a step in
  `.github/workflows/ci.yml`.
- `docs/glossary.md` for app-specific music terms in `en` / `ml` / `sa`.

**Phase 10 — Malayalam and Sanskrit translations** (H1, H10), in batches
- Batches by screen area, like the earlier English l10n batches (songbook and setlists,
  editor, performance view, settings and About, import/export and AirQR, help text in several
  batches, service messages).
- Each batch adds the same keys to `app_ml.arb` and `app_sa.arb`, following the pack's rules
  and glossary.
- All Malayalam and Sanskrit written by the AI agent is a **draft**. Each change log lists
  every new string as "needs native-reader review". `ml` and `sa` are switched on in the
  picker only after the last batch, when the parity test and the Hindi-marker gate pass.
  Before a release ships them, a fluent reader must review them (reviewer roles: profile §4).

## Phase 6 — proposed shorter texts (for review)

**Status of this section:** approved by the user on 2026-10-23 (all 48 texts, the 14 Help
edits and the 2 optional edits) and applied in Phase 6 part 2.

The length test (standard §8.6) allows at most **20 characters** for `action…`, `label…`,
`title…`, `tab…`, `nav…` and `tooltip…` strings in English. Counting rule used: a plural is
checked one branch at a time, and a `{placeholder}` counts as 3 characters. With that rule
**48** strings are over the limit (Phase 5 estimated 55 with a rougher count).

Each proposal keeps the meaning. Where words are dropped, the note says where the detail
still appears (a subtitle under the row, or Help).

| # | Key | Now | Proposed | Chars | Note |
|---|---|---|---|---|---|
| 1 | `tooltipSongListExportSelected` | Export selected (ChordPro) | **Export selected** | 15 |  |
| 2 | `tooltipSongListShareSelectedAirQr` | Share selected via AirQR | **Send via AirQR** | 14 |  |
| 3 | `titleSongListExportDialog` | Export selected songs as ChordPro | **Export selected** | 15 | Title of the system Save dialog |
| 4 | `titleSongListShareDialog` | {count, plural, =1{Share 1 selected song} other{Share {count} selected songs}} | **{count, plural, =1{Share 1 song} other{Share {count} songs}}** | 15 |  |
| 5 | `tooltipSetlistShareAirQr` | Share Setlist via AirQR Stream | **Send via AirQR** | 14 |  |
| 6 | `labelSetlistDescription` | Description (optional) | **Details (optional)** | 18 |  |
| 7 | `actionEditorPasteCarnatic` | Paste Carnatic notation | **Paste Carnatic** | 14 | Also the sheet title |
| 8 | `labelSongMetaSetlist` | Add to Setlist (Optional) | **Add to setlist** | 14 | "Optional" dropped; the first choice is already "None" |
| 9 | `tooltipMelodyKeypadHold` | Ring on for one more beat | **Hold one more beat** | 18 |  |
| 10 | `tooltipMelodyKeypadBar` | Group divider — takes no time | **Group divider** | 13 | "takes no time" dropped; Help explains it |
| 11 | `tooltipMelodyKeypadShare` | The next note shares this beat | **Share this beat** | 15 |  |
| 12 | `tooltipMelodyKeypadTie` | Start the next note part-way through a beat | **Start mid-beat** | 14 |  |
| 13 | `labelCarnaticSheetAnyaTitle` | Shuddha madhyamam in Ga-Ma-Ri | **Ma1 in Ga-Ma-Ri** | 15 | Uses the app's own name for shuddha madhyamam; the subtitle under the switch still explains it |
| 14 | `tooltipMelodyLineNeedsTonic` | Add a {directive} line to hear this | **Needs a {directive} line** | 16 |  |
| 15 | `actionPerfChordReferenceGuide` | Chord Reference Guide | **Chord Reference** | 15 | Same words as the dialog title |
| 16 | `labelPerfFormatAirQr` | AirQR Stream (Animated QR) | **AirQR stream** | 12 |  |
| 17 | `tooltipPerfDrone` | Pitch pipe & shruti box | **Pitch pipe & drone** | 18 |  |
| 18 | `tooltipPerfSpeed` | Scroll speed — double-tap the sheet to change | **Scroll speed** | 12 | The double-tap hint moves to Help only (already there) |
| 19 | `tooltipStageQuietActive` | Stage Quiet Mode (Active) | **Turn off Quiet Mode** | 19 | Names the action, not the state (standard 7.8) |
| 20 | `tooltipStageQuietInactive` | Stage Quiet Mode (Mute ringer/alerts) | **Turn on Quiet Mode** | 18 | Names the action, not the state (standard 7.8) |
| 21 | `labelGesturesDoubleTapBottom` | Double-tap bottom half | **Double-tap bottom** | 17 |  |
| 22 | `labelGesturesPinch` | Pinch with two fingers | **Two-finger pinch** | 16 |  |
| 23 | `labelGesturesFullScreen` | Full screen (Stage Mode) | **Full screen** | 11 |  |
| 24 | `actionMetronomeUseSongTempo` | Use song tempo ({bpm} BPM) | **Use song tempo** | 14 | Loses the song BPM on the button. Help already quotes "Use song tempo". Alternative: "Song tempo {bpm}" (14) |
| 25 | `actionMetronomeNoSongTempoToRestore` | No song tempo to go back to | **No song tempo** | 13 |  |
| 26 | `tooltipMetronomeStop` | Stop metronome ({bpm} BPM) · long press for tempo | **Stop metronome** | 14 | The BPM is on the button; "long press for tempo" moves to Help only |
| 27 | `tooltipMetronomeStart` | Start metronome ({bpm} BPM) · long press for tempo | **Start metronome** | 15 | As above |
| 28 | `titleDrone` | Pitch Pipe & Shruti Box | **Pitch Pipe & Drone** | 18 |  |
| 29 | `labelImportStrategyRenameImported` | Rename imported songs | **Rename imported** | 15 | The line under each choice explains it |
| 30 | `labelImportStrategyRenameExisting` | Rename existing songs | **Rename existing** | 15 | As above |
| 31 | `labelImportStrategyUserSuggested` | User suggested name for imported song | **Ask for a new name** | 18 | As above |
| 32 | `titleDroneSettingsIndianSongs` | Indian songs (Carnatic / Hindustani) | **Indian songs** | 12 | The caption under it names Carnatic and Hindustani |
| 33 | `labelDroneSettingsDefaultQuality` | Default chord quality | **Chord quality** | 13 |  |
| 34 | `titleDroneSettingsEverything` | Applies to everything | **All songs** | 9 | The caption says "These affect both traditions." |
| 35 | `labelImportExportPickFiles` | Import ChordPro file(s) | **Import ChordPro** | 15 | The subtitle lists the file types |
| 36 | `labelImportExportScan` | AirQR Scan Import (Camera / Photo) | **Import via AirQR** | 16 | The subtitle says camera or photo |
| 37 | `labelImportExportAllChordPro` | Export all songs (ChordPro) | **Export all songs** | 16 | The subtitle says ChordPro |
| 38 | `labelImportExportAllAirQr` | Export all songs via AirQR Stream | **Send all via AirQR** | 18 |  |
| 39 | `titleImportExportAllDialog` | Export all songs as ChordPro | **Export all songs** | 16 | Title of the system Save dialog |
| 40 | `titleImportExportFullSongbook` | {count, plural, =1{Full Songbook (1 song)} other{Full Songbook ({count} songs)}} | **{count, plural, =1{Songbook (1 song)} other{Songbook ({count} songs)}}** | 20 |  |
| 41 | `actionImportPreviewImportSelected` | Import Selected ({count}) | **Import ({count})** | 12 |  |
| 42 | `tooltipAirQrReceiverGallery` | Scan Photo from Gallery | **Scan a photo** | 12 |  |
| 43 | `actionAirQrTransmitterResume` | Resume Optical Stream | **Resume stream** | 13 | Suggest the same for Pause: "Pause stream" |
| 44 | `titleHelpTranspose` | Transpose & chord shapes | **Transpose & chords** | 18 |  |
| 45 | `titleHelpPitchPipeDrone` | Pitch Pipe & Shruti Box | **Pitch Pipe & Drone** | 18 | Same as the sheet title |
| 46 | `titleHelpIndianSongs` | Carnatic & Hindustani songs | **Indian songs** | 12 |  |
| 47 | `titleHelpAirqr` | AirQR — songs screen to screen | **AirQR sharing** | 13 |  |
| 48 | `titleHelpAppearance` | Themes, fonts & text size | **Themes & fonts** | 14 | Text size is covered inside the topic |

### Matching Help edits

Help quotes some of these texts. To keep Help pointing at real names, these Help strings
change too (only the quoted words change):

| # | Key | Now | Proposed |
|---|---|---|---|
| H1 | `helpEditorS5P2` | Paste Carnatic notation — turn a block of published notation into melody lines. See the Carnatic & Hindustani topic. | Paste Carnatic — turn a block of published notation into melody lines. See the Indian songs topic. |
| H2 | `helpIndianSongsS5P1` | In the editor, More options → "Paste Carnatic notation" takes … | In the editor, More options → "Paste Carnatic" takes … |
| H3 | `helpMelodyS1P7` | … — see the Carnatic & Hindustani topic. | … — see the Indian songs topic. |
| H4 | `helpTransposeS4Heading` | Chord Reference Guide | Chord Reference |
| H5 | `helpTransposeS4P1` | Top-bar menu → "Chord Reference Guide" lists … | Top-bar menu → "Chord Reference" lists … |
| H6 | `helpIndianSongsS3P3` | The menu offers "Swara Reference" in place of the Chord Reference Guide. | The menu offers "Swara Reference" in place of Chord Reference. |
| H7 | `helpAirqrS1P2` | Pick "AirQR Stream (Animated QR)" and tap Share. | Pick "AirQR stream" and tap Share. |
| H8 | `helpPitchPipeDroneS2P3` | Settings → General → Pitch Pipe & Shruti Box sets the defaults … | Settings → General → Pitch Pipe & Drone sets the defaults … |
| H9 | `helpPitchPipeDroneS7P3` | Settings → General → Pitch Pipe & Shruti Box has the same chips … | Settings → General → Pitch Pipe & Drone has the same chips … |
| H10 | `helpExportS1Heading` | Export all songs (ChordPro) | Export all songs |
| H11 | `helpExportS1P2` | Tap "Export all songs (ChordPro)". | Tap "Export all songs". |
| H12 | `helpAirqrS2P1` | … → "Export all songs via AirQR Stream" sends the whole songbook. | … → "Send all via AirQR" sends the whole songbook. |
| H13 | `helpAirqrS3P1` | … → Import → "AirQR Scan Import". | … → Import → "Import via AirQR". |
| H14 | `helpEditorS3P4` | "Add to Setlist" drops the song into a setlist as you save it. | "Add to setlist" drops the song into a setlist as you save it. |

The `@…` translator descriptions that name an old topic title (for example
"Help › Pitch Pipe & Shruti Box › …") are updated to the new title too. They are not shown
in the app.

### Optional, for consistency (already within the limit)

- `actionAirQrTransmitterPause`: "Pause Optical Stream" → "Pause stream" (pairs with #43).
- `labelGesturesDoubleTapTop`: "Double-tap top half" → "Double-tap top" (pairs with #21).

### Until the review

The Phase 6 length test is added now with a temporary list of these 48 keys as known
exceptions, so the test suite stays green. The test also fails if a key on that list is
already short enough, so the list can only shrink. When the texts are approved and applied,
the list becomes empty.

## Files to be changed

Phase 1 files are listed in its change log. For Phases 2–10:

- New: `lib/core/config/app_flavor_config.dart`, `lib/core/logging/app_logger.dart`,
  `lib/widgets/safe_error_fallback.dart`, `lib/services/app_lifecycle_service.dart`,
  `lib/services/data_purge_service.dart`, `lib/widgets/made_with_love.dart`,
  `lib/providers/locale_provider.dart`, `lib/l10n/fallback_localizations.dart`,
  `lib/core/utils/formatting_locale.dart`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb`
  (+ generated files), `assets/fonts/NotoSansDevanagari-*.ttf` and its licence file,
  `docs/glossary.md`, `tool/rename_arb_keys.dart`, `tool/check_sanskrit_hindi_markers.sh`,
  `test/helpers/tooltip_expectations.dart`, `test/l10n/label_length_test.dart`,
  `test/l10n/translation_parity_test.dart`, plus tests for new classes.
- Changed: `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.github/workflows/ci.yml`,
  `docs/architecture.md`, `docs/dependencies.md`, `docs/security.md`,
  `android/app/build.gradle.kts`, `android/settings.gradle.kts`,
  `android/gradle/wrapper/gradle-wrapper.properties`, `android/gradle.properties`,
  `assets/config/app_config.json`, `lib/main.dart`, `lib/core/config/app_config.dart`,
  `lib/core/config/config_service.dart`, `lib/screens/about_screen.dart`,
  `lib/screens/air_qr_receiver_screen.dart`, `lib/screens/settings_screen.dart`,
  `lib/screens/general_settings_screen.dart`, `lib/theme/app_colors.dart`,
  `lib/theme/app_theme.dart`, `lib/l10n/app_en.arb` (+ generated l10n files), the 10 files
  with `debugPrint`, the 91 files whose Material import changes (Phase 3, by `dart fix`), and
  every file that uses an ARB key (Phase 5, by script).

## Out of scope

- Any edit inside `docs/guidelines/` (read-only). The submodule pointer change from the last
  update stays for you to commit.
- `ios/` changes (E4 and any iOS work) until iOS is declared.
- Store listing work (screenshots, Data safety form, the Malayalam Play listing) — done in the
  Play Console.
- The native-reader review itself — done by people the user names.
