# LyricChord — App Description & Features Catalog

> **Note on scope:** This document describes features that are actually built and
> shipped in the app today. A separate document,
> [feature_analysis_and_innovations.md](feature_analysis_and_innovations.md), lists
> *proposed* ideas and enhancements that are **not implemented**. Do not treat
> anything in that other document as a current feature of the app.

## 1. App Description

**LyricChord** (`in.sreerajp.lyricchord`, Version 2.6.13+37) is a cross-platform (Android & iOS), privacy-first, **100% offline lyrics and chords notebook and live performance manager** engineered specifically for musicians, guitarists, keyboard/harmonium players, vocalists, worship leaders, and buskers.

The application addresses three core musical workflows:
1. **Creation, Editing & Library Management:** Authoring, organizing, and formatting lyric sheets with inline chord bracket syntax (`[Chord]word`), metadata (original key, BPM, artist), custom chord shortcuts, and key-aware scale degree chord suggestions — with instant search, starred favorites, song duplication, and multi-selection bulk export/share/delete across the library.
2. **Setlist & Gig Management:** Grouping and ordering songs into setlists for a gig, rehearsal, or service, with drag-and-drop reordering and a sequential "Perform Setlist" mode that binds song swiping to the setlist order.
3. **Live Stage Performance & Stage Mode:** Hands-free stage performance featuring real-time semitone key transposition, dual-mode auto-scrolling (Manual speed multiplier and Tempo duration math), full-screen Stage HUD with gesture controls, visual edge-flash/audio metronome, and interactive chord reference diagrams (6-string Guitar fretboard & Harmonium/Piano keyboard).

The app is fully self-serve: a Settings hub lets a musician define custom chord shortcuts, pick a lyric font (including dedicated Malayalam typefaces), choose a Light/Dark/System theme, and set up the metronome — backed by an in-app Help Center covering the songbook, the editor, setlists, transposition and chord shapes, auto-scroll, full screen, the metronome, the pitch pipe and shruti box, melody lines, Carnatic/Hindustani songs, selecting songs, import, export, AirQR, and appearance.

Songs and setlists move in and out of the app through **ChordPro (`.chordpro`/`.cho`/`.pro`/`.txt`) file import/export and printable PDF export**, so a musician can bring songs in from other tools or band members, and share or print a set for a gig.

