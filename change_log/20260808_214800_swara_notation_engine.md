# Change Log: 4.1 Swara & Indian Classical / Devotional Notation Engine

**Plan:** [plans/20260808_210500_swara_notation_engine.md](../plans/20260808_210500_swara_notation_engine.md)
**Date:** 2026-08-08

## Summary of Changes
Implemented the **Swara & Indian Classical / Devotional Notation Engine** for LyricChord, enabling musicians to perform songs using Indian relative Swaras (*Sa, Re, Ga, Ma, Pa, Dha, Ni* / *S, R, G, m, P, D, N*) in addition to standard Western chords.

### 1. New Pure Logic Service
* **[lib/services/swara_notation_service.dart](../lib/services/swara_notation_service.dart)**: Added `SwaraNotationService` and `SwaraDisplayMode` (`western`, `swara`, `dual`). Maps 12 chromatic semitone offsets relative to any tonic *Sa* pitch class. Converts single chords and slash chords (`C#/F#` -> `S/m`) into Swara or Dual overlay notation.

### 2. State & Transposer Integration
* **[lib/providers/performance_provider.dart](../lib/providers/performance_provider.dart)**: Added `swaraDisplayMode` to `PerformanceSettings` and notifier methods (`cycleSwaraDisplayMode`, `setSwaraDisplayMode`).
* **[lib/services/chord_transposer.dart](../lib/services/chord_transposer.dart)**: Extended `transposeLyrics` and `chordsUsed` to support `SwaraDisplayMode`. Automatically aligns Western chords and Swara scale degrees during bilingual semitone transposition.

### 3. Visualizer & UI Integration
* **[lib/widgets/harmonium_chord_diagram.dart](../lib/widgets/harmonium_chord_diagram.dart)**: Updated `_HarmoniumPainter` to draw Swara letter badges (`S`, `r`, `R`, `g`, `G`, `m`, `M`, `P`, `d`, `D`, `n`, `N`) directly on white and black key surfaces.
* **[lib/screens/song_performance_screen.dart](../lib/screens/song_performance_screen.dart)**: Added "Notation System" menuItem inside the top-right overflow menu (`⋮`) opening a modal to switch between `Western`, `Swara`, and `Dual Overlay` without cluttering the stage toolbar.

### 4. Comprehensive Unit Tests
* **[test/services/swara_notation_service_test.dart](../test/services/swara_notation_service_test.dart)**: Added unit test suite covering pitch-to-Swara calculations, slash chord parsing, dual overlay formatting, and bilingual transposition.

---

## Verification Results

### Automated Tests
* `flutter analyze`: **Clean (0 errors, 0 warnings)**
* `flutter test`: **355 / 355 unit tests passed**
