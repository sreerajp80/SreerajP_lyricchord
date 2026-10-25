# Architecture — SreerajP_lyricchord

This document describes the technical design of the LyricCord Flutter app. Read
it before adding or changing app structure, state, storage, or navigation, so
the code stays consistent with these decisions.

LyricCord is a Flutter re-implementation of the existing Android app. The
product intent lives in the idea doc; this file is the "how".

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — plan-before-changing and log-after-changing rules.
- [lyriccord_idea.md](lyriccord_idea.md) — the product concept and features.
- [guidelines/architecture.md](guidelines/architecture.md) — the blueprint this
  file is filled in from.
- [guidelines/guideline.md](guidelines/guideline.md) — About-screen config and
  the baseline `lib/` layout that this app follows.
- [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)
  — the cross-app rulebook.

---

## 1. Scope

- **Product:** LyricChord
- **Application id / namespace:** `in.sreerajp.lyricchord`
- **Repository type:** application
- **Toolchain:** Flutter 3.44.8 (stable), Dart 3.12.2
- **Engineering standard profiles in force:**
  - `Core Baseline` — always.
  - `Production App Extension` — yes; the app is meant to ship to real users.
  - `Sensitive Data Extension` — **N/A.** The app stores only user-written song
    sheets locally; no secrets, PII, health, or finance data.
- **Platforms:** Android and iOS. Desktop (Windows) is a possible later target,
  not built now.

---

## 2. Goals And Non-Goals

### Goals

- Reproduce the Android app's experience exactly (songbook, editor, performance
  view, transpose, auto-scroll, chord diagrams, import/export).
- One Flutter codebase for Android and iOS.
- Stay fully offline and fast on a mid-range phone.

### Non-Goals

- No accounts, cloud sync, or sharing services.
- No AI features (the Android project declared Gemini but never used it).
- No redesign — this is a like-for-like port, not a new product.

---

## 3. Architecture Summary

> The app uses a Tier 1 layered Flutter structure with Riverpod for state
> management. Screens read state from Riverpod providers and call services for
> logic (transposition, ChordPro parsing, PDF export). Song data is persisted in
> a local `drift` (SQLite) database behind a repository, exposed as reactive
> streams so the list and performance views update live. The single setting
> (theme mode) is stored in `shared_preferences`. The app is fully offline; it
> requests no network permission.

---

## 4. Repository Structure

### Current Structure Tier

- **Tier 1** (layered, single feature area).
- Why this tier is appropriate now:
  - The whole app is one feature area — a songbook — so feature folders would
    add ceremony without benefit.
  - Small, single-developer project; a flat layered layout is easiest to keep
    consistent.

### Top-Level Source Layout

Follows the baseline layout from [guidelines/guideline.md](guidelines/guideline.md) §3.

```text
lib/
|-- main.dart
|-- core/
|   |-- config/         # AppConfig + ConfigService (About screen, fixed path); AppFlavorConfig
|   |-- constants/      # app_constants.dart — db name, pref keys, thresholds
|   |-- errors/         # AppException hierarchy; global error handlers
|   |-- logging/        # AppLogger
|   |-- startup/        # AppStartup: start-up steps 5–8 and the restart after Delete all data
|   `-- utils/          # small helpers/extensions
|-- models/             # SongNote and value types, MelodyNote/MelodyBeat/MelodyLine
|-- services/           # ChordTransposer, ChordProService, PdfExportService, ScrollController logic,
|                       # MetronomeCalculator (beat math), MetronomeAudioService (click playback),
|                       # PcmSynthService (WAV synthesis for pitch cue, drone, click and melody),
|                       # MelodyParser (melody text -> beats), MelodyPlayerService (beats -> timed
|                       # spans), MelodyAudioService (one rendered WAV per line)
|-- repositories/       # SongRepository over the drift database
|-- data/               # drift database + DAO definitions
|-- providers/          # Riverpod providers (app state)
|-- screens/            # SongListScreen, SongDetailScreen, SongEditorScreen, AboutScreen
|-- widgets/            # ChordLyricsView, ChordDiagram (guitar/harmonium), controls
`-- theme/              # colors, text styles, ThemeData (light/dark)
```