### Key Architecture, Technical & Security Attributes
* **100% Fully Offline:** Operates entirely on-device with zero network communication. Contains no `INTERNET` permission in app manifests, no analytics, no telemetry, and no external API dependencies.
* **Platform & Framework:** Built with the Flutter SDK targeted in this project's own build guidelines (Flutter 3.47.6 stable, the version CI pins) and Dart 3.13.5 using Material 3 design system with a signature High-Density palette (`#0052CC` blue Light primary, `#FFD54F` amber Dark primary, with `#D0BCFF` used as the floating-action-button accent) — available in System Default, Light, and Dark theme modes — Riverpod (`flutter_riverpod` 3.3.2) state management, Drift (`drift` 2.34.2) SQLite local relational database with foreign key constraints enabled (`PRAGMA foreign_keys = ON;`) and cascading deletions (`ON DELETE CASCADE`), and `go_router` (18.x, built on `material_ui`) navigation; Material widgets come from the `material_ui` package rather than the Flutter SDK. Every dependency uses a `^` range; the earlier exact pins on `file_picker` and `package_info_plus` were removed in the Android toolchain upgrade (2026-10-23).
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
* **Resizable, Collapsible Split:** On tablets the divider between the list and the song can be dragged to resize the list (240 dp up to 60% of the width; 38% by default, as on Android). Dragging it far left, double-tapping it, or tapping its chevron button hides the list so the song fills the screen; the same button brings it back. The width and hidden state are remembered across restarts.
* **Context-Aware Empty States:** Dedicated visual empty state screens (`empty_songbook.dart`) delivering tailored guidance when search yields no matches, when starred filter has no entries, or when the library is completely empty.
* **Split-View Home Shell:** On tablets, `home_shell.dart` shows the song list on the left and a "Pick a song" placeholder (or the selected song's performance view) on the right, until a song is chosen.
* **Song Duplication Naming Rule:** A duplicated song is automatically named `"<Title> (Copy)"`; if the original title was blank, it falls back to `"Untitled Song (Copy)"`. Both words are saved in the user's language (Malayalam `"<Title> (പകർപ്പ്)"`, Sanskrit `"<Title> (प्रतिलिपिः)"`), and so is the "Untitled Song" name given to a song saved, imported or received without a title.

### 2.2 Lyrics & Chords Editor
* **Distraction-Free Workspace:** Clean, borderless multi-line text editor optimized for typing lyrics and embedding inline chord brackets (`song_editor_screen.dart`).
* **Inline Chord Bracket Syntax:** Standard ChordPro notation (`[Chord]word`) placing floating chord badges precisely above targeted lyric syllables.
* **Structured Song Metadata Inputs:** Text fields for Title, Artist/Band, Original Key selection dropdown, and numeric Tempo (BPM) entry (`song_meta_fields.dart`).
* **Notation Picker (Western / Carnatic / Hindustani):** A dropdown that records which notation the song is written in, saved per song in the `tradition` column. Choosing Western shows the **Original key** field; choosing either Indian tradition replaces it with **Raga** and **Tala** fields, because an Indian sheet is written in swaras and has no key to transpose. Switching a song back to Western clears its raga and tala, so a stale value can never make it look Indian again.
* **Tala Mismatch Warning:** Typing a tala that belongs to the other tradition (for example "Keherwa" on a Carnatic song) shows a note under the field. It is advice only and never blocks saving — the app knows a fixed list of tala names and the writer may be using one it has not heard of.
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
* **Top Bar Overflow Action Menu:** Instant access to Performance Controls, Chord Reference, Export options, Share options, and Settings.

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
* **Stage Lock (`stage_security_service.dart`):** The padlock in the Stage HUD locks the tap controls; unlocking asks for the phone's fingerprint/face or PIN through `local_auth`. It never traps the user: if the check cannot run (no screen lock, no hardware, lockout, platform error) the stage unlocks and a `SnackBar` says so; only backing out of or failing the prompt keeps it locked. Android needs `MainActivity` to be a `FlutterFragmentActivity` with AppCompat launch themes for the prompt to show.
* **Stage Quiet Mode (`stage_quiet_mode_service.dart`, Android only):** The bell in the Stage HUD silences the ringer and notification sounds; the app's own audio keeps playing. The icon shows "on" only when the phone confirmed the ringer is silent. Android 7+ first needs "Do Not Disturb access"; the `SnackBar` offers an **Open settings** button for it. The previous ringer mode is saved to disk before the change and restored when Stage Mode ends, the song is left, the app closes, or on the next start after a crash (and only if the ringer is still silent then). Hidden on iOS, which does not let apps change the ringer.
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
* **Visual Beat Flash & Bar Counter:** The metronome button flashes on every beat and shows the counted beat number (1 2 3 4) while running, for silent, high-visibility timekeeping on dark stage setups (`metronome_beat.dart`). The flash never falls below 60 ms, so it stays visible at fast tempos.
* **Synthesized Audio Click:** A short percussive click is generated in pure Dart by `PcmSynthService.generateClickWav()` and played on the device **media** channel through `MetronomeAudioService` (`metronome_audio_service.dart`), in low-latency mode with the sound pre-loaded. It replaces the earlier platform UI key-press sound, which was silenced by the phone's "Touch sounds" setting, tied to the system volume, and mute in silent mode.
* **Accented Downbeat & Time Signature:** Beat 1 of each bar plays a higher, louder accent click so the bar start is audible. Bars of 2, 3, 4 or 6 beats are selectable; the accent can be switched off for a flat tick.
* **Click Volume:** A dedicated metronome volume (0–100%), kept separate from the Pitch Drone volume so the two do not fight, applied live to the loaded players.
* **Hand-Set Tempo & Tap Tempo:** A long press on the metronome button opens `metronome_tempo_sheet.dart`: −/+ single-BPM nudges, a 30–300 BPM slider, a 4-tap averaging tap-tempo, and a "Use song tempo" reset. The override is session-only (`metronome_runtime_provider.dart`), so a per-song tweak does not follow the user to the next song. A song with no saved BPM now falls back to the last tempo used instead of leaving the button dead.
* **Drift-Free Scheduled Beat:** Each beat is armed by its own timer aimed at `start + beatIndex × 60/bpm`, always measured from the start, so a late timer shortens the next wait instead of pushing every later beat back. The click no longer waits for a screen frame (previously up to ~16 ms late, and worse while the chord sheet was drawing).
* **Independent Metronome Toggles:** Flash, Click, volume, beats-per-bar and accent can be set independently in General Settings; settings persist across app restarts (`metronome_settings_screen.dart`).
* **Test the Sound:** A Test row in Metronome settings plays one bar at 100 BPM, so audio can be verified without opening a song that has a saved tempo.
* **Safe Failure & Background Stop:** Every audio call is guarded — a failed click leaves the flash working and never interrupts a performance. The beat stops when its song page is swiped away or the app leaves the foreground, so no click plays off-screen.

### 2.7 Pitch Pipe & Drone
* **Reference Pitch Cue:** A 2-second synthesized note so a singer can find their starting pitch before the song begins (`PcmSynthService.generatePitchCueWav()`).
* **Shruti Box Drone:** A continuous synthesized drone of two notes — **Sa + Pa** (the fifth) or **Sa + Ma** (the fourth, for ragas that leave out Pa such as Malkauns and Marwa). The two notes use pure just-intonation ratios (3:2 and 4:3), the way a real drone instrument sounds, rather than equal temperament.
* **A reference, not an accompaniment:** the drone holds **one steady pair of notes** for as long as it is on. It does not follow the tune, the words or the chords. This is stated plainly in Help and in Settings, because "continuous drone" was being read as "hums the song".
* **Not a tanpura:** a tanpura has four strings plucked in a cycle and takes its shimmer from *jawari* (the string grazing a curved bridge). This synthesizes a steady reed-style drone, so it is described as a shruti box.
* **Per-Tradition Pitch Naming (`pitch_naming_service.dart`):** Sa is movable, so the drone must be anchored to a real pitch — but that anchor is named the way each tradition names it, and **no Western letter appears on an Indian sheet**. A Carnatic song shows `5 kattai`, a Hindustani song `safed 5`, a Western song plain `G`. The song's tala decides which, reusing the tala tables already in `swara_notation_service.dart`; when a song names a raga but no readable tala, the user's "Pitch naming" setting decides.
* **Opens on the Right Pitch:** a **Western** song opens on the song's own transposed key; a **Carnatic or Hindustani** song opens on the singer's saved **Sa**, because the notation is written relative to Sa and the written key is not the pitch actually sung. Picking a different pitch in the sheet lasts for that sheet only and never overwrites the saved default.
* **Reads Any Key Spelling:** flats (`Bb`, `Eb`), minor keys (`Am`, `F#m`), slash chords and lower case all resolve to the right pitch; an unreadable key falls back to the saved default rather than showing nothing.
* **Reachable From the Song Screen:** a pitch button sits next to the metronome on the ordinary song screen, as well as in the Stage Mode bar (`performance_controls.dart`, `stage_hud.dart`).
* **Safe Failure:** every audio call is wrapped (`pitch_drone_audio_service.dart`). A failure shows a `SnackBar` and logs the reason in debug builds only; the button reports "playing" **only** when sound really started, never on assumption.
* **Your Sa & Naming Settings:** Settings → General → Pitch Pipe & Drone sets the singer's Sa, the naming system, the Western default key, the interval, volume and stage font scale, with Test buttons for both sounds.

### 2.8 Melody Lines
* **The gap it fills:** a chord sheet holds the words and tells the accompanist what to play. It does not hold the **tune**. A `{melody}` line written under a lyric line adds it, so someone who has never heard the song can still learn how it goes.
* **How it is written:** `{melody} P ,  M2 | M2!G3~ ,  | R2 S` sits under the lyric line it belongs to. Beats are separated by spaces; the words and chords above are untouched. A song with no melody lines behaves exactly as before.
* **Five marks (`melody_parser_service.dart`):** `,` holds the note before it for another beat; `|` is a bar line and takes no time; `-` joins notes sharing one beat (`G3-R2`); `!` slides into a note, optionally from a named one (`M2!G3`, or a bare `!G3`); `~` shakes the note. A leading `.` drops an octave, a trailing `'` or `^` raises it.
* **One naming rule everywhere:** a bare swara name is the note from the plain **Sa Re Ga Ma Pa Dha Ni** row, so `Ma` is Ma1; a digit names the exact variant, so the raised Ma is `Ma2`/`M2`. `Ma2` and `M2` resolve identically (`swara_notation_service.dart`). **The raga never changes what a name means**, which is why there is no raga or melakarta database anywhere in the app.
* **Tapped out, not typed (`melody_keypad_sheet.dart`, `melody_entry_service.dart`):** **More options -> Melody keypad** opens a pad of all sixteen swaras plus the marks — hold, bar, share-a-beat, tie, silence, octave up/down, slide and shake. The beats draw themselves as you tap, and a running count reads "6 of 8 beats", turning green when the line fills the tala. The preview comes from a real parse of what has been entered, so what the pad shows is exactly what the player will sing. With the cursor already on a `{melody}` line, that line is loaded into the pad and replaced when you insert, so a typed line can be fixed without deleting it first. All sixteen swaras are always offered — the app keeps no raga-to-swara table, so hiding one would mean guessing.
* **Never crashes on a hand-typed line:** an unreadable token becomes a marked beat that keeps its place, so every later beat stays where it was written, and the problem is reported in plain English rather than thrown (hard rule 4).
* **Playback over the drone (`melody_player_service.dart`, `melody_audio_service.dart`):** the line is laid out in time, rendered as **one** WAV and played once — not one sound per note, which drifts and would teach uneven timing. Full speed and half speed, with looping, and a cursor that moves along the beat grid.
* **Tuned to the drone, not to a piano (`melody_player_service.dart`):** each of the twelve keys sounds at a whole-number ratio from Sa — Pa is exactly 3/2 and Ma1 exactly 4/3, which is where the shruti drone puts them. A held note locks into the drone instead of beating slowly against it, which equal temperament cannot do (its Pa is two cents flat of the drone's).
* **Both gamaka marks are sounded (`pcm_synth_service.dart`):** `!` glides into the note over its first 30%, capped at 120 ms, moving in semitones rather than hertz so the slide is even. `~` swings the pitch up from the written note and back — one key deep, two swings per beat (clamped 3–8 Hz), after a short plain onset and ramping in, so the written note stays the pitch the ear anchors on. A note under 180 ms is sung plain, and a note can slide and shake at once (`M2!G3~`). The shake is one fixed shape standing in for every kampita, not a raga-aware gamaka model — see [carnatic_notation.md](carnatic_notation.md) §8.
* **Beat grid (`melody_beat_grid.dart`):** one box per beat, grouped the way the tala groups them, scrolling sideways when a cycle is too wide for the screen. It shows the writer's own spelling, so `Ma2` stays `Ma2` and `Da2` stays `Da2` — `Da`, `Dha` and `D` are all accepted and all mean the same note.
* **Madhyama sruti:** `{sruti: madhyama}` marks a song sung with the tambura's Pa string dropped to shuddha madhyamam, which is how Yamunakalyani and its neighbours are traditionally sung. The written Sa then sounds a fourth above the singer's adhara shadja, and the melody player places it there instead of humming the tune too low.
* **Needs a real Sa:** `{tonic: 1 kattai}` gives the pitch; the tonic moves with the active transpose. Without it the grid still draws and reads correctly, but the play button stays off rather than humming a guessed pitch.
* **Stored inline:** melody and tonic lines live in the song text, so import, export and transposition carry them through unchanged with no database change. Transposing chords never touches a melody line — swaras are relative to Sa and do not move.
* **A real transcription in the sample song:** the seeded *Krishna Nee Begane Baro* carries the published Carnatic notation, not an invented tune. The krithi is sung in **madhyama sruti** — the tambura's Pa string drops to shuddha madhyamam and that note becomes the base Sa — so it is notated starting on `Sa`, not on `Pa`. One lyric line spans **four misra chapu cycles**, so each carries four `{melody}` lines; all 32 parse clean at exactly seven beats. Only the **first sangati** of each section is included. caraNam 1 ships with words and no melody, because the source gives its lyrics but no notation.
* **Off-the-beat phrases:** a beat is a row of slots, so a note can start or stop part-way through one. `,-Ri2` holds the first half of the beat and then sounds Ri; `Ri2-x` sounds Ri for half a beat and then stops. Carnatic phrases begin off the beat constantly, and this is what lets them be written where they really fall.
* **Slides are sung, not stepped:** a `!` glides into its note instead of jumping to it — over the first 30% of the note, capped at 120 ms, and moving in semitones so the glide sounds even at any pitch. `Ma2!Ga3` slides from Ma; a bare `!Ga3` scoops in from a semitone below. The shake `~` is sounded too: the pitch swings up to one semitone above the note, two swings per beat, so it follows the tempo instead of a fixed vibrato speed (kept between 3 and 8 swings a second).
* **Honest about its limits:** it shows **where the notes go**, not every way a singer shapes them. Only the two written marks, slide `!` and shake `~`, are sounded; other gamakas are not written in the line, so they are not played.
* **Reading published Carnatic notation:** the song editor can take a block of published notation and turn it into `{melody}` lines — **More options -> Paste Carnatic**. Published notation has no single standard: the same letter case means note *length* on some pages and note *octave* on others. So the importer reads it both ways, checks each against the song's tala, and shows which won and by how much ("1 of 1 cycles fit, read with case means note length"), along with anything that did not add up. Where the two tie it says so rather than picking one. It will not choose between the two madhyamams on its own — that is raga grammar — but it points out where the phrase that decides it appears, and will apply the rule if asked. Full detail in [carnatic_notation.md](carnatic_notation.md).

### 2.9 Chord Reference & Instrument Visualizers
* **Transposed Chord Inspector:** Modal dialog (`chord_reference_dialog.dart`) listing all unique chords in the current song, automatically transposed to match the active performance key.
* **Guitar Fretboard Diagrams (`guitar_chord_diagram.dart`, `chord_shape_service.dart`):** Custom-painted 6-string fretboard diagrams displaying finger placement dots, open/muted string indicators (O/X), and base fret numbers. Includes 24 hand-picked open chord shapes and dynamic movable barre chord template generation (E-shape and A-shape barre offsets) covering all 12 root semitones and chord qualities (`maj`, `m`, `7`, `m7`, `maj7`, `dim`, `aug`, etc.).
* **Harmonium / Piano Keyboard Diagrams (`harmonium_chord_diagram.dart`, `chord_shape_service.dart`):** Custom-painted piano keyboard diagrams highlighting active chord notes across pitch classes (0–11) for 20+ chord qualities (`maj7`, `maj9`, `m7b5`, `m7`, `m9`, `m6`, `madd9`, `mmaj7`, `dim7`, `dim`, `aug`, `sus2`, `sus4`, `add9`, `6`, `9`, `7`, `m`). Highlights root note in accent color and slash chord bass notes (`C/E` → `E`) in a secondary color.

### 2.10 Import & Export Workflows
* **ChordPro File Import (`chord_pro_service.dart`, `import_service.dart`):**
  * Imports `.cho`, `.pro`, `.chordpro`, and `.txt` files via system file pickers.
  * Parses ChordPro directives (`{title}`/`{t}`, `{artist}`/`{a}`, `{key}`/`{k}`, `{bpm}`/`{tempo}`, `{comment}`/`{c}`, chorus/verse formatting, `{new_song}` / `{ns}`), accepting both the long and short directive names.
  * Multi-file and multi-song batch import support.
  * Defensive parsing ensures malformed files are skipped safely without breaking application state.
  * **Size limit:** files over 5 MB (`AppConstants.maxImportFileBytes`) are refused with a `SnackBar` that names them, both from the picker and when opened from another app. Files opened from another app are read off the main thread, and a file that cannot be read or holds no songs also gets a `SnackBar` instead of silently doing nothing.
  * **Text encodings:** UTF-8 (with or without BOM) and UTF-16 LE/BE with BOM are decoded safely (`text_decoding.dart`).
  * **Binary files refused:** a photo, PDF or other binary file is reported as unreadable instead of being saved as a garbled song (`looksLikeBinary` in `text_decoding.dart`).
  * **What you preview is what is saved:** the import preview saves the parsed songs directly (`ImportService.importSongs`), not a re-parse of their text.
* **System File Intent Handler (`file_intent_listener.dart`):** Listens for system `content://` and `file://` URIs to launch import preview directly when opening ChordPro files from external file managers, email attachments, or messaging apps. The app is offered only for ChordPro and text files (by name or type), not for every file. **Shared text** (a chord sheet shared from a chat or notes app) and **several files shared at once** also open the import preview; several files are joined into one preview, under the same 5 MB limit for the total.
* **Settings → Import & Export Screen (`import_export_screen.dart`):** A dedicated hub reachable from the Settings menu (labelled "Import" there, routes to `/settings/general/import`) offering "Import ChordPro" (multi-file picker straight into the import preview screen) and "Export all songs" (whole library saved as a single file). This is a separate entry point from the per-song export/share menu (§2.3) and the multi-selection bulk export/share (§2.1).
* **Interactive Import Preview Screen (`import_preview_screen.dart`):**
  * Inspect parsed songs, titles, artists, keys, BPMs, and chorded lyric content before committing to database.
  * Edit metadata and choose resolution actions for duplicate title conflicts.
* **Import Duplicate Conflict Strategies (`import_settings.dart`, `import_settings_screen.dart`):**
  * **Overwrite Existing Song:** Replaces the existing song's content with the imported one — words, artist, key, tempo, raga, tala and tradition — keeping its star and scroll settings.
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
* **AirQR Transfer (`air_qr_service.dart`, `air_qr_transmitter_screen.dart`, `air_qr_receiver_screen.dart`):** Send songs between two phones with no network: the sender shows a looping stream of QR codes (systematic blocks plus fountain-code parity blocks, so missed frames are recovered); the receiver scans them with the camera, or from a photo, and opens the import preview. The camera is asked for only when the scanner opens. Every frame is checked before use — block count 1–4096, every index inside the stream, and a matching checksum (parity frames too) — so a bad or foreign QR code cannot count as progress.
* **Safe File Naming (`safe_file_name.dart`):** Exported file names are automatically cleaned of characters that would break on some file systems, while non-English letters (such as Malayalam) are kept intact. A blank title falls back to a generic `"song"` file name.

### 2.11 Typography, Themes, & In-App Help
* **Material 3 Visual Design:** Material 3 styling with a blue Light primary (`#0052CC`) and amber Dark primary (`#FFD54F`), with `#D0BCFF` used as a floating-action-button accent in both modes.
* **Theme Modes:** System Default, Light Mode, and Dark Mode options saved in shared preferences (`theme_settings_screen.dart`).
* **Settings Hub:** A single Settings menu (`settings_screen.dart`, `general_settings_screen.dart`) groups all app-wide options together: Import, Import Settings, Metronome, Themes, Language (System default or a chosen language, applied at once: English, Malayalam or Sanskrit), Chords, Fonts, Help, About, and **Delete all data** (after a confirm dialog it removes every song, setlist, note, setting and temporary file, then the app starts fresh with its sample songs).
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
  * In-app documentation hub covering 15 topic areas, in hub order: Your songbook, Write a song, Setlists, Transpose & chords, Auto-scroll, Full screen, Metronome, Pitch Pipe & Drone, Melody Lines, Indian songs, Select Songs, Import, Export, AirQR sharing, and Themes & fonts.
  * Topic ids are stable route segments (`/settings/help/<id>`); `test/screens/help_content_test.dart` guards uniqueness, id shape, and that no topic or section is left empty.
  * Dedicated detail screens for each topic providing step-by-step operational instructions.
* **About Screen (`about_screen.dart`):** Fully data-driven from `assets/config/app_config.json` — renders app name, description, version/build, and every key in the config's `details` map (currently Author, Email, License, AI used, IDE used) as its own row, so adding a field to the config is the only change needed. The Email row is tappable and opens the device's mail app via a `mailto:` link (`url_launcher`). Also links to Flutter's built-in licenses page, which lists the bundled fonts' Open Font Licence (Noto, Manjari, Gayathri) registered at startup (`main.dart`).
