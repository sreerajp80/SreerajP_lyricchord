# LyricChord — Comprehensive Feature Analysis & Innovation Roadmap

> **Document Purpose:** Detailed technical analysis of the `LyricChord` Flutter codebase, auditing currently implemented capabilities against non-implemented features, introducing novel offline music innovations, and cross-integrating technologies from sister Flutter applications (as documented in `L:\Android\MyFlutterApps\myapps.md`) while strictly preserving the **100% Offline, Privacy-First Architecture**.
> **Target Audience:** Lead Developer, Product Manager, Musician Testers.
> **Date:** August 2026

---

## 1. Executive Codebase & Architectural Summary

`LyricChord` is a cross-platform (Android/iOS) songbook, chord sheet manager, and hands-free live performance tool built specifically for gigging musicians, guitarists, keyboard/harmonium players, and vocalists.

### Core Stack & Design Architecture
* **UI & Rendering:** Flutter 3.44.8 / Dart 3.12.2 with Material 3 design and custom `CustomPainter` widgets for fretboards (`GuitarChordDiagram`) and harmonium keyboards (`HarmoniumChordDiagram`).
* **State Management:** Riverpod (`flutter_riverpod` ^3.3.2).
* **Database & Storage:** Drift (SQLite) for song/setlist relational storage (`drift` ^2.34.2) and `shared_preferences` for key-value user settings.
* **Navigation:** `go_router` (^17.3.0) with responsive dual-pane breakpoint layout (600dp phone/tablet shell).
* **PDF & Printing:** `pdf` (^3.12.0) and `printing` (^5.14.3) for generating and sharing songbooks (`PdfExportService`, `HtmlPdfService`, `PdfFitAction`).
* **Strict Security Constraint:** **100% Fully Offline.** No network packages, no cloud telemetry, no `INTERNET` permission in `AndroidManifest.xml`.

---

## 2. Codebase Implementation Audit Matrix

The following matrix categorizes all features into **Implemented**, **Partially Implemented**, and **Non-Implemented (Roadmap)** based on the current codebase audit (`lib/services/`, `lib/widgets/`, `lib/screens/`).

```
+---------------------------------------------------------------------------------------------------+
|                                 CODEBASE IMPLEMENTATION AUDIT                                     |
+---------------------------------------------------------------------------------------------------+
| Feature Area            | Current Codebase State                      | Audit Status               |
+-------------------------+---------------------------------------------+----------------------------+
| Transposition Engine    | `ChordTransposer` (-11 to +11 semitones)    | ✅ Implemented              |
| Auto-Scroll Engine      | `AutoScrollCalculator`, smooth ticker       | ✅ Implemented              |
| Stage HUD & Controls    | `StageHud`, `StageGestureLayer`             | ✅ Implemented              |
| Chord Diagrams          | Fretboard & Harmonium custom painters       | ✅ Implemented              |
| Basic ChordPro Parser   | `ChordProService` ({title}, {key}, {bpm})   | ✅ Implemented              |
| Basic PDF Export        | `PdfExportService`, A4 single/multi page    | ✅ Implemented              |
| Metronome Audio         | `MetronomeCalculator`, `MetronomeBeat`      | ✅ Implemented              |
| Setlist Manager         | Reordering, song picker sheet               | ✅ Implemented              |
| Pitch Pipe & Drone      | `PcmSynthService`, shruti box drone & pitch cue| ✅ Implemented           |
| 5-Tier Font Scale       | `pitchDroneProvider`, dynamic 0.85x–1.30x    | ✅ Implemented              |
| QR Songbook Sharing     | AirQR Fountain stream & camera receiver     | ✅ Implemented              |
| Stage Lock & Security   | `StageSecurityService` & `StageQuietModeService` | ✅ Implemented          |
+-------------------------+---------------------------------------------+----------------------------+
| Swara Notation View     | Western-only (`C`, `D`), missing Swara engine| Non-Implemented (Priority) |
| Acoustic Strum Control  | Manual tap scroll, missing audio mic trigger| Non-Implemented (Priority) |
| Red Night-Vision HUD    | Fixed dark theme, missing lux auto switch   | Non-Implemented (Priority) |
| Multi-Instrument Bar    | Single active diagram, missing parallel strip| Non-Implemented (Priority) |
| Smart Capo Optimizer    | Manual transposition, missing difficulty score| Non-Implemented (Priority) |
| Song Local Revision Diff| SQLite saves latest only, missing diff/history| Non-Implemented (Priority) |
| Text-to-ChordPro Smart  | Basic bracket parser, missing auto-converter | Non-Implemented (Sister App)|
| Gig Stage Checklist     | Setlist list only, missing gear checklist   | Non-Implemented (Sister App)|
| Encrypted Vault Backup  | Plain JSON export, missing encrypted `.lcpack`| Non-Implemented (Sister App)|
| Audio Backing Sync      | No audio attachment, missing sync player    | Non-Implemented (Sister App)|
| Silent Stage Haptic     | Audio metronome only, missing haptic pulses | Non-Implemented (Sister App)|
| Raga / Kāla Recommender | No time-of-day or raga mood association     | Non-Implemented (Sister App)|
+---------------------------------------------------------------------------------------------------+
```

