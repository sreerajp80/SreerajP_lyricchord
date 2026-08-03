# LyricChord — Comprehensive Feature Analysis & Innovation Roadmap

> **Document Purpose:** Detailed analysis of the `LyricChord` Flutter codebase, proposing revolutionary features absent in existing Android lyrics/chords apps, along with strategic enhancements for existing capabilities while strictly preserving the **100% Offline, Privacy-First Architecture**.
> **Target Audience:** Lead Developer, Product Manager, Musician Testers.
> **Date:** July 2026

---

## 1. Executive Codebase & Architectural Summary

`LyricChord` is a cross-platform (Android/iOS) songbook, chord sheet manager, and hands-free live performance tool built specifically for gigging musicians, guitarists, keyboard/harmonium players, and vocalists.

### Core Stack & Design Architecture
* **UI & Rendering:** Flutter 3.41.9 / Dart 3.11.5 with Material 3 design and custom `CustomPainter` widgets for fretboards and harmonium keyboards.
* **State Management:** Riverpod (`flutter_riverpod` ^3.3.2).
* **Database & Storage:** Drift (SQLite) for song/setlist relational storage (`drift` ^2.34.2) and `shared_preferences` for key-value user settings.
* **Navigation:** `go_router` (^17.3.0) with responsive dual-pane breakpoint layout (600dp phone/tablet shell).
* **PDF & Printing:** `pdf` (^3.12.0) and `printing` (^5.14.3) for generating and sharing songbooks.
* **Strict Security Constraint:** **100% Fully Offline.** No network packages, no cloud telemetry, no `INTERNET` permission in `AndroidManifest.xml`.

---

## 2. Novel Features — Industry Firsts for Mobile Chord Apps

These features do not exist in mainstream market competitors (such as Ultimate Guitar, SongBook Pro, OnSong, or Chordify) while staying strictly within the 100% offline architectural mandate.

```
+-----------------------------------------------------------------------------------+
|                        NOVEL OFFLINE INNOVATION MATRIX                           |
+-----------------------------------------------------------------------------------+
| 1. Swara / Raga Notation Engine   --> Dual Western (C, D) & Indian (Sa, Re) View  |
| 2. Acoustic Strum Page Turner    --> Low-Latency Offline Mic Pattern Recognition   |
| 3. Stage HUD & Red Night Vision   --> Ambient Lux Sensor + Zero-Distraction View   |
| 4. Synchronized Multi-Instrument  --> Parallel Guitar + Harmonium + Ukulele Visual |
| 5. Offline Pitch Pipe & Key Shift --> Built-in Audio Tone Cuer & Segue Advisor    |
| 6. Smart Capo Optimizer           --> Algorithmic Fingering Difficulty Minimizer  |
| 7. Song Snapshot Revisions        --> Local Git-like Version Control History      |
+-----------------------------------------------------------------------------------+
```

---

### 2.1 Swara & Indian Classical / Devotional Notation Engine
> **Why it's unique:** Existing chord apps are 100% Western-centric (`C`, `Dm`, `G7`, `F#m`). Millions of Indian classical, devotional, bhajan, harmonium, and keyboard artists read music using **Swaras** (*Sa, Re, Ga, Ma, Pa, Dha, Ni* / *S, R, G, m, P, D, N*).

* **Feature Mechanics:**
  * **Dynamic Key-Root Mapping:** Assign a key root as *Sa* (e.g., `Key C#` = `Sa`).
  * **One-Tap Toggle:** Instantly switch performance view chords from Western (`C# - F# - G#`) to Swara (`S - M - P`) or dual overlay (`C# (S) - F# (M)`).
  * **Harmonium Swara Highlighting:** Harmonium reference diagrams dynamically show Swara labels directly on key surfaces.
  * **Bilingual Transposition:** Transposing by +1 semitone seamlessly shifts both Western chord names and scale Swara degrees.

---

### 2.2 Offline Acoustic Strum & Pitch-Triggered Hands-Free Scroll
> **Why it's unique:** Hands-free scrolling in existing apps requires buying expensive $100+ Bluetooth foot pedals or relying on fixed timers that fall out of sync when a musician pauses or improvises.

* **Feature Mechanics:**
  * **Local Audio Analysis:** Uses Flutter low-latency offline microphone audio buffers without saving or transmitting audio data.
  * **Strum Gesture / Pitch Cue:** Detects a specific double-strum accent, a low-string E tap, or a designated whistle tone to perform:
    * **Single Trigger:** Pause / Resume auto-scroll.
    * **Double Trigger:** Jump to Next Section (Chorus / Bridge).
  * **Zero Hardware Cost:** Works entirely on the phone/tablet mic during live rehearsals or acoustic performances.

---

### 2.3 Stage HUD & Ambient Red/OLED Night-Vision Adaptor
> **Why it's unique:** Standard dark modes still produce glare on dark stages, and standard app interfaces contain tiny buttons easily mis-tapped under live stage lights.