### Ownership Rules

| Path | Responsibility |
|------|----------------|
| `lib/screens/` | Full-page UI; reads providers, no SQL/parsing logic |
| `lib/widgets/` | Reusable UI (chord/lyric rendering, diagrams, controls) |
| `lib/providers/` | App/screen state and glue between UI and services |
| `lib/services/` | Pure logic: transpose, ChordPro parse/format, PDF export, beat math, audio synthesis/playback |
| `lib/repositories/` | Data access; abstracts the drift database |
| `lib/data/` | drift database, tables, DAOs |
| `lib/core/config/` | About-screen `AppConfig` + `ConfigService` (fixed); `AppFlavorConfig` |
| `lib/core/logging/` | `AppLogger`, the only logger |
| `lib/core/startup/` | `AppStartup`: opens the data, runs the app, restarts it fresh after Delete all data |

---

## 5. App Initialization Sequence

Order of steps in `main()` before `runApp`.

The numbers follow engineering standard §4.5. Steps 1–2 are in `lib/main.dart`;
steps 5–8 are in `AppStartup.start` (`lib/core/startup/app_startup.dart`), so
`main.dart` stays thin.

| Step | Code / Call | Notes |
|------|-------------|-------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Always first |
| 2 | `AppLogger.init()`, `installGlobalErrorHandlers()` | Every later step can log its failure. Then the font licences are registered (read lazily) |
| 3 | — | No desktop FFI set-up: the app is mobile-only |
| 4 | — | No secure storage: the app keeps no secrets |
| 5 | `AppDatabase()` | Opens on first use; applies migrations and seeds the classic songs on first run |
| 6 | `SharedPreferences.getInstance()` | Saved settings (theme), so the first frame uses the right theme. The About `AppConfig` is loaded lazily by `appConfigProvider` when the About screen opens |
| 7 | `AppLifecycleService(...).init()` | App-wide lifecycle handling (§6) |
| 8 | `runApp(ProviderScope(...))` | Overrides inject the database and preferences into Riverpod |

- Steps 5–8 run inside one `try`. If any of them fails, the failure is logged as
  `fatal` and the app shows `StartupErrorApp` (`lib/screens/startup_error_screen.dart`):
  a plain explanation, **Try again** (runs steps 5–8 again) and **Copy details**.
- First-run seeding of the sample songs happens as part of database open (step 5),
  matching the Android app's seeded content.

---

## 6. App Lifecycle Behavior

| Lifecycle State | App Behavior |
|----------------|--------------|
| `resumed` | Nothing special; providers already hold current state |
| `inactive` | N/A — no sensitive content to obscure |
| `paused` | Auto-scroll stops; any in-flight DB write completes normally |
| `detached` | `AppLifecycleService` runs a write-ahead-log checkpoint (`AppDatabase.checkpointWal`). The database is **not** closed — see §20 |
| Memory pressure | `AppLifecycleService` clears the image cache |

`AppLifecycleService` (`lib/services/app_lifecycle_service.dart`) is the app-wide
observer. The performance view (wake lock, scroll-speed flush on `paused`) and the
AirQR receiver (camera) keep their own observers for screen-specific behaviour.

---

## 7. Offline Behavior

- **Connectivity requirement:** fully offline.
- **Network permission:** `INTERNET` permission absent. The app makes no network
  calls.
- **Offline data source:** local `drift` (SQLite) database plus
  `shared_preferences`.

Because the app is fully offline:

- The merged Android release manifest MUST NOT contain
  `<uses-permission android:name="android.permission.INTERNET" />`. Verify on the
  built artifact, e.g.:

  ```bash
  aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
  ```

- No package that performs network I/O should be added. Import/export use the
  device file picker only.

See [security.md](security.md) for the full offline posture.

---

## 8. State Management

- **Primary pattern:** Riverpod.
- **Why:**
  - Cleanly replaces the Android `ViewModel` + `StateFlow` model with providers
    and reactive `Stream`/`Notifier` state.
  - Easy to inject the database, prefs, and config for tests via
    `ProviderScope` overrides.