---

## 3. Comprehensive Sister-App Cross-Integration Matrix (`myapps.md`)

By integrating production-tested components and architectures from existing Flutter applications in `L:\Android\MyFlutterApps\myapps.md`, `LyricChord` can add powerful capabilities rapidly without reinventing the wheel.

```
+----------------------------------------------------------------------------------------------------+
|                               SISTER APP CROSS-INTEGRATION MATRIX                                  |
+----------------------------------------------------------------------------------------------------+
| Source App                      | Ready Tech / Component              | LyricChord Integration     |
+---------------------------------+-------------------------------------+----------------------------+
| 1. `sreeraj_qr_reader`          | AirQR High-Density QR Encoder/Decoder| Offline QR Setlist Sharing |
| 2. `SreerajP_PDFApp`            | pdfrx & Multi-Layout PDF Engine     | Lead Sheet & Songbook PDF  |
| 3. `SreerajP_TextApp`           | Regex Text Parsing & Converter      | Text-to-ChordPro Smart Conv|
| 4. `SreerajP_CodeApp`           | `diff_match_patch` & AST Syntax     | Song Snapshot Revision Diffs|
| 5. `SreerajP_LalithaSahasranamam`| Indic Unicode Normalizer & Tone Sync| Bilingual Swara Devotional  |
| 6. `SreerajP_Devi`              | Indic Script Engine & Tone Cues     | Indian Classical Scale View|
| 7. `MantraJapaCounter`          | Haptic Pulse Ticker                 | Silent Stage Haptic Pulse  |
| 8. `sreerajp_todo`              | Reorderable Checklist & Status      | Gig Stage Gear Checklist   |
| 9. `vault-files`                | AES-256 Storage & Backup Archive    | Encrypted `.lcpack` Vault  |
| 10. `SreerajP_Journal_Vault`    | Markdown & Encrypted Entry Storage  | Musician Gig Rehearsal Diary|
| 11. `chronotune-smart-clock`    | PCM 16-bit Synth, Equal-Power Blend | Pitch Pipe & Shruti Drone  |
| 12. `Sanathana_Dharma_Clock`    | Raga Time-of-Day (Kāla) Algorithms  | Raga Kāla Song Recommender |
| 13. `SreerajP_Authenticator`    | PIN/Biometric Authentication        | Stage Lock & Musician Vault|
| 14. `sreerajp_youtube_shortcut` | Deep-link & Media File Launcher     | Audio Backing Track Sync   |
| 15. `SreerajPContactSphere`     | Offline Peer Protocols & Quiet Mode | Stage Quiet / DND Manager  |
| 16. `daily_rule_cards`          | Streak Tracker & Card Swipe Dynamics| Rehearsal Routine Tracker   |
| 17. `sms-sentry`                | Pattern Screening & Text Filtering  | ChordPro Syntax Validator  |
| 18. `LyricChord`                | Current Core Application            | Primary Base Ecosystem     |
+----------------------------------------------------------------------------------------------------+
```