* **Feature Mechanics:**
  * **Ambient Lux Auto-Adaptor:** Monitors device ambient light sensors. In pitch-black stage environments, automatically switches the UI to an ultra-low-glare **Monochrome OLED Black & Red / Amber Filter** (preserving dark adaptation for human eyes).
  * **Stage HUD Layout:** Hides all non-essential UI elements, maximizing font size, showing giant Next/Prev song tap zones, and displaying large BPM/Key indicators visible from 6 feet away.
  * **Touch-Lock Mode:** Prevents accidental screen touches while auto-scrolling during a performance. Unlocks via long-press or volume rocker keys.

---

### 2.4 Synchronized Multi-Instrument Visualizer Bar
> **Why it's unique:** Current apps require opening a separate dialog or switching instrument tabs one-by-one to see guitar frets vs. keyboard keys.

* **Feature Mechanics:**
  * **Inline Instrument Strip:** A sticky top/bottom bar in performance view displaying real-time synchronized mini-visualizers for the active chord:
    * **Guitar:** 6-string fretboard with finger placement numbers.
    * **Harmonium / Piano:** Highlighted key diagram with octave indicators.
    * **Ukulele / Mandolin:** 4-string fretboard mapping.
  * **Band Collaboration Mode:** Essential for multi-instrumentalists or duet performers reviewing chord shapes together on a single screen.

---

### 2.5 Offline Pitch Pipe Cuer & Key Transition Advisor
> **Why it's unique:** Vocalists and guitarists frequently start songs out of pitch when moving between songs in a setlist.

* **Feature Mechanics:**
  * **Built-in Offline Audio Tone Generator:** Synthesizes a clean 2-second reference pitch (root note or tonic chord triad) when tapping a "Pitch Pipe" icon or upon opening a song in a setlist.
  * **Setlist Key Transition Alert:** Displays visual cues when consecutive songs in a setlist have jarring key jumps (e.g., `Song 1: G Major` → `Song 2: Eb Major`: warning badge reading *"Key Shift +8 semitones / Recommend Capo 1 (D shape)"*).

---

### 2.6 Smart Capo Recommendation & Fingering Optimizer
> **Why it's unique:** Transposing a song to fit a singer's voice often results in difficult, uncomfortable chords (e.g., `F#m`, `C#m`, `G#7`).

* **Feature Mechanics:**
  * **Fingering Difficulty Score Engine:** Evaluates all chords in a song for barre chord density and finger stretch complexity.
  * **Capo Advisor Badge:** Recommends optimal capo positions to minimize hard chords. (Example: *"Playing in key of F#? Place Capo on Fret 2 and strum easy open E, A, B7 shapes!"*).
  * **One-Tap Capo Apply:** Transposes chord notation visually for capo playback while preserving the actual sound key badge.

---

### 2.7 Song Snapshot Local Revisions & Draft History
> **Why it's unique:** Musicians constantly tweak lyrics, transpose keys for different vocalists, or shorten verses during rehearsals, accidentally overwriting original versions.

* **Feature Mechanics:**
  * **Local Revision Snapshots:** Stored directly in Drift SQLite database upon saving.
  * **Version Comparison:** View side-by-side diffs between "Original", "Acoustic Rehearsal", and "Band Live Edit".
  * **One-Tap Rollback:** Revert song key, chords, and lyric changes instantly without network or cloud backups.

---

## 3. High-Impact Enhancements to Existing Features

```
+-----------------------------------------------------------------------------------+
|                        FEATURE ENHANCEMENT ROADMAP                               |
+-----------------------------------------------------------------------------------+
| Existing Feature         | Current State                 | Proposed Enhancement   |
+--------------------------+-------------------------------+------------------------+
| Transposition Engine     | Semitone Shift (-11 to +11)   | Custom Scale & Capo-   |
|                          |                               | Aware Dual Display     |
| Auto-Scroll              | Fixed Speed / Tempo Auto Math | Visual Flash Beat Sync |
|                          |                               | & Section Landmarks    |
| ChordPro Import/Export   | Basic Directive Parser        | Full Spec + Auto Text  |
|                          | ({title}, {key}, {bpm})       | to ChordPro Converter  |
| Chord Visualizer         | Curated Open + Barre Fallback | Custom Fret Tap Editor |
|                          |                               | & Alternate Tunings    |
| PDF Export               | Standard Single/Multi A4 PDF  | Multi-Layout Band Lead |
|                          |                               | Sheets & Setlist Book  |
| Setlists                 | Basic List & Reordering       | Gig Time Estimator     |
|                          |                               | & Key Map Statistics   |
+--------------------------+-------------------------------+------------------------+
```

---

### 3.1 Transposition & Key Engine Enhancements
* **Current Implementation:** `ChordTransposer` shifts semitones with sharp/flat preference.
* **Proposed Enhancements:**
  1. **Slash Chord & Root-Bass Disassociation:** Smart handling of complex jazz/prog slash chords (`C/B`, `D/F#`, `Am/G`).
  2. **Capo Overlay Mode:** Displays transposed play chords alongside original key sounding chords (e.g., `G (Sounding: Bb)`).
  3. **Relative Solfege View:** Option to view chords in Roman Numerals (`I - V - vi - IV`) for music theory study and jam sessions.

