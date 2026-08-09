# LyricChord — App Description & Features Catalog

> **Note on scope:** This document describes features that are actually built and
> shipped in the app today. A separate document,
> [feature_analysis_and_innovations.md](feature_analysis_and_innovations.md), lists
> *proposed* ideas and enhancements that are **not implemented**. Do not treat
> anything in that other document as a current feature of the app.

## 1. App Description

**LyricChord** (`in.sreerajp.lyricchord`, Version 2.5.13+19) is a cross-platform (Android & iOS), privacy-first, **100% offline lyrics and chords notebook and live performance manager** engineered specifically for musicians, guitarists, keyboard/harmonium players, vocalists, worship leaders, and buskers.

The application addresses three core musical workflows:
1. **Creation, Editing & Library Management:** Authoring, organizing, and formatting lyric sheets with inline chord bracket syntax (`[Chord]word`), metadata (original key, BPM, artist), custom chord shortcuts, and key-aware scale degree chord suggestions — with instant search, starred favorites, song duplication, and multi-selection bulk export/share/delete across the library.
2. **Setlist & Gig Management:** Grouping and ordering songs into setlists for a gig, rehearsal, or service, with drag-and-drop reordering and a sequential "Perform Setlist" mode that binds song swiping to the setlist order.
3. **Live Stage Performance & Stage Mode:** Hands-free stage performance featuring real-time semitone key transposition, dual-mode auto-scrolling (Manual speed multiplier and Tempo duration math), full-screen Stage HUD with gesture controls, visual edge-flash/audio metronome, and interactive chord reference diagrams (6-string Guitar fretboard & Harmonium/Piano keyboard).

The app is fully self-serve: a Settings hub lets a musician define custom chord shortcuts, pick a lyric font (including dedicated Malayalam typefaces), choose a Light/Dark/System theme, and set up the metronome — backed by an in-app Help Center covering setlists, metronome, auto-scroll, full screen, selecting songs, export, and import.

Songs and setlists move in and out of the app through **ChordPro (`.chordpro`/`.cho`/`.pro`/`.txt`) file import/export and printable PDF export**, so a musician can bring songs in from other tools or band members, and share or print a set for a gig.

### Key Architecture, Technical & Security Attributes
* **100% Fully Offline:** Operates entirely on-device with zero network communication. Contains no `INTERNET` permission in app manifests, no analytics, no telemetry, and no external API dependencies.
* **Platform & Framework:** Built with the Flutter SDK targeted in this project's own build guidelines (Flutter 3.44.8 channel stable) and Dart 3.12.2 (the Dart version is the one hard-pinned in `pubspec.yaml`; no file in this repo pins an exact Flutter release number) using Material 3 design system with a signature High-Density palette (`#0052CC` blue Light primary, `#FFD54F` amber Dark primary, with `#D0BCFF` used as the floating-action-button accent) — available in System Default, Light, and Dark theme modes — Riverpod (`flutter_riverpod` 3.3.2) state management, Drift (`drift` 2.34.2) SQLite local relational database with foreign key constraints enabled (`PRAGMA foreign_keys = ON;`) and cascading deletions (`ON DELETE CASCADE`), and `go_router` (17.3.0) navigation. Two dependencies, `file_picker` and `package_info_plus`, are pinned to exact versions (no `^` range) in `pubspec.yaml`, unlike every other package — likely to avoid known regressions in those plugins.
* **Responsive Multi-Pane Layout:** Implements a 600dp responsive breakpoint shell. Mobile phones display a single-pane navigation stack, while tablets and foldable devices feature a dual-pane split view (Songbook list on left, Performance/Editor on right) for seamless multitasking.
* **Privacy & Scoped Storage:** Employs native system file pickers (`file_picker`) and share sheets (`printing`) for file import and export under platform scoped storage, eliminating requests for broad device storage permissions.
* **Complex Script & Multi-Language Typography:** Includes native HTML-to-PDF compilation (`HtmlPdfService`) utilizing a hidden platform web view and embedded SIL OFL base64 fonts (`Noto Sans Malayalam`, `Noto Serif Malayalam`, `Manjari`, `Gayathri`, and `LcMalayalamFallback`) to correctly shape complex scripts (Malayalam chillu, conjuncts, vowel signs) with selectable text output.
* **Pre-seeded Starter Content:** Ships pre-loaded with three classic songs (*"Amazing Grace"*, *"House of the Rising Sun"*, *"Jingle Bells"*) and a default setlist (*"Sunday Gig"* containing all three seed songs) for immediate zero-configuration testing upon fresh installation.
* **Per-Song State Persistence & Lifecycle Safety:** Automatically persists per-song auto-scroll speed multipliers (`scrollSpeed`) and tempo measure counts (`scrollMeasures`) in SQLite. Listens to application lifecycle states (`resumed`, `paused`) to automatically manage screen wake-lock state (`wakelock_plus`) and flush debounced scroll speed writes safely.