### Detailed Sister-App Integration Specifications

#### 3.1 AirQR Peer-to-Peer Offline Song Sharing (`sreeraj_qr_reader`) (✅ Implemented)
* **Technology Leveraged:** Animated multi-frame high-density QR chunking & decoding algorithms adapted from `sreeraj_qr_reader`.
* **LyricChord Implementation:**
  * **Core Engine:** `AirQrService` ([lib/services/air_qr_service.dart](lib/services/air_qr_service.dart)) chunks song or setlist ChordPro payloads into 160-byte blocks with CRC32 checksums and generates systematic (`v1`) & LT Fountain (`LT1`) parity frames for loss-resilient optical transfer.
  * **State & Models:** `AirQrFrame` ([lib/models/air_qr_frame.dart](lib/models/air_qr_frame.dart)), `AirQrProgress` ([lib/models/air_qr_progress.dart](lib/models/air_qr_progress.dart)), and Riverpod `airQrProvider` ([lib/providers/air_qr_provider.dart](lib/providers/air_qr_provider.dart)).
  * **Transmitter Screen:** `AirQrTransmitterScreen` ([lib/screens/air_qr_transmitter_screen.dart](lib/screens/air_qr_transmitter_screen.dart)) renders high-density vector QR code streams via `qr_flutter` with 5–25 FPS speed slider, pause/resume controls, and frame statistics.
  * **Receiver Screen:** `AirQrReceiverScreen` ([lib/screens/air_qr_receiver_screen.dart](lib/screens/air_qr_receiver_screen.dart)) provides live camera scanning via `mobile_scanner` with realtime FPS counter, block matrix HUD, flash toggle, camera switch, photo gallery scanner (`image_picker`), and automatic navigation to `ImportPreviewScreen` upon complete payload reassembly.
  * **App Integration:** Accessible via Share menu in `SongPerformanceScreen` ([lib/screens/song_performance_screen.dart](lib/screens/song_performance_screen.dart)), app bar in `SetlistDetailScreen` ([lib/screens/setlist_detail_screen.dart](lib/screens/setlist_detail_screen.dart)), Import & Export tiles in `ImportExportScreen` ([lib/screens/import_export_screen.dart](lib/screens/import_export_screen.dart)), and quick scan action on main app bar in `SongListScreen` ([lib/screens/song_list_screen.dart](lib/screens/song_list_screen.dart)).

