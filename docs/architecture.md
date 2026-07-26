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
- **Toolchain:** Flutter 3.41.9 (stable), Dart 3.11.5
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
|   |-- config/         # AppConfig + ConfigService (About screen). Fixed path.
|   |-- constants/      # app_constants.dart — db name, pref keys, thresholds
|   |-- errors/         # AppException hierarchy
|   `-- utils/          # small helpers/extensions
|-- models/             # SongNote and value types
|-- services/           # ChordTransposer, ChordProService, PdfExportService, ScrollController logic
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
| `lib/services/` | Pure logic: transpose, ChordPro parse/format, PDF export |
| `lib/repositories/` | Data access; abstracts the drift database |
| `lib/data/` | drift database, tables, DAOs |
| `lib/core/config/` | About-screen `AppConfig` + `ConfigService` (fixed) |

---

## 5. App Initialization Sequence

Order of steps in `main()` before `runApp`.

| Step | Code / Call | Notes |
|------|-------------|-------|
| 1 | `WidgetsFlutterBinding.ensureInitialized()` | Always first |
| 2 | Open drift database | Applies schema/migrations; seeds classic songs on first run |
| 3 | Load `AppConfig` via `ConfigService` | About-screen values |
| 4 | Read theme-mode from `shared_preferences` | So first frame uses the right theme |
| 5 | Build `ProviderScope` overrides (db, prefs, config) | Inject singletons into Riverpod |
| 6 | `runApp(ProviderScope(...))` | |

- No secure storage or FFI bootstrap is needed on mobile.
- First-run seeding of the three sample songs happens as part of database open
  (step 2), matching the Android app's seeded content.

---

## 6. App Lifecycle Behavior

| Lifecycle State | App Behavior |
|----------------|--------------|
| `resumed` | Nothing special; providers already hold current state |
| `inactive` | N/A — no sensitive content to obscure |
| `paused` | Auto-scroll stops; any in-flight DB write completes normally |
| `detached` | Database closed by the framework; no manual work needed |
| Memory pressure | N/A — no large image cache; diagrams are drawn, not loaded |

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

- **Global error handler:** `FlutterError.onError` and
  `PlatformDispatcher.instance.onError` set in `main()`.
- **Domain exceptions:** a small sealed hierarchy in
  `lib/core/errors/app_exception.dart`.

| Exception Class | Thrown By | Meaning |
|----------------|-----------|---------|
| `StorageException` | Repository | Database read/write failure |
| `ImportException` | ChordPro service | File could not be parsed as ChordPro |
| `ExportException` | PDF / ChordPro export | Could not write the output file |

- **Escalation policy:** import/export failures surface as a `SnackBar` (the
  Android app used a `Toast`); they never crash the app.
- **Fatal error screen:** a simple error widget shown by the global handler for
  unrecoverable startup errors (e.g. database open failure).

---

## 11. Domain Model

### Current Schema Version

SQLite schema version: `1` (increment when a migration is added).

Migration history:

| Version | Change Summary |
|---------|---------------|
| 1 | Initial schema: `song_notes` table |

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

- **Logger implementation:** `logger` package (or `dart:developer` `log`) — no
  network sinks.
- **Log file location:** N/A — console/debug logging only; no persisted logs.
- **Log rotation policy:** N/A.
- **Verbose logging gate:** `kDebugMode`.
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

---

## 22. Related Documents

- [lyriccord_idea.md](lyriccord_idea.md)
- [implementation_plan.md](implementation_plan.md)
- [security.md](security.md)
- [guidelines/flutter_project_engineering_standard.md](guidelines/flutter_project_engineering_standard.md)
- [guidelines/flutter_build_flavors_guide.md](guidelines/flutter_build_flavors_guide.md)
- [guidelines/release_process.md](guidelines/release_process.md) (when a release is set up)
