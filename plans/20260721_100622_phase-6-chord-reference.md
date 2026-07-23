# Plan — Phase 6: Chord reference (guitar + harmonium diagrams)

**Status:** completed

**Date:** 2026-07-21

## What this phase is

Add the **Chord Reference Guide** dialog to the performance view. It lists the
song's chords (already transposed to the current key) and shows a diagram for
each chord in two tabs:

- **Guitar** — a fretboard diagram (dots, open `O` and muted `X` strings, base
  fret number).
- **Harmonium** — a keyboard diagram with the chord's notes highlighted.

This matches [docs/implementation_plan.md](../docs/implementation_plan.md)
Phase 6 and the idea doc §"Chord reference".

## The issue / gap today

- The overflow menu in the performance view shows a disabled **Chord Reference
  Guide** item ("Coming soon"). Nothing draws diagrams yet.
- The transposer already exposes `chordsUsed(...)`, built earlier for exactly
  this — so the data side is ready; only the diagrams and the dialog are missing.

## Design (layers)

Follow the project layers: pure logic in `services/`, drawing + dialog in
`widgets/`, and only a small wiring change in the screen.

### 1. Service — `lib/services/chord_shape_service.dart` (new, pure logic)

A pure service (no UI, no storage). Never throws; unknown input falls back to a
safe default (CLAUDE.md hard rule 4). It provides two things per chord name:

- `GuitarChordShape? guitarShape(String chord)`
  - Value type holding six fret values (index 0 = low E … 5 = high e), where
    `-1` = muted, `0` = open, otherwise the absolute fret number.
  - A small **curated map** of the common open chords (C, A, G, E, D and their
    minors/7ths/maj7ths, plus F) so the everyday keys look the way players
    expect.
  - A **movable barre fallback** for any other root: pick the E-shape or A-shape
    (whichever sits at the lower fret) for the chord's quality and shift it to
    the root. This covers all 12 roots for major, minor, 7, m7, maj7.
  - Returns `null` for a quality it has no shape for, so the guitar tab can show
    a short "diagram not available" note instead of guessing.
- `HarmoniumChordShape harmoniumShape(String chord)`
  - Value type holding the chord's note pitch-classes (0–11), which one is the
    root, and an optional bass note for a slash chord.
  - Computed from the root note plus an **interval set for the quality**
    (major `0,4,7`; minor `0,3,7`; 7 `0,4,7,10`; m7 `0,3,7,10`; maj7 `0,4,7,11`;
    dim `0,3,6`; aug `0,4,8`; sus2 `0,2,7`; sus4 `0,5,7`; 6/m6/add9 as well).
  - Unknown quality falls back to the major triad, so it always returns a value.

Chord parsing reuses the note tables in `chord_suggestion_service.dart`
(`sharpNotes` / `flatNotes`) — the app's single source of note spelling. It
splits a name into root note (letter + optional `#`/`b`) and a quality suffix,
and for a slash chord (`C/E`) uses the left side for the shape and the right
side as the harmonium bass note.

### 2. Widgets — two `CustomPainter` diagrams

- `lib/widgets/guitar_chord_diagram.dart` (new): `GuitarChordDiagram` wraps a
  `CustomPaint`. Draws six strings, the fret lines, finger dots, `O`/`X` markers
  above the nut, and a base-fret label when the shape sits up the neck. Colors
  come from the current `Theme`, so it works in light and dark.
- `lib/widgets/harmonium_chord_diagram.dart` (new): `HarmoniumChordDiagram`
  wraps a `CustomPaint`. Draws a short keyboard (about two octaves of white keys
  with the black keys on top) and fills the chord's notes — the root in a
  stronger shade. Theme-aware.

Each takes the chord name as a label plus the shape from the service.

### 3. Dialog — `lib/widgets/chord_reference_dialog.dart` (new)

`ChordReferenceDialog` is a `Dialog` with a `TabBar` (Guitar | Harmonium) and a
`TabBarView`. It is given the already-transposed, distinct chord list. Each tab
is a scrollable `Wrap` of labelled diagrams. A `showChordReferenceDialog(...)`
helper opens it. An empty chord list shows a friendly "no chords in this song"
message.

### 4. Wiring — `lib/screens/song_performance_screen.dart` (modify)

- Pass the current song id into `_OverflowMenu`.
- Enable the **Chord Reference Guide** item. On tap it reads the current song
  (`songByIdProvider`) and the performance settings, computes the transposed
  chords with `ChordTransposer.chordsUsed(...)`, and opens the dialog. It is
  disabled only when there is no song or the song has no chords.

## Files to change

**New:**
- `lib/services/chord_shape_service.dart`
- `lib/widgets/guitar_chord_diagram.dart`
- `lib/widgets/harmonium_chord_diagram.dart`
- `lib/widgets/chord_reference_dialog.dart`
- `test/services/chord_shape_service_test.dart`
- `test/widgets/chord_reference_dialog_test.dart`

**Modify:**
- `lib/screens/song_performance_screen.dart` — enable + wire the menu item.
- `docs/implementation_progress.md` — mark Phase 6 done (after implementation).

**After implementation:**
- `change_log/<ts>_phase-6-chord-reference.md` — the change log.

## Tests

- **Service** (`chord_shape_service_test.dart`):
  - Guitar shapes for known open chords are correct (e.g. C = `x32010`,
    Am = `x02210`, G = `320003`, E7, D…).
  - Barre fallback returns six valid fret values for roots with no open shape
    (e.g. F#, Bb) for major/minor/7/m7/maj7.
  - Harmonium note sets are correct (C → {0,4,7}; Am → {9,0,4}; C7 adds 10;
    Cmaj7 adds 11).
  - Slash chord `C/E` → guitar uses the C shape; harmonium bass note = E.
  - Junk input (`"?"`, `""`, `"H9"`) never throws: guitar returns `null`,
    harmonium returns the major triad fallback.
- **Widget** (`chord_reference_dialog_test.dart`):
  - The dialog opens, both tabs are present, and the chord names are shown.
  - Empty chord list shows the "no chords" message.

## Definition of Done

- The dialog shows correct diagrams for a song's chords in both tabs.
- `flutter analyze` is clean; `flutter test` passes; `dart format .` applied.

## Notes / constraints kept

- No new packages (diagrams are drawn with `CustomPainter`, not images) — keeps
  the app fully offline and matches architecture §20.
- Widgets do not know note theory: the service works out shapes and notes; the
  widgets only draw what they are handed (layer boundary rule).