---

## 2. Exhaustive Feature Matrix

### 2.1 Songbook & Library Management
* **Local Relational Storage:** Persistent SQLite storage via Drift DAO managing song attributes: title, artist, original key, tempo (BPM), lyrics with inline bracket notation, favorite status, creation/modified timestamps, and per-song auto-scroll speed/measure preferences.
* **Instant Multi-Field Search:** Real-time search filtering across titles, artists, and lyric contents (`song_search_field.dart`).
* **Starred Favorites Filtering:** One-tap favorite star toggle with an "All Songs" vs. "Starred" filter row displaying live song count badges (`song_filter_row.dart`).
* **Rich Metadata Cards:** Song cards displaying title, artist, key badge (e.g., `C`, `Am`), tempo badge (e.g., `120 BPM`), favorite star toggle, and contextual menu (`song_card.dart`).
* **Pre-seeded Demonstration Library & Setlist:** Ships pre-populated with three classic songs (*"Amazing Grace"*, *"House of the Rising Sun"*, *"Jingle Bells"*) and a pre-configured setlist (*"Sunday Gig"*, description *"Acoustic live setlist"*) for immediate out-of-the-box demonstration.
* **Multi-Selection Bulk Mode:** Long-press gesture on any song card activates multi-selection mode with visual checkboxes, selection count app bar header, Select All / Deselect All controls, bulk deletion with safety confirmation, bulk ChordPro file export, and bulk sharing sheet (supporting both ChordPro `.chordpro` and PDF `.pdf` output formats).
* **Song Duplication:** One-tap song cloning feature to duplicate existing songs as new independent library entries (`song_copy.dart`).
* **Activity-Based Sorting:** Automatic library list ordering by last modified timestamp (newest changes first).
* **Songs / Setlists Tab Navigation:** The songbook home screen carries a top-level `TabBar` with two tabs — "Songs" (search, filter, and song cards) and "Setlists" — so both libraries are reachable from the same screen without an extra navigation hop (`song_list_screen.dart`).
* **Dual-Pane Tablet Split View:** On tablets (>=600dp), selecting a song in the left list updates the right performance pane instantly without pushing a new screen route. Stage Mode (see §2.4) is not offered in this pane — see §2.4 for why.
* **Context-Aware Empty States:** Dedicated visual empty state screens (`empty_songbook.dart`) delivering tailored guidance when search yields no matches, when starred filter has no entries, or when the library is completely empty.
* **Split-View Home Shell:** On tablets, `home_shell.dart` shows the song list on the left and a "Pick a song" placeholder (or the selected song's performance view) on the right, until a song is chosen.
* **Song Duplication Naming Rule:** A duplicated song is automatically named `"<Title> (Copy)"`; if the original title was blank, it falls back to `"Untitled Song (Copy)"`.

### 2.2 Lyrics & Chords Editor
* **Distraction-Free Workspace:** Clean, borderless multi-line text editor optimized for typing lyrics and embedding inline chord brackets (`song_editor_screen.dart`).
* **Inline Chord Bracket Syntax:** Standard ChordPro notation (`[Chord]word`) placing floating chord badges precisely above targeted lyric syllables.
* **Structured Song Metadata Inputs:** Text fields for Title, Artist/Band, Original Key selection dropdown, and numeric Tempo (BPM) entry (`song_meta_fields.dart`).
* **Sticky Quick Chord Inserter Bar:** Persistent toolbar anchored above the soft keyboard during editing (`chord_inserter_bar.dart`):
  * **Key-Aware Chord Suggestions (`ChordSuggestionService`):** Analyzes the selected song key and generates common scale degree chord buttons: Major keys (I, ii, iii, IV, V, vi, V7, ♭VII) and Minor keys (i, ii°, ♭III, iv, v, ♭VI, ♭VII, V7), dynamically selecting sharp vs. flat note spelling tables. If the song's key text cannot be understood (e.g. left blank or malformed), suggestions quietly fall back to the key of C major instead of failing.
  * **One-Tap Insertion:** Tapping a chord button inserts `[Chord]` directly at the current text cursor position.
  * **Custom Chord Shortcut Toolbar:** Displays user-defined custom chord notations following key-aware suggestions.
  * **Custom Chord Notation Manager:** Dialog to define, save, and manage custom chord symbols (e.g., `F#m7`, `Cmaj7`, `D/F#`), persisted in user preferences (`chord_settings_screen.dart`). Each custom chord entry is limited to 12 characters and duplicates are not stored.
* **Form Validation:** Prevents saving empty or invalid song entries.
* **Undo / Redo:** Dedicated Undo and Redo buttons in the editor app bar, wired to the lyrics text field's built-in edit history.
* **Unsaved-Changes Exit Guard:** Leaving the editor with unsaved edits (`isDirty`) asks for confirmation before discarding them; a clean, unedited draft can be closed without a prompt.
* **Save As Copy:** For an existing song, the editor's overflow menu offers "Save as copy," which saves the current in-progress edits — including ones not yet saved to the original song — as a brand-new, independent song. This is separate from the song-list "Song Duplication" feature (§2.1), which clones an already-saved song.
* **Auto-Collapsing Metadata Fields:** The Title/Artist/Key/Tempo fields fold away (animated) whenever the lyrics field gains focus, replaced by a tappable compact summary, so the lyrics area gets more room while typing.

### 2.3 Live Performance View
* **Performance Screen & State (`song_performance_screen.dart`, `performance_provider.dart`):** The screen and its Riverpod provider that host all of the live performance features described below — transposition, chord show/hide, font size, auto-scroll, song swiping, wakelock, and the overflow action menu.
* **Floating Chord Sheet Renderer:** Displays lyric sheets with distinct Material secondary-colored chord badges rendered floating above words using bold monospace typography (`chord_sheet_view.dart`).
* **Collapsible Performance Control Panel:** Floating/collapsible card containing all live performance controls (`performance_controls.dart`).
* **Transposition Engine (`chord_transposer.dart`):**
  * Semitone shift range from -11 to +11 semitones with instant visual updating (stops one short of ±12, since a full 12-semitone shift would just repeat the same key).
  * Slash chord transposition support (e.g., `C/E` transposed +2 semitones yields `D/F#`).
  * Key-aware sharp/flat spelling selection (e.g., flat spelling for `Bb`, sharp spelling for `D`).
  * Real-time computed sounding key display badge and one-tap Reset button (`transpose_sheet.dart`).
* **Show/Hide Chords Toggle:** Instant toggle to hide all chord badges, presenting clean lyrics only for vocalists.
* **Font Size & Pinch-Zoom Controls:** On-screen font size stepper controls (10sp to 32sp) accompanied by smooth multi-finger pinch-to-zoom gesture scaling.
* **Dual-Mode Hands-Free Auto-Scroll (`auto_scroll_provider.dart`, `auto_scroll_calculator.dart`):**
  * **Manual Speed Mode:** Speed multiplier slider/stepper (0.10x to 2.00x in 0.05x increments) driven by a precise frame ticker.
  * **Tempo Auto Mode:** Algorithmic calculation of total song duration and scroll velocity based on song BPM and measure count (bars, 4 beats/bar default 32 bars). Displays computed time status (e.g., *"32 bars · 1:04"*) and automatically halts ticker upon reaching the bottom of the song.
  * **Per-Song Persistence:** Scroll speed multiplier and tempo bar settings are saved to SQLite per song upon editing and automatically restored when re-opening that song.
* **Horizontal Song Swiping (PageView):** Swipe left or right across the display to transition between consecutive songs in the current songbook list or setlist sequence. Smart touch gesture handling prevents accidental swiping during vertical scrolling or multi-finger pinch zoom.
* **Automatic Screen Wakelock:** Prevents device display timeout during active performance viewing via `wakelock_plus`, with lifecycle management that restores wakelock on app resume and releases on screen exit.
* **Quick Setlist Song Navigation:** When performing inside a setlist, the top app bar presents Previous/Next song shortcuts and a Quick Setlist Sheet listing all setlist songs with current song sequence indicators and jump-to-song capabilities.
* **Top Bar Overflow Action Menu:** Instant access to Performance Controls, Chord Reference Guide, Export options, Share options, and Settings.

### 2.4 Stage Mode (Full-Screen View)
* **100% Immersive Full-Screen Display:** Expands the lyric sheet across the entire screen area, hiding top navigation app bar, bottom navigation, and system status/navigation bars (`system_ui.dart`).
* **Auto-Hiding Stage HUD:** Floating HUD overlay (`stage_hud.dart`) displaying essential performance metrics (song title, key badge, auto-scroll status) that automatically slides out of view after a few seconds of idle time.
* **Stage Gesture Layer (`stage_gesture_layer.dart`):**
  * **Single Tap:** Toggle HUD overlay visibility.
  * **Double-Tap Upper Half:** Increase scroll speed (Manual mode) or add 4 measures (Tempo mode).
  * **Double-Tap Lower Half:** Decrease scroll speed (Manual mode) or remove 4 measures (Tempo mode).
  * **Two-Finger Tap:** Toggle Play / Pause auto-scroll state.
  * **Pinch Gesture:** Dynamic font size adjustment.
* **Non-Interfering Listener Architecture:** Uses a passive `Listener` stream reader rather than a competing `GestureDetector`, allowing Stage Mode taps to function smoothly alongside vertical lyric scrolling and two-finger font pinch-zoom gestures.
* **Large-Text Visual Feedback Flash (`_ValueFlash`):** Triggers a high-contrast 44pt text HUD flash notification in the center of the screen upon executing any gesture (e.g., *"Playing"*, *"Paused"*, *"1.25x"*, *"36 bars"*), readable from a distance on stage.
* **Touch-Lock Protection:** Horizontal swiping is disabled during Stage Mode to prevent accidental song switching during live gig execution.
* **Stage Gesture Help Overlay:** Modal visual reference guide detailing all stage tap and pinch gestures (`stage_help_overlay.dart`). Shown automatically the first time a user enters Stage Mode; a saved preference remembers it has been seen so it does not reappear on later visits.
* **PopScope Back Guard:** Intercepts system back gestures to exit Stage Mode safely back to normal performance view without exiting the screen.
* **Phone / Single-Pane Only:** Stage Mode is not offered when the performance view is shown as the tablet's right-hand split-view pane (§2.1) — the full-screen button is hidden there, because going full screen would only fill the pane, not the whole device screen.

### 2.5 Setlists & Gig Management
* **Custom Setlist Creation:** Group and sequence songs for gigs, rehearsals, or services without duplicating underlying library song data (`setlist_list_screen.dart`, `setlist_editor_dialog.dart`).
* **Setlist Description Field:** Optional text field for setlist notes, venue info, or date details.
* **Pre-seeded Demonstration Setlist:** Pre-packaged with a *"Sunday Gig"* setlist (*"Acoustic live setlist"*) pre-loaded with all three seed songs in order.
* **Interactive Drag-and-Drop Reordering:** Dynamic song reordering within setlists using reorderable list drag handles (`setlist_detail_screen.dart`).
* **Multi-Song Setlist Picker Sheet:** Custom bottom sheet to search, pick, and add multiple library songs into a setlist (`setlist_song_picker_sheet.dart`).
* **Sequential Setlist Performance:** "Perform Setlist" mode binds song swiping strictly to the ordered setlist sequence, complete with header indicators (e.g., *"Sunday Service (2/5)"*).
* **Non-Destructive Operations & Relational Cascades:** Removing a song from a setlist deletes only the reference; deleting a song from the library or deleting a setlist relies on SQLite `ON DELETE CASCADE` foreign keys for clean relational cleanup.

### 2.6 Metronome System
* **Song BPM Synchronization:** Automatically derives tempo from individual song BPM metadata.
* **Visual Edge Flash Metronome:** Blinks container/screen borders on every beat for silent, high-visibility visual timekeeping on dark stage setups (`metronome_beat.dart`).
* **Audio Click Metronome:** Synthesizes audio tick sounds on every beat.
* **Independent Metronome Toggles:** Flash and Click options can be enabled independently or together in General Settings; settings persist across app restarts (`metronome_settings_screen.dart`).

### 2.7 Chord Reference Guide & Instrument Visualizers
* **Transposed Chord Inspector:** Modal dialog (`chord_reference_dialog.dart`) listing all unique chords in the current song, automatically transposed to match the active performance key.
* **Guitar Fretboard Diagrams (`guitar_chord_diagram.dart`, `chord_shape_service.dart`):** Custom-painted 6-string fretboard diagrams displaying finger placement dots, open/muted string indicators (O/X), and base fret numbers. Includes 24 hand-picked open chord shapes and dynamic movable barre chord template generation (E-shape and A-shape barre offsets) covering all 12 root semitones and chord qualities (`maj`, `m`, `7`, `m7`, `maj7`, `dim`, `aug`, etc.).
* **Harmonium / Piano Keyboard Diagrams (`harmonium_chord_diagram.dart`, `chord_shape_service.dart`):** Custom-painted piano keyboard diagrams highlighting active chord notes across pitch classes (0–11) for 20+ chord qualities (`maj7`, `maj9`, `m7b5`, `m7`, `m9`, `m6`, `madd9`, `mmaj7`, `dim7`, `dim`, `aug`, `sus2`, `sus4`, `add9`, `6`, `9`, `7`, `m`). Highlights root note in accent color and slash chord bass notes (`C/E` → `E`) in a secondary color.

### 2.8 Import & Export Workflows
* **ChordPro File Import (`chord_pro_service.dart`, `import_service.dart`):**
  * Imports `.cho`, `.pro`, `.chordpro`, and `.txt` files via system file pickers.
  * Parses ChordPro directives (`{title}`/`{t}`, `{artist}`/`{a}`, `{key}`/`{k}`, `{bpm}`/`{tempo}`, `{comment}`/`{c}`, chorus/verse formatting, `{new_song}` / `{ns}`), accepting both the long and short directive names.
  * Multi-file and multi-song batch import support.
  * Defensive parsing ensures malformed files are skipped safely without breaking application state.
* **System File Intent Handler (`file_intent_listener.dart`):** Listens for system `content://` and `file://` URIs to launch import preview directly when opening ChordPro files from external file managers, email attachments, or messaging apps.
* **Settings → Import & Export Screen (`import_export_screen.dart`):** A dedicated hub reachable from the Settings menu (labelled "Import" there, routes to `/settings/general/import`) offering "Import ChordPro file(s)" (multi-file picker straight into the import preview screen) and "Export all songs (ChordPro)" (whole library saved as a single file). This is a separate entry point from the per-song export/share menu (§2.3) and the multi-selection bulk export/share (§2.1).
* **Interactive Import Preview Screen (`import_preview_screen.dart`):**
  * Inspect parsed songs, titles, artists, keys, BPMs, and chorded lyric content before committing to database.
  * Edit metadata and choose resolution actions for duplicate title conflicts.
* **Import Duplicate Conflict Strategies (`import_settings.dart`, `import_settings_screen.dart`):**
  * **Overwrite Existing Song:** Replaces existing database entry with imported song.
  * **Rename Imported Song:** Appends timestamp to imported song title.
  * **Rename Existing Song:** Appends timestamp to existing song title.
  * **Interactive Custom Prompt:** Opens `RenameImportedSongDialog` to enter a custom song title manually.
* **ChordPro File Export:** Export individual songs (with active semitone transposition applied), selected songs (bulk mode), or entire library as `.chordpro` text files.
* **Printable PDF Export (`pdf_export_service.dart`, `html_pdf_service.dart`, `pdf_fit_action.dart`):**
  * Compiles printable lead sheets containing title, artist, key, BPM, top guitar fretboard chord diagrams, and chorded lyrics.
  * Supports single-song and multi-song PDF document generation with automatic page break wrappers (`<div class="song-container">`).
  * Respects active transpose key shift and user-selected lyric font.
  * Features smart line auto-fitting (progressively scales font down to 9pt to prevent unwanted line wrapping).
  * **Content-Fit Page Width:** The page width is no longer fixed at full A4 width. Export measures the widest lyric/chord line in the song and sets the page to that width, clamped between 300 pt and 595.28 pt (A4 width) — the height always stays fixed at A4 (841.89 pt). A song with short lines gets a narrower, taller page, which fills more of a phone screen when read on-device; a song with long lines is capped at A4 width and falls back to the font auto-fit above.
  * Employs native platform web view rendering (`HtmlPdfService`) with embedded base64 SIL OFL fonts to ensure accurate Malayalam script shaping (chillu, conjuncts, vowel signs) and selectable PDF text.
  * Modifies PDF document catalog (`pdf_fit_action.dart`) to append an `OpenAction` fit-page view hint.
  * Integrates with native system file saver and print/share dialogs (`printing`).
* **Native System Share Sheet Integration:** Share single songs or multi-selected song bundles as ChordPro (`.chordpro`) or PDF (`.pdf`) files directly to messaging, email, or cloud storage apps.
* **Safe File Naming (`safe_file_name.dart`):** Exported file names are automatically cleaned of characters that would break on some file systems, while non-English letters (such as Malayalam) are kept intact. A blank title falls back to a generic `"song"` file name.

### 2.9 Typography, Themes, & In-App Help
* **Material 3 Visual Design:** Material 3 styling with a blue Light primary (`#0052CC`) and amber Dark primary (`#FFD54F`), with `#D0BCFF` used as a floating-action-button accent in both modes.
* **Theme Modes:** System Default, Light Mode, and Dark Mode options saved in shared preferences (`theme_settings_screen.dart`).
* **Settings Hub:** A single Settings menu (`settings_screen.dart`, `general_settings_screen.dart`) groups all app-wide options together: Import, Import Settings, Metronome, Themes, Chords, Fonts, Help, and About.
* **Startup Version Check:** On launch, the app quietly compares its own version/build number against the bundled config file and logs a warning in debug builds if they do not match (`config_service.dart`). No user-facing effect in release builds.
* **Multi-Language Lyric Font Engine (`lyric_font_provider.dart`, `lyric_font.dart`):**
  * Bundles high-quality open-license (SIL OFL) Malayalam and Latin fonts:
    * System Default
    * Noto Sans Malayalam
    * Noto Serif Malayalam
    * Manjari
    * Gayathri
  * User choice is persisted globally and drives both on-screen performance text and generated PDF document rendering.
  * **Fonts Settings Screen (`font_settings_screen.dart`):** Each font option in the picker shows a live preview line rendered in English and Malayalam, so the letter shapes are visible before choosing.
* **Integrated Documentation & Help Center (`help_screen.dart`, `help_content.dart`, `help_detail_screen.dart`):**
  * In-app documentation hub covering 7 distinct topic areas: Setlists, Metronome, Auto-scroll, Full screen, Select Songs, Export, and Import.
  * Dedicated detail screens for each topic providing step-by-step operational instructions.
* **About Screen (`about_screen.dart`):** Fully data-driven from `assets/config/app_config.json` — renders app name, description, version/build, and every key in the config's `details` map (currently Author, Email, License, AI used, IDE used) as its own row, so adding a field to the config is the only change needed. The Email row is tappable and opens the device's mail app via a `mailto:` link (`url_launcher`). Also links to Flutter's built-in licenses page, which lists the bundled fonts' Open Font Licence (Noto, Manjari, Gayathri) registered at startup (`main.dart`).