- **State boundaries:**
  - Widgets own: local UI state (expanded/collapsed controls, text field focus).
  - State layer (providers) owns: selected song, editing flag, search query,
    transpose amount, show-chords, font size, scroll speed, theme mode.
  - Services own: transposition, ChordPro parse/format, PDF export.

---

## 9. Data Flow

```text
Widget -> Provider (state) -> Service / Repository -> drift DAO -> SQLite
```

### Rules

- Widgets must not know: SQL, ChordPro syntax, or PDF drawing.
- Services must not know: navigation or widget copy.
- Repositories abstract: the drift database behind plain model streams.

---

## 10. Error Handling Architecture

- **Global error handlers:** `installGlobalErrorHandlers()`
  (`lib/core/errors/global_error_handlers.dart`), called in `main()` step 2.
  `FlutterError.onError` and `PlatformDispatcher.instance.onError` log through
  `AppLogger`; in release builds `ErrorWidget.builder` shows `SafeErrorFallback`
  (`lib/widgets/safe_error_fallback.dart`) — a calm message and an icon, no error
  detail — instead of the grey error box. Debug builds keep Flutter's red box.
- **Domain exceptions:** a small sealed hierarchy in
  `lib/core/errors/app_exception.dart`.

| Exception Class | Thrown By | Meaning |
|----------------|-----------|---------|
| `StorageException` | Repository | Database read/write failure |
| `ImportException` | ChordPro service | File could not be parsed as ChordPro |
| `ExportException` | PDF / ChordPro export | Could not write the output file |

- **Escalation policy:** import/export failures surface as a `SnackBar` (the
  Android app used a `Toast`); they never crash the app.
- **Fatal error screen:** `StartupErrorApp`, shown when start-up fails (§5). It has
  **Try again** and **Copy details** (standard §11.4).

---

## 11. Domain Model

### Current Schema Version

SQLite schema version: `11` (`AppDatabase.schemaVersion`; increment when a migration is added).

Migration history:

| Version | Change Summary |
|---------|---------------|
| 1 | Initial schema: `song_notes` table |
| 2 | `setlists` and `setlist_items` tables |
| 3 | `song_notes.scrollSpeed` and `song_notes.scrollMeasures` |
| 4 | Seeds any missing classical songs |
| 5–8 | Rewrote the seeded classical songs in swara notation |
| 9 | `song_notes.raga`, `song_notes.tala`, `song_notes.tradition` |
| 10 | Rewrote the sample song with its real words and `{melody}` lines |
| 11 | `song_notes.scrollSpeedSet` (marks songs whose scroll speed was set by hand) |

### Core Models Or Entities

| Type | Purpose | Mutable? | Notes |
|------|---------|----------|-------|
| `SongNote` | One song sheet | No (copyWith) | Fields below |

`SongNote` fields (ported 1:1 from the Android Room entity):

| Field | Type | Meaning |
|-------|------|---------|
| `id` | int (auto) | Primary key |
| `title` | String | Song title |
| `artist` | String | Artist / band (may be empty) |
| `lyrics` | String | Lyrics with inline `[Chord]` markers |
| `key` | String | Original key (e.g. `C`, `Am`) |
| `bpm` | int | Tempo in BPM |
| `favorite` | bool | Starred |
| `timestamp` | int | Last-modified time (ms since epoch) |
| `scrollSpeed` | double | Manual auto-scroll speed last used |
| `scrollMeasures` | int | Tempo-Auto length last used |
| `raga` | String | Raga name; empty on a Western song |
| `tala` | String | Tala name; empty on a Western song |
| `tradition` | `PitchTradition?` | `western`, `carnatic`, `hindustani`; `null` = not classified |

### Which Notation A Song Is Written In

A song is either Western (chords) or Indian (swaras). The app never mixes the
two on one sheet.

- **Western vs Indian** is decided by the stored `tradition` column, read
  through `SongNote.isIndian`. When `tradition` is `null` — a song that somehow
  escaped the version 9 backfill — it falls back to the old rule, "does it name
  a raga".
- **Carnatic vs Hindustani** is decided by the **tala**, not the raga
  (`PitchNamingService.detect`). Tala names split cleanly between the two
  traditions; many raga names are shared, so a raga cannot settle it.
