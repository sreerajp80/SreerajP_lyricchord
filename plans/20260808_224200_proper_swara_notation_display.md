# Plan: Proper & Understandable Swara Notation Display

**Status:** completed

## Problem & Context
The current Swara chord converter inserts spaces between the Swara root and chord qualities (e.g., turning `B7` into `P 7`, `C#m` into `S m`, `F#m7` into `m m7`). This looks like two separate unrelated elements rather than a unified chord symbol.

Additionally, musicians reading Indian music expect standard Carnatic Swarasthanam symbols with subscripts (`S`, `R₁`, `R₂`, `G₂`, `G₃`, `M₁`, `M₂`, `P`, `D₁`, `D₂`, `N₂`, `N₃`) or full Swara names (`Sa`, `Ri`, `Ga`, `Ma`, `Pa`, `Dha`, `Ni`), exactly as shown in Carnatic / Hindustani notation sheets.

## Proposed Changes

### `lib/services/swara_notation_service.dart`
- Update `swaraSymbols` to standard Carnatic Swarasthanam notation with subscripts:
  - 0: `S` (Sa)
  - 1: `R₁` (Shuddha Ri)
  - 2: `R₂` (Chathushruthi Ri)
  - 3: `G₂` (Sadharana Ga)
  - 4: `G₃` (Antara Ga)
  - 5: `M₁` (Shuddha Ma)
  - 6: `M₂` (Prati Ma)
  - 7: `P` (Pa)
  - 8: `D₁` (Shuddha Dha)
  - 9: `D₂` (Chathushruthi Dha)
  - 10: `N₂` (Kaisiki Ni)
  - 11: `N₃` (Kakali Ni)
- Fix `_tokenToSwara` chord suffix formatting: remove space between Swara root and chord quality (e.g., `P7` instead of `P 7`, `Sm` instead of `S m`).
- Ensure slash chords format cleanly without extra spaces (e.g. `S/P` or `M₁/S`).

### `test/services/swara_notation_service_test.dart`
- Update unit tests to verify proper Carnatic Swara chord output (`S`, `m`, `P7`, `R₂`, `G₃`, etc.) and ensure slash chords work cleanly without spaces.

### `lib/widgets/harmonium_chord_diagram.dart`
- Ensure key surface labels display the clean Swara symbols.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero analysis errors/warnings.
- Run `flutter test test/services/swara_notation_service_test.dart` to verify all Swara formatting tests pass.

### Manual Verification
- View song in performance mode with Swara enabled. Verify chords display as `S`, `m`, `P7` cleanly aligned over lyrics without awkward spaces.