#### 3.2 Professional Multi-Layout Lead Sheet PDF Engine (`SreerajP_PDFApp`)
* **Technology Leveraged:** Vector PDF compilation, multi-layout generation, and page processing from [SreerajP_PDFApp](file:///L:/Android/SreerajP_PDFApp/docs/features.md).
* **LyricChord Integration:**
  * **Lead Sheet Layout:** Full lyrics, chords above words, and top fretboard diagrams.
  * **Vocalist Layout:** Large, clean lyric-only printouts with section headers.
  * **Rhythm Section Grid:** Compact progression blocks for bassists and drummers.
  * **Setlist Songbook Compiler:** Merges an entire setlist into a single indexed PDF with TOC, page numbers, and custom band branding.

#### 3.3 Text-to-ChordPro Converter & Syntax Validator (`SreerajP_TextApp` & `sms-sentry`)
* **Technology Leveraged:** Regex-based line-above-lyric parser from [SreerajP_TextApp](file:///L:/Android/SreerajP_TextApp/docs/features.md) and pattern validation from [sms-sentry](file:///L:/Android/sms-sentry/docs/features.md).
* **LyricChord Integration:**
  * **Smart Conversion:** Automatically converts plain text files with chords sitting on lines *above* lyrics into standard inline `[Chord]` ChordPro format.
  * **ChordPro Validator:** Identifies unclosed brackets `{title: ...` or invalid directive tags prior to saving.

#### 3.4 Song Revision Visual Diff Engine (`SreerajP_CodeApp`)
* **Technology Leveraged:** Line-by-line inline diff visualizer (`diff_match_patch`) and syntax highlighting engine from [SreerajP_CodeApp](file:///L:/Android/SreerajP_CodeApp/docs/features.md).
* **LyricChord Integration:**
  * **Side-by-Side Diff:** Displays visual comparisons between song revisions (e.g., "Original Key C" vs "Gig Rehearsal Key G with Capo 2").

#### 3.5 Devotional Swara Engine & Raga Kāla Recommender (`SreerajP_LalithaSahasranamam`, `SreerajP_Devi` & `Sanathana_Dharma_Clock`)
* **Technology Leveraged:** Unicode NFC normalization and tone cues from [SreerajP_LalithaSahasranamam](file:///L:/Android/SreerajP_LalithaSahasranamam/docs/features.md) / [SreerajP_Devi](file:///L:/Android/SreerajP_Devi/docs/features.md), combined with time-of-day calculation algorithms from [Sanathana_Dharma_Clock](file:///L:/Android/Sanathana_Dharma_Clock/docs/features.md).
* **LyricChord Integration:**
  * **Bilingual Swara View:** Renders lyrics in English, Malayalam, or Devanagari script paired with Swara chord notation (*S R G M P D N*).
  * **Raga Kāla Recommender:** Suggests devotional or classical songs appropriate for the current time of day (e.g., Morning *Bhairavi*, Evening *Yaman*).

#### 3.6 Procedural Pitch Pipe & Shruti Box Drone (`chronotune-smart-clock`) **[✅ Implemented]**
* **Technology Leveraged:** PCM 16-bit stereo synthesis, multi-harmonic additive synthesis with ADSR envelope, and equal-power audio blending from [chronotune-smart-clock](file:///L:/Android/chronotune-smart-clock/docs/features.md).
* **LyricChord Integration:**
  * **Shruti Box Generator:** Real-time synthesized continuous shruti box drone (Sa + Pa / Sa + Ma) in any of the twelve pitches, for Indian classical or acoustic practice (`PcmSynthService`). The two notes use pure just-intonation ratios (3:2 and 4:3), as a real drone instrument sounds — not equal temperament. It holds one steady pair of notes and **does not follow the melody**. Not a tanpura: a tanpura has four strings plucked in a cycle and its character comes from *jawari*, which this does not model.
  * **Indian pitch naming:** because Sa is movable, the drone must be anchored to a real pitch. That anchor is named the way each tradition names it — `5 kattai` for Carnatic, `safed 5` for Hindustani, plain `G` for Western, with no Western letter shown on an Indian sheet. The song's tala decides which (`PitchNamingService`), and the singer's own Sa is set in Settings.
  * **Pitch Pipe Cuer:** 2-second synthesized pure tone cue for vocalists before starting a song.
  * **5-Tier Dynamic Font Scale:** Dynamic text scaling (0.85x to 1.30x) for screen readability on stage (`pitchDroneProvider`).
  * **Help Documentation:** Added under `Settings -> Help -> Pitch Pipe & Shruti Drone` (`help_content.dart`).

#### 3.7 Silent Stage Haptic Metronome (`MantraJapaCounter`)
* **Technology Leveraged:** High-precision haptic feedback ticker from [MantraJapaCounter](file:///L:/Android/MantraJapaCounter/docs/features.md).
* **LyricChord Integration:**
  * **Haptic Pulse Metronome:** Sends precise vibration pulses on Beat 1 and sub-beats to keep silent stage tempo without audible click tracks.

#### 3.8 Gig Stage Gear Checklist (`sreerajp_todo`)
* **Technology Leveraged:** Reorderable item list and state management from [sreerajp_todo](file:///L:/Android/sreerajp_todo/docs/features.md).
* **LyricChord Integration:**
  * **Gig Checklist Sheet:** Customizable gear checklist attached to setlists (cables, tuning check, battery status, capo, spare strings).

#### 3.9 Encrypted `.lcpack` Vault & Rehearsal Notes (`vault-files` & `SreerajP_Journal_Vault`)
* **Technology Leveraged:** Local AES-256 archive encryption from [vault-files](file:///L:/Android/vault-files/docs/features.md) and encrypted entry storage from [SreerajP_Journal_Vault](file:///L:/Android/SreerajP_Journal_Vault/docs/features.md).
* **LyricChord Integration:**
  * **Encrypted Songbook Backup:** Export full song databases to password-protected `.lcpack` archives.
  * **Musician Rehearsal Diary:** Attach private Markdown gig notes, amplifier settings, or vocal warmup advice to individual songs.

#### 3.10 Stage Security & Quiet Performance Mode (`SreerajP_Authenticator` & `SreerajPContactSphere`) (✅ Implemented)
* **Technology Leveraged:** Local PIN/Biometric authentication from [`SreerajP_Authenticator`](https://github.com/sreerajp80/sreerajp_authenticator) and quiet mode triggers from `SreerajPContactSphere`.
* **LyricChord Implementation:**
  * **Stage Lock Mode:** Prevents accidental screen touches, song editing, pitch drone changes, or leaving the performance view while on stage via local biometric/PIN authentication (`StageSecurityService` via `local_auth` and `StageGestureLayer` overlay).
  * **Stage Quiet Mode:** Automatically silences incoming calls and notification alert streams via Android `AudioManager` MethodChannel while performance mode is active (`StageQuietModeService`), preserving media audio streams for pitch drone synths and metronome playback.

#### 3.11 Local Audio Backing Track Sync (`sreerajp_youtube_shortcut`)
* **Technology Leveraged:** Deep-link URI persistence and local media file launching from [sreerajp_youtube_shortcut](file:///L:/Android/sreerajp_youtube_shortcut/docs/features.md).
* **LyricChord Integration:**
  * **Backing Track Sync:** Attach local MP3/WAV backing tracks to song sheets with integrated play/pause, looping, and variable playback speed controls.

#### 3.12 Rehearsal Routine Tracker (`daily_rule_cards`)
* **Technology Leveraged:** Habit tracking metrics and card swipe dynamics from [daily_rule_cards](file:///L:/Android/daily_rule_cards/docs/features.md).
* **LyricChord Integration:**
  * **Rehearsal Streak Tracker:** Keeps track of daily song practice sessions and setlist rehearsal completions.

---

## 4. Novel Features — Industry Firsts for Mobile Chord Apps

These features do not exist in mainstream market competitors (such as Ultimate Guitar, SongBook Pro, OnSong, or Chordify) while staying strictly within the 100% offline architectural mandate.

```
+-----------------------------------------------------------------------------------+
|                        NOVEL OFFLINE INNOVATION MATRIX                           |
+-----------------------------------------------------------------------------------+
| 1. Swara / Raga Notation Engine   --> Dual Western (C, D) & Indian (Sa, Re) View  |
| 2. Acoustic Strum Page Turner    --> Low-Latency Offline Mic Pattern Recognition   |
| 3. Stage HUD & Red Night Vision   --> Ambient Lux Sensor + Zero-Distraction View   |
| 4. Synchronized Multi-Instrument  --> Parallel Guitar + Harmonium + Ukulele Visual |
| 5. Offline Pitch Pipe & Drone     --> Built-in PCM Shruti Box Generator            |
| 6. Smart Capo Optimizer           --> Algorithmic Fingering Difficulty Minimizer  |
| 7. Song Snapshot Revisions        --> Local Git-like Version Control History      |
+-----------------------------------------------------------------------------------+
```

### 4.1 Swara & Indian Classical / Devotional Notation Engine
> **Why it's unique:** Existing chord apps are 100% Western-centric (`C`, `Dm`, `G7`, `F#m`). Millions of Indian classical, devotional, bhajan, harmonium, and keyboard artists read music using **Swaras** (*Sa, Re, Ga, Ma, Pa, Dha, Ni* / *S, R, G, m, P, D, N*).

* **Feature Mechanics:**
  * **Dynamic Key-Root Mapping:** Assign a key root as *Sa* (e.g., `Key C#` = `Sa`).
  * **One-Tap Toggle:** Instantly switch performance view chords from Western (`C# - F# - G#`) to Swara (`S - M - P`) or dual overlay (`C# (S) - F# (M)`).
  * **Harmonium Swara Highlighting:** Harmonium reference diagrams dynamically show Swara labels directly on key surfaces.
  * **Bilingual Transposition:** Transposing by +1 semitone seamlessly shifts both Western chord names and scale Swara degrees.

### 4.2 Offline Acoustic Strum & Pitch-Triggered Hands-Free Scroll
> **Why it's unique:** Hands-free scrolling in existing apps requires buying expensive $100+ Bluetooth foot pedals or relying on fixed timers that fall out of sync when a musician pauses or improvises.

* **Feature Mechanics:**
  * **Local Audio Analysis:** Uses Flutter low-latency offline microphone audio buffers without saving or transmitting audio data.
  * **Strum Gesture / Pitch Cue:** Detects a specific double-strum accent, a low-string E tap, or a designated whistle tone to perform:
    * **Single Trigger:** Pause / Resume auto-scroll.
    * **Double Trigger:** Jump to Next Section (Chorus / Bridge).
  * **Zero Hardware Cost:** Works entirely on the phone/tablet mic during live rehearsals or acoustic performances.

### 4.3 Stage HUD & Ambient Red/OLED Night-Vision Adaptor
> **Why it's unique:** Standard dark modes still produce glare on dark stages, and standard app interfaces contain tiny buttons easily mis-tapped under live stage lights.

* **Feature Mechanics:**
  * **Ambient Lux Auto-Adaptor:** Monitors device ambient light sensors. In pitch-black stage environments, automatically switches the UI to an ultra-low-glare **Monochrome OLED Black & Red / Amber Filter** (preserving dark adaptation for human eyes).
  * **Stage HUD Layout:** Hides all non-essential UI elements, maximizing font size, showing giant Next/Prev song tap zones, and displaying large BPM/Key indicators visible from 6 feet away.
  * **Touch-Lock Mode:** Prevents accidental screen touches while auto-scrolling during a performance. Unlocks via long-press or volume rocker keys.

### 4.4 Synchronized Multi-Instrument Visualizer Bar
> **Why it's unique:** Current apps require opening a separate dialog or switching instrument tabs one-by-one to see guitar frets vs. keyboard keys.

* **Feature Mechanics:**
  * **Inline Instrument Strip:** A sticky top/bottom bar in performance view displaying real-time synchronized mini-visualizers for the active chord:
    * **Guitar:** 6-string fretboard with finger placement numbers.
    * **Harmonium / Piano:** Highlighted key diagram with octave indicators.
    * **Ukulele / Mandolin:** 4-string fretboard mapping.
  * **Band Collaboration Mode:** Essential for multi-instrumentalists or duet performers reviewing chord shapes together on a single screen.

### 4.5 Offline Pitch Pipe Cuer & PCM Shruti Drone Generator
> **Why it's unique:** Vocalists and guitarists frequently start songs out of pitch when moving between songs in a setlist.

* **Feature Mechanics:**
  * **Shruti Box Drone Synthesizer:** Synthesizes continuous PCM stereo shruti box drone audio (Sa + Pa / Sa + Ma) with multi-harmonic overtone warmth for practice and vocal alignment. It is a reference, not an accompaniment — the drone never changes with the tune.
  * **Built-in Offline Pitch Cuer:** Synthesizes a clean 2-second reference pitch note when tapping a "Pitch Pipe" icon or upon opening a song in a setlist.
  * **Setlist Key Transition Alert:** Displays visual cues when consecutive songs in a setlist have jarring key jumps (e.g., `Song 1: G Major` → `Song 2: Eb Major`: warning badge reading *"Key Shift +8 semitones / Recommend Capo 1 (D shape)"*).

### 4.6 Smart Capo Recommendation & Fingering Optimizer
> **Why it's unique:** Transposing a song to fit a singer's voice often results in difficult, uncomfortable chords (e.g., `F#m`, `C#m`, `G#7`).

* **Feature Mechanics:**
  * **Fingering Difficulty Score Engine:** Evaluates all chords in a song for barre chord density and finger stretch complexity.
  * **Capo Advisor Badge:** Recommends optimal capo positions to minimize hard chords. (Example: *"Playing in key of F#? Place Capo on Fret 2 and strum easy open E, A, B7 shapes!"*).
  * **One-Tap Capo Apply:** Transposes chord notation visually for capo playback while preserving the actual sound key badge.

### 4.7 Song Snapshot Local Revisions & Draft History
> **Why it's unique:** Musicians constantly tweak lyrics, transpose keys for different vocalists, or shorten verses during rehearsals, accidentally overwriting original versions.

* **Feature Mechanics:**
  * **Local Revision Snapshots:** Stored directly in Drift SQLite database upon saving.
  * **Version Comparison:** View side-by-side diffs between "Original", "Acoustic Rehearsal", and "Band Live Edit".
  * **One-Tap Rollback:** Revert song key, chords, and lyric changes instantly without network or cloud backups.

---

## 5. Prioritized Feature Implementation Matrix & Phasing

### 5.1 Updated Master Implementation Matrix

```
+-------------------------------------------------------------------------------------------------------------------+
| Category            | Feature Name                 | Source / Leverage  | Est. Effort | Priority | Audit Status     |
+---------------------+------------------------------+--------------------+-------------+----------+------------------+
| Sister Integration  | QR Peer-to-Peer Song Share   | `sreeraj_qr_reader`| Low         | P1       | ✅ Implemented   |
| Sister Integration  | Pitch Pipe & Shruti Drone    | `chronotune`       | Low         | P1       | ✅ Implemented   |
| Sister Integration  | Stage Lock & Security        | `Authenticator`    | Low         | P1       | ✅ Implemented   |
| Novel Innovation    | Swara / Raga Notation View   | Devotional Engine  | Medium      | P1       | ⏳ Planned (P1)  |
| Sister Integration  | Text-to-ChordPro Converter   | `SreerajP_TextApp` | Low         | P1       | ⏳ Planned (P1)  |
| Novel Innovation    | Smart Capo Optimizer         | Internal Algorithm | Low         | P1       | ⏳ Planned (P1)  |
| Novel Innovation    | Stage HUD & OLED Red Mode    | Internal Sensor    | Medium      | P2       | ⏳ Planned (P2)  |
| Sister Integration  | Lead Sheet & Songbook PDF    | `SreerajP_PDFApp`  | Medium      | P2       | ⏳ Planned (P2)  |
| Sister Integration  | Silent Stage Haptic Metronome| `MantraJapaCounter`| Low         | P2       | ⏳ Planned (P2)  |
| Sister Integration  | Gig Stage Gear Checklist     | `sreerajp_todo`    | Low         | P2       | ⏳ Planned (P2)  |
| Sister Integration  | Audio Backing Track Sync     | `youtube_shortcut` | Medium      | P2       | ⏳ Planned (P2)  |
| Novel Innovation    | Acoustic Strum Page Turner   | Offline Mic Buffer | High        | P3       | ⏳ Planned (P3)  |
| Sister Integration  | Song Version Diff History    | `SreerajP_CodeApp` | Medium      | P3       | ⏳ Planned (P3)  |
| Sister Integration  | Encrypted Database Vault     | `vault-files`      | Medium      | P3       | ⏳ Planned (P3)  |
| Sister Integration  | Raga Kāla Recommender        | `Sanathana_Dharma` | Medium      | P3       | ⏳ Planned (P3)  |
| Sister Integration  | Rehearsal Routine Tracker    | `daily_rule_cards` | Low         | P3       | ⏳ Planned (P3)  |
+-------------------------------------------------------------------------------------------------------------------+
```

---

### 5.2 Phased Roadmap & Release Strategy

#### Milestone 0: Core Foundation & Sister Integrations (Completed ✅)
* **AirQR P2P Sharing:** Fountain code streaming transmitter and live camera scanner (`AirQrService`, `AirQrTransmitterScreen`, `AirQrReceiverScreen`).
* **Procedural Pitch Pipe & Drone:** Synthesized PCM 16-bit shruti box drone & pure vocal pitch cues, named per tradition (`PcmSynthService`, `PitchDroneAudioService`, `PitchNamingService`, `pitchDroneProvider`).
* **Stage Lock & Quiet Performance Mode:** Biometric/PIN screen lock overlay & DND notification silencing (`StageSecurityService`, `StageQuietModeService`).
* **Core Songbook & Engine:** Transposition, smooth auto-scroll, chord reference diagrams (Guitar & Harmonium), ChordPro parser, and PDF printing.

#### Phase 1: Notation & Smart Assistance (Next Immediate Release - P1)
1. **Swara / Raga Notation View:** Dual Western/Swara toggle, key-root mapping, harmonium Swara visualization.
2. **Text-to-ChordPro Smart Converter:** Automatic conversion of line-above-lyric plain text files into bracketed ChordPro syntax.
3. **Smart Capo Optimizer:** Algorithmic barre chord difficulty calculation and optimal capo position recommendations.

#### Phase 2: Live Stage Performance Extensions (P2)
1. **Stage HUD & OLED Red Night-Vision:** Light sensor auto-trigger for high-contrast red/black dark adaptation and enlarged HUD touch zones.
2. **Multi-Layout PDF Songbook Compiler:** Vocalist, Rhythm Grid, and Lead Sheet layouts compiled into indexed setlist PDFs.
3. **Silent Stage Haptic Metronome:** Tactile vibration pulses for quiet stage tempo keeping.
4. **Gig Gear Checklist & Audio Backing Track Sync:** Reorderable setlist gear checklist and local audio track playback integration.

#### Phase 3: Advanced Innovations & Security Vault (P3)
1. **Acoustic Strum Page Turner:** Low-latency offline microphone audio buffer processing for hands-free scroll triggering.
2. **Song Local Revision Diffs:** Version control for song edits with visual side-by-side inline diffs.
3. **Encrypted `.lcpack` Vault:** AES-256 encrypted songbook backup archives and rehearsal diary notes.
4. **Raga Kāla Recommender & Routine Tracker:** Time-of-day raga suggestions and daily practice metrics.

---

## 6. Architectural Compliance & Security Verification

All proposed innovations strictly comply with the core rules established in [`CLAUDE.md`](../CLAUDE.md):

1. **Zero Internet Requirement:** All pitch generation, microphone audio analysis, PDF creation, QR generation/scanning, and transposition run 100% locally on device hardware. No network permissions (`INTERNET`) required or added.
2. **Database Integrity:** Local version snapshots, custom chord voicings, and Swara mappings are stored cleanly via Drift (SQLite) migrations without breaking existing schemas.
3. **Performance Budget:** Audio processing and custom painting execute strictly within 60fps frame budgets without blocking the main UI thread.