---

### 3.2 Performance View & Auto-Scroll Upgrades
* **Current Implementation:** `AutoScrollCalculator` computes duration; smooth `Ticker` auto-scrolls view.
* **Proposed Enhancements:**
  1. **Visual Edge Flash Metronome:** Pulsing screen border edge on Beat 1 of each measure during playback for silent tempo synchronization on stage.
  2. **Section Jump Anchors:** Sticky quick-jump buttons (`Verse 1`, `Chorus`, `Bridge`, `Outro`) allowing one-tap scrolling directly to key song sections.
  3. **Vowel-Anchored Chord Alignment:** Refines chord badge placement directly over targeted syllables using rich text line layout measurements.

---

### 3.3 ChordPro & Smart Import Parser Expansion
* **Current Implementation:** `ChordProService` parses basic song tags (`{title}`, `{artist}`, `{key}`, `{bpm}`).
* **Proposed Enhancements:**
  1. **Extended Directive Support:** Parse `{capo}`, `{tempo}`, `{time}`, `{comment}`, `{start_of_chorus}`, `{end_of_chorus}`, `{tab}`.
  2. **Text-to-ChordPro Smart Converter:** Automatically converts standard text files with chords sitting on lines *above* lyrics into inline `[Chord]` ChordPro format.
  3. **Batch Import & Zip Extraction:** Pick multiple files or a zip archive to import an entire song folder in seconds.

---

### 3.4 Interactive Chord Diagram & Custom Fingering Visualizer
* **Current Implementation:** `ChordShapeService` uses hardcoded fingerings and basic barre formula; rendered via `CustomPainter`.
* **Proposed Enhancements:**
  1. **Interactive Fretboard Editor:** Tap frets and select muted/open strings in the Chord Reference dialog to save custom chord voicings directly to the database.
  2. **Alternate Tunings Support:** Fretboard visualizer support for Drop D, DADGAD, Open G, Half-Step Down, and custom harmonium scale mappings.
  3. **Left-Handed Fretboard Toggle:** Instantly mirror guitar fretboards for left-handed musicians.

---

### 3.5 Professional PDF Export & Print Sheet Customizer
* **Current Implementation:** `PdfExportService` produces a fixed A4 sheet with chord diagrams and lyrics.
* **Proposed Enhancements:**
  1. **Print Layout Presets:**
     * **Lead Sheet:** Full lyrics, chords, and top fretboard diagrams.
     * **Vocalist Sheet:** Clean large lyrics only (no chords or diagrams).
     * **Chord Chart Grid:** Compact chord progression blocks only (for rhythm section).
  2. **Consolidated Setlist Book Export:** Merge an entire setlist into a single multi-page indexed PDF with table of contents and page numbers.

---

### 3.6 Advanced Setlist & Gig Management
* **Current Implementation:** `SetlistDetailScreen` stores and reorders songs.
* **Proposed Enhancements:**
  1. **Gig Duration Estimator:** Calculates total setlist run time based on song BPMs and measure counts, including custom pause/intermission dividers.
  2. **Key & Tempo Distribution Analytics:** Graph showing setlist key diversity to avoid consecutive songs in the same key.

---

## 4. Prioritized Feature Matrix & Implementation Phases

```
+-----------------------------------------------------------------------------------------------+
| Category            | Feature Name                 | Target Audience  | Est. Effort | Priority |
+---------------------+------------------------------+------------------+-------------+----------+
| Novel Innovation    | Swara / Raga Notation View   | Indian / Devotional| Medium      | P1       |
| Novel Innovation    | Smart Capo Optimizer         | Guitarists       | Low         | P1       |
| Enhancement         | Text-to-ChordPro Converter   | All Users        | Low         | P1       |
| Novel Innovation    | Stage HUD & OLED Red Mode    | Live Performers  | Medium      | P2       |
| Novel Innovation    | Offline Pitch Pipe Cuer      | Vocalists        | Low         | P2       |
| Enhancement         | Visual Edge Metronome        | Performers       | Low         | P2       |
| Enhancement         | Interactive Fretboard Editor | Guitarists       | Medium      | P2       |
| Novel Innovation    | Acoustic Strum Page Turner   | Hands-free Gigs  | High        | P3       |
| Enhancement         | Consolidated Setlist PDF     | Gigging Bands    | Medium      | P3       |
| Novel Innovation    | Local Song Snapshots         | Songwriters      | Medium      | P3       |
+---------------------+------------------------------+------------------+-------------+----------+
```

---

## 5. Architectural Compliance & Security Verification

All proposed innovations strictly comply with the established core rules in [`CLAUDE.md`](../CLAUDE.md):

1. **Zero Internet Requirement:** All pitch generation, audio analysis, PDF creation, and transposition run 100% locally on device hardware. No network permissions required or added.
2. **Database Integrity:** Local version snapshots and custom chord voicings are stored cleanly via Drift (SQLite) migrations without corrupting existing schemas.
3. **Performance Budget:** Audio processing and custom painting execute within 60fps frame budgets without blocking the UI main thread.
