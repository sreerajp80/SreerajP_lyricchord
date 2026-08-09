# Technical Implementation Plan: 4.1 Swara & Indian Classical / Devotional Notation Engine

**Status:** Pending Approval

## Context & User Goal
Existing chord applications are 100% Western-centric (`C`, `Dm`, `G7`, `F#m`). Millions of Indian classical, devotional, bhajan, harmonium, and keyboard artists read music using **Swaras** (*Sa, Re, Ga, Ma, Pa, Dha, Ni* / *S, R, G, m, P, D, N*).

This feature introduces a dedicated offline **Swara Notation Engine** to LyricChord with:
1. **Dynamic Key-Root Mapping**: Map any Western key root (e.g. `C#`, `D`, `G#`) as the tonic *Sa*.
2. **Uncluttered Notation Toggle**: Access notation selection (`Western`, `Swara`, `Dual Overlay`) via the Song Overflow Menu (`⋮` top right) without cluttering the main performance toolbar.
3. **Persistent App Settings Default**: Set preferred default notation system (`Western`, `Swara`, or `Dual`) in App Settings.
4. **Harmonium Swara Highlighting**: Harmonium reference key diagrams dynamically display Swara labels on key surfaces.
5. **Bilingual Transposition**: Transposing by semitones shifts both Western chords and Swara scale degrees seamlessly in unison.

---

## Architectural & UX Blueprint

### 1. New Service: `SwaraNotationService`
* **File:** `lib/services/swara_notation_service.dart` (NEW)
* **Responsibilities:**
  * Maps 12 chromatic semitones relative to a chosen *Sa* root into Indian Swara symbols:
    * `+0`: `S` (Sa)
    * `+1`: `r` (komal Re)
    * `+2`: `R` (shuddha Re)
    * `+3`: `g` (komal Ga)
    * `+4`: `G` (shuddha Ga)
    * `+5`: `m` (shuddha Ma)
    * `+6`: `M` (tivra Ma)
    * `+7`: `P` (Pa)
    * `+8`: `d` (komal Dha)
    * `+9`: `D` (shuddha Dha)
    * `+10`: `n` (komal Ni)
    * `+11`: `N` (shuddha Ni)
  * Converts Western chord names (e.g. `C#m`, `F#7`, `G#sus4`, `C#/F#`) to Swara notation or Dual overlay given a root *Sa* note.
  * Preserves chord qualities (e.g. `m`, `7`, `maj7`, `sus4`, slash notes) cleanly.

### 2. State & Settings Integration
* **File:** `lib/providers/performance_provider.dart` & `lib/providers/settings_provider.dart` (MODIFY)
* **Changes:**
  * Define `enum SwaraDisplayMode { western, swara, dual }`.
  * Add `swaraDisplayMode` field to `PerformanceSettings` (initialized from user's persistent default setting).
  * Add `defaultSwaraDisplayMode` to `AppSettings` with `SharedPreferences` persistence.

### 3. Uncluttered UI Integration
* **File:** `lib/screens/song_performance_screen.dart` (MODIFY)
* **Changes:**
  * Add "Notation System" menuItem under the top-right overflow menu (`⋮`) opening a dialog/bottom sheet to switch between `Western (C#)`, `Swara (S)`, and `Dual (C# (S))`. Keeps the main stage toolbar clean!
* **File:** `lib/screens/settings_screen.dart` (MODIFY)
* **Changes:**
  * Add "Default Notation System" dropdown/radio tile under Performance Settings in App Settings.

### 4. Swara Rendering in `ChordSheetView` / `ChordTransposer`
* **File:** `lib/services/chord_transposer.dart` & `lib/widgets/chord_sheet_view.dart` (MODIFY)
* **Changes:**
  * Extend chord formatting so transposed lyrics render chords according to active `SwaraDisplayMode` and root *Sa* key.

### 5. Harmonium Key Surface Swara Highlighting
* **File:** `lib/widgets/harmonium_chord_diagram.dart` & `lib/services/chord_shape_service.dart` (MODIFY)
* **Changes:**
  * Update `_HarmoniumPainter` to draw Swara letter badges (`S`, `R`, `G`, `m`, `P`, `D`, `N`) directly on the white/black keys when Swara mode or key highlighting is enabled.

---

## Files to Modify & Create

### [NEW] Files
1. `lib/services/swara_notation_service.dart`: Core Swara pitch mapping and chord string converter.
2. `test/services/swara_notation_service_test.dart`: Unit tests for Swara chord formatting, dual overlay, and transposition.

### [MODIFY] Files
1. `lib/providers/performance_provider.dart`: Add `SwaraDisplayMode` and state notifier methods.
2. `lib/providers/settings_provider.dart`: Add persistent `defaultSwaraDisplayMode`.
3. `lib/services/settings_service.dart`: Read/write default notation preference to `SharedPreferences`.
4. `lib/screens/settings_screen.dart`: Add Default Notation System setting UI.
5. `lib/screens/song_performance_screen.dart`: Add Notation System item in overflow menu (`⋮`).
6. `lib/services/chord_transposer.dart`: Integrate Swara conversion methods for lyric sheets and chord lists.
7. `lib/widgets/harmonium_chord_diagram.dart`: Render Swara labels on key surfaces for harmonium diagrams.

---

## Verification Plan

### Automated Tests
* Run `flutter analyze` to ensure 0 static analysis errors/warnings.
* Run `flutter test` to execute existing tests and new Swara unit tests:
  ```bash
  flutter test test/services/swara_notation_service_test.dart
  ```

### Manual Verification
* Change Default Notation System in Settings screen and verify songs open with preferred default.
* Open song in Performance View, tap top-right overflow menu (`⋮`), select Notation System to test `Western`, `Swara`, and `Dual`.
* Transpose song up +1 semitone and verify both Western chords (`D`) and Swara degrees update in perfect harmony.
* Open Chord Reference guide and verify Harmonium diagrams display Swara labels on key surfaces.