- The `{raga: …}` and `{tala: …}` header lines inside the lyrics are legacy
  input only. They are still parsed for imports and still hidden from the drawn
  sheet, but the columns are the source of truth.

Why the column exists: reading the header line meant a typo such as
`{ragam: …}` made an Indian song look Western, and the transposer would then
rewrite `[Ga]` and `[Dha]` as the chords G and D — silently damaging the sheet.
It also meant a song with a raga but no readable tala fell back to the user's
global "Pitch naming" setting, so the same song read Carnatic on one phone and
Hindustani on another.

### Serialization Strategy

- JSON models: no (no network/transport layer).
- Database models: yes, via drift row mapping.
- Separate domain vs transport models: not needed — one `SongNote` is used
  throughout; there is no transport layer.

### Database Indexes

| Table | Indexed Columns | Reason |
|-------|----------------|--------|
| `song_notes` | (none beyond primary key) | Search is an in-memory filter over a small local list, matching the Android app |

---

## 12. Dependency Management And Injection

- **DI approach:** Riverpod provider tree.
- **App-root dependencies (injected via `ProviderScope` overrides):**
  - drift database / `SongRepository`
  - `shared_preferences` instance
  - `AppConfig` (from `ConfigService`)
- **Test replacement strategy:** override the repository and prefs providers with
  fakes; use an in-memory drift database for repository tests.

---

## 13. Navigation

- **Navigation approach:** go_router.
- **Route definition location:** `lib/core/router` (or `lib/router.dart`).
- **Routes:**

| Route | Screen |
|-------|--------|
| `/` | Song list |
| `/song/:id` | Performance (detail) view |
| `/song/:id/edit` | Editor (edit existing) |
| `/new` | Editor (new song) |
| `/about` | About screen |

- **Protected routes:** none (no auth or app-lock).
- **Deep-link support:** not required.
- On tablet (width ≥ 600 dp) the list and detail/editor are shown together in a
  dual-pane layout; go_router still drives which song/editor is active.

---

## 14. Persistence And External Systems

### Local Storage

- **Database:** drift (SQLite).
- **WAL mode:** enabled (drift default) — fine for a single-writer app.
- **Key-value storage:** `shared_preferences` (theme mode only).
- **Secure storage:** N/A — nothing sensitive is stored.

### Network

- **Network client:** none.
- **Offline behavior:** fully offline.

### Platform Channels Or Native Integrations

- File picker (import/export) via a file-picker package.
- Share/print for PDF via the `printing` package.

---

## 15. Environment And Build Model

- **Flavors used:** none for now (single flavor). If dev/prod split is needed
  later, follow [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md).
- **Runtime config mechanism:** `assets/config/app_config.json` for About-screen
  values; technical constants in `lib/core/constants/app_constants.dart`.
  Every text a user reads in the JSON (`appName`, `description`, display rows in
  `details`) is a per-language map with `en`, `ml` and `sa`; addresses and links
  (`email`, `website`, `privacyPolicy`) may be plain strings. `details` keys are
  `lowerCamelCase` ids; the About screen shows each row under the ARB label
  `aboutDetail<Key>` (`aboutDetailLabel` in `lib/l10n/l10n_labels.dart`).
  `test/l10n/app_config_test.dart` checks all of this, and that `version`/`build`
  match `pubspec.yaml`.
