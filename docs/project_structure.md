# Project Structure — LyricChord

This document describes the directory tree layout, layer boundaries, and file
organization of the LyricChord project. Read this before adding new files or
restructuring existing modules.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — project architecture and layer rules.
- [architecture.md](architecture.md) — comprehensive architectural specification.
- [dependencies.md](dependencies.md) — external library roles and categories.

---

## 1. Architectural Overview

LyricChord follows a **Tier 1 Layer-First** directory structure under `lib/`.
Code is organized horizontally by technical responsibility rather than vertically by
feature. This guarantees clean separation of concerns:

- Business logic never leaks into user interface widgets.
- Presentation widgets never execute raw SQL queries or invoke file system commands.
- Data models are strictly immutable.
- Dependencies flow in a single direction.

---

## 2. Directory Tree Layout

```text
lyricchord/
|-- android/                 # Android native host project and Gradle configuration
|-- assets/                  # Bundled assets (app config, fonts, icons)
|   |-- config/              # app_config.json source of truth for About screen
|   |-- fonts/               # Bundled Malayalam SIL OFL font families
|   `-- icon/                # Master icon artwork for flutter_launcher_icons
|-- change_log/              # Post-implementation change logs (yyyymmdd_hhMMss_<slug>.md)
|-- docs/                    # Living design docs and guidelines submodule
|   |-- guidelines/          # Shared Flutter Guidelines git submodule (read-only)
|   `-- *.md                 # Architecture, security, release, and workflow docs
|-- ios/                     # iOS native host project and Xcode configuration
|-- lib/                     # Application Dart source code
|   |-- core/                # Cross-cutting foundational modules
|   |   |-- config/          # AppConfig and ConfigService
|   |   |-- constants/       # App-wide constants, keys, and generated build metadata
|   |   |-- errors/          # Custom exceptions and failure models
|   |   |-- router/          # go_router declarative route definitions
|   |   `-- utils/           # Pure utility helpers (text formatting, line breaks)
|   |-- data/                # Drift SQLite database, schema, tables, and DAOs
|   |-- l10n/                # ARB localization files and generated localizations
|   |-- models/              # Pure immutable domain data models
|   |-- providers/           # Riverpod state notifiers and providers
|   |-- repositories/        # Data access repositories abstracting the database
|   |-- screens/             # Full-page navigable screen widgets
|   |-- services/            # Pure business logic (parsers, audio synth, transposer)
|   |-- theme/               # Color palettes, typography, and ThemeData definitions
|   |-- widgets/             # Reusable UI widgets and dialog components
|   `-- main.dart            # Application entry point and top-level ProviderScope
|-- plans/                   # Pre-implementation plan files (yyyymmdd_hhMMss_<slug>.md)
|-- test/                    # Automated test suite mirroring lib/ structure
|   |-- core/                # Tests for utility helpers and config services
|   |-- data/                # Tests for database migrations and connection setup
|   |-- helpers/             # Test fakes and mock implementations
|   |-- providers/           # Tests for Riverpod state notifiers
|   |-- repositories/        # Tests for song and setlist repositories
|   |-- screens/             # Widget tests for full screens
|   |-- services/            # Unit tests for parsers, transposition, and audio synth
|   `-- widgets/             # Widget tests for reusable UI components
|-- tool/                    # Offline development helper scripts (metadata generator)
|-- analysis_options.yaml    # Static analysis and linter configuration
|-- l10n.yaml                # Flutter localization configuration
`-- pubspec.yaml             # Project dependencies and asset registrations
```

---

## 3. Layer Responsibilities & Rules

### 3.1 `core/`
Foundational code that has no dependency on domain models. Contains configuration
loaders, constants, router definitions, and string/line-break utilities.

### 3.2 `data/`
Owns SQLite persistence via Drift. Houses table definitions (`songs`, `setlists`),
queries, and database lifecycle management.
- **Rule:** Only repositories may interact directly with `AppDatabase`. Widgets and
  services must never touch database classes directly.

### 3.3 `models/`
Pure Dart domain models (`Song`, `Setlist`, `SongNote`, `PitchDroneSettings`).
- **Rule:** Models MUST be immutable. State mutations use `copyWith`.

### 3.4 `services/`
Stateless or stateful pure logic engines:
- `ChordSheetParser`: parses ChordPro directives and chord-over-lyric notations.
- `ChordTransposer`: transposes chords across keys.
- `PcmSynthService` & `PitchDroneAudioService`: procedural audio synthesis.
- **Rule:** Services must not know about UI, navigation, or presentation strings.

### 3.5 `repositories/`
Data mediation layer (`SongRepository`, `SetlistRepository`). Implements data
operations by delegating to Drift DAOs.

### 3.6 `providers/`
Riverpod state management. Exposes observable state streams to UI screens:
- `performance_provider`: manages auto-scroll position, speed, and transposition state.
- `pitch_drone_provider`: controls playback of tanpura and chord drones.

### 3.7 `screens/`
Full-page routes pushed via `go_router` (e.g., `SongListScreen`, `SongPerformanceScreen`).
- **Rule:** Screens consume providers and compose widgets; they do not contain
  heavy parsing or database query logic.

### 3.8 `widgets/`
Reusable presentation components (`ChordSheetView`, `AutoScrollControls`, `SongCard`).
- **Rule:** Widgets communicate upward via callbacks or Riverpod providers.

### 3.9 `l10n/`
Contains ARB string catalogs (`app_en.arb`) and generated accessors (`AppLocalizations`).
- **Rule:** All user-visible UI strings must be read through `AppLocalizations`.

---

## 4. Architectural Boundaries & Data Flow

Data flows in a single, predictable direction:

```text
[ SQLite Database / Disk ]
         ▲
         │ (Drift DAOs)
[ Repositories / Data Services ]
         ▲
         │ (Domain Models)
[ Riverpod Providers (State Notifiers) ]
         ▲
         │ (State / Events)
[ UI Screens & Reusable Widgets ]
```

- **Imports rule:** Always use package imports (`package:lyricchord/...`), never relative
  imports across directory layers.