- **Generated build metadata:** `tool/generate_app_version.dart` writes
  `lib/core/constants/app_version.g.dart` (`kAppVersion`, read from the
  `version:` line in `pubspec.yaml`) and `tool/generate_build_date.dart` writes
  `lib/core/constants/build_date.g.dart` (`kBuildDate`, today's date). The
  Gradle task `generateBuildMetadata` in `android/app/build.gradle.kts` runs
  both before the Dart code is compiled, so every Android build refreshes them
  and prints the new values. Both generated files are committed so tests and
  iOS builds work without Gradle. The About screen shows `kAppVersion` (falling
  back to the `app_config.json` values only if it is empty) and `kBuildDate`.
  Never hand-edit the two `.g.dart` files; run the scripts instead.
- **Build outputs supported:**
  - debug APK
  - release APK (split-per-ABI)
  - release app bundle (`.aab`) for Play
  - iOS release build
- **Obfuscation:** enabled for prod release builds; symbols stored under
  `build/symbols/` (see the release process when set up).

---

## 16. UI System

- **Theme source of truth:** `lib/theme/` — a Material 3 `ColorScheme` built from
  the violet "High Density" palette (primary `#6750A4` light / `#D0BCFF` dark).
- **Design tokens location:** `lib/theme/` (colors, text styles).
- **Material library:** `material_ui` (not the SDK's `package:flutter/material.dart`).
  No `MaterialUiCompatibilityBridge` is used: the runtime packages that still import the
  SDK Material library (`printing`, `qr_flutter`, `mobile_scanner`, `flutter_riverpod`) only
  use its colour and icon constants, never `Theme.of` or Material localizations, and
  `go_router` 18 is built on `material_ui`. Re-check this when adding a package that renders
  Material widgets.
- **Languages (engineering standard §8):** English, Malayalam, Sanskrit are declared.
  - `localeProvider` (`lib/providers/locale_provider.dart`) is the only place that holds the
    app language; `MaterialApp.locale` follows it. It is read from `shared_preferences`
    (`app_language`) before the first frame; `null` follows the phone, resolved by
    `resolveAppLocale` (phone language if the app has it, else English).
  - Settings → Language (`language_settings_screen.dart`) lists System default and each
    language with strings, by its own name (`lib/l10n/language_names.dart`).
  - Sanskrit has no Flutter framework strings: `lib/l10n/fallback_localizations.dart` serves
    English ones (never Hindi); they come first in `appLocalizationsDelegates`.
  - Numbers shown to the user go through `formatFixed` / `formattingLocale`
    (`lib/core/utils/formatting_locale.dart`), which use English patterns for Sanskrit.
  - UI text falls back to the bundled Noto Sans Malayalam, then Noto Sans Devanagari
    (`AppTheme.uiFontFallback`).
  - Checks: `test/l10n/translation_parity_test.dart`, `test/l10n/label_length_test.dart`,
    `test/l10n/app_config_test.dart`, and `tool/check_sanskrit_hindi_markers.sh` (CI).
- **Shared widget strategy:** reusable rendering (chord-over-lyric view, guitar
  and harmonium diagrams, performance controls) lives in `lib/widgets/`.
- **Accessibility expectations:**
  - Minimum touch target: 48 × 48 dp on mobile.
  - Color contrast: WCAG AA (4.5:1 normal, 3:1 large).
  - Screen reader: TalkBack (Android), VoiceOver (iOS) sanity-checked before
    release.
  - Text scale: verified at 1.0×, 1.5×, 2.0× (the in-app font-size control is
    separate from OS text scale).

---

## 17. Logging

- **Logger implementation:** `AppLogger` (`lib/core/logging/app_logger.dart`) over the
  `logger` package. `print` and `debugPrint` are not used.
- **Levels:** dev flavor — every level (`trace` and up), with error detail and stack
  traces. prod flavor — `info` and up; `trace` and `debug` print nothing.
- **Release redaction:** in prod release builds an error is logged by its type only,
  never its message or stack trace, because a message can carry song text or a file
  name.
- **Output:** console only (logcat on Android). **No log file** is written, so there is
  no rotation (standard §14.4 does not apply) and no logs to purge.
- **Verbose logging gate:** the flavor (`AppFlavorConfig.enableVerboseLogging`), not
  `kDebugMode`.
- **Sensitive data policy:** nothing sensitive exists to log; song content is not
  logged in release builds.

---

## 18. Testing Strategy

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit | Transpose, ChordPro parse/format, chord-line parsing | Pure logic, highest value |
| Widget | List, editor, performance controls | Golden tests for chord/lyric layout |
| Integration | Create → edit → transpose → export flow | End-to-end on a device/emulator |
| Performance | Auto-scroll smoothness | Frame budget on mid-range device |

### Test Layout

```text
test/
|-- services/          # transpose, chordpro
|-- repositories/      # in-memory drift db
|-- widgets/           # chord/lyric rendering goldens
|-- helpers/
`-- fixtures/          # sample ChordPro files
```

### Critical Test Areas

- Chord transposition (sharps/flats, slash chords, wrap-around).
- ChordPro import/export round-trip.
- Chord-over-lyric line parsing (the `[C]word` renderer).
- Tempo-Auto scroll math (ends exactly at song end).
- Database seeding on first run.
- Melody line parsing: every mark, and broken input that must never throw.
- Melody timing: beats add up, bar lines take no time, half speed doubles every
  note without changing its pitch.

---

## 19. Operational Constraints

- **Minimum supported OS:** Android (target parity with the source app, min
  SDK 24 / Android 7) and a current iOS minimum; confirm exact versions at setup.
- **Performance constraints:**
  - Cold start under 2 seconds to first meaningful frame (release).
  - 16 ms frame budget at 60 Hz; sustained jank above 5% is release-blocking —
    especially during auto-scroll.
- **Regulatory or store constraints:** standard Play/App Store policies; no data
  collection to declare (fully offline).
- **Team constraints:** single developer.
- **Offline constraints:** no INTERNET permission, no network packages.

---

## 20. Decisions And Tradeoffs

| Decision | Chosen Option | Why | Tradeoff |
|----------|---------------|-----|----------|
| State management | Riverpod | Maps cleanly from ViewModel + StateFlow; testable | Small learning curve vs plain Provider |
| Local database | drift | Reactive streams like Room's Flow; type-safe | More setup than raw sqflite |
| Navigation | go_router | Declarative routes; handles dual-pane selection | Slight overhead for a small route set |
| PDF export | `pdf` + `printing` | Cross-platform; replaces Android `PdfDocument` | Chord-diagram drawing must be re-implemented |
| Structure tier | Tier 1 layered | One feature area; simplest that fits | Would need refactor if the app grows many features |
| Shutdown handling | Checkpoint the WAL on `detached`; do not close the database | On Android a detached engine can be shown again, and a closed drift database cannot be reopened. Every write is already committed, so nothing is lost | The database file stays open until the process ends |
| Log output | Console only, no log file | No user data ends up on disk; nothing to rotate or purge | No in-app log export for support (standard §14.4 is only for apps that write logs to disk) |

---

## 21. Known Risks And Follow-Ups

- **Risk:** Chord-over-lyric layout and auto-scroll are the hardest visual parts
  to match pixel-for-pixel from Compose.
  **Mitigation:** golden tests for the renderer; port the Tempo-Auto math
  directly.
- **Risk:** PDF chord diagrams must be redrawn in the `pdf` package's canvas API.
  **Mitigation:** reuse the same fret-data map and drawing logic from the Android
  `ExportUtils` as the reference.
- **Risk:** drift schema drift over time.
  **Mitigation:** bump schema version and add a migration for every table change;
  record it in §11.
- **Risk:** Flutter warns that apps and plugins applying the Kotlin Gradle Plugin will
  fail to build in a future Flutter. The app still uses `kotlin-android`
  (`android.builtInKotlin=false`, as the Flutter template writes), and `mobile_scanner`
  6.x applies the plugin itself.
  **Mitigation:** move to built-in Kotlin as its own change once every Android plugin
  supports it (`mobile_scanner` 7.x is the candidate); see
  `guidelines/flutter_build_flavors_guide.md` ("Android Toolchain Baseline").
- **Risk:** `file_picker` 12+ needs iOS 14.0, but the Xcode project still targets 13.0.
  **Mitigation:** raise the iOS deployment target to at least 14.0 when iOS is declared.
- **Risk:** `audioplayers` pulls in `http` as a transitive package, which
  [dependencies.md](dependencies.md) §4 forbids. Release builds have no `INTERNET`
  permission, so it cannot reach the network on Android.
  **Mitigation:** decide in its own plan (accept with this note, or replace
  `audioplayers`).

---

## 22. Related Documents

- [lyriccord_idea.md](lyriccord_idea.md)
- [implementation_plan.md](implementation_plan.md)
- [security.md](security.md)
- [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)
- [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md)
- [guidelines/release_process.md](guidelines/release_process.md) (when a release is set up)
