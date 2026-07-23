# Change log — Phase 6: Chord reference (guitar + harmonium diagrams)

**Date:** 2026-07-21

**Plan:** [plans/20260721_100622_phase-6-chord-reference.md](../plans/20260721_100622_phase-6-chord-reference.md)

## What changed

Added the **Chord Reference Guide** to the performance view. The overflow menu
item (a "Coming soon" placeholder before) now opens a dialog with **Guitar** and
**Harmonium** tabs. It lists the song's chords already transposed to the current
key and draws a diagram for each.

## New files

- `lib/services/chord_shape_service.dart` — pure logic. Turns a chord name into:
  - a **guitar shape** (six fret values): a hand-picked map of common open
    chords (C, G, Am, E7, Cmaj7 …) plus a movable barre fallback (E-shape or
    A-shape at the lower fret) that covers all twelve roots for major, minor, 7,
    m7 and maj7. Returns `null` for a quality it cannot draw.
  - a **harmonium shape** (the chord's note pitch-classes, the root, and a
    slash-chord bass note), computed from the root and an interval set per
    quality.
  - Never throws: junk input gives `null` for guitar and a major-triad fallback
    for harmonium (CLAUDE.md hard rule 4).
- `lib/widgets/guitar_chord_diagram.dart` — `GuitarChordDiagram`, a
  `CustomPainter` that draws strings, frets, finger dots, `O`/`X` markers, the
  nut, and a base-fret number. Theme-aware. Shows a small "No diagram" note when
  the shape is `null`.
- `lib/widgets/harmonium_chord_diagram.dart` — `HarmoniumChordDiagram`, a
  `CustomPainter` that draws two octaves of keys and lights up the chord's
  notes, the root in a stronger shade. Theme-aware.
- `lib/widgets/chord_reference_dialog.dart` — `ChordReferenceDialog` (and a
  `showChordReferenceDialog` helper): a `Dialog` with a Guitar/Harmonium
  `TabBar`, each tab a scrolling `Wrap` of labelled diagrams. Shows a friendly
  message when the song has no chords.
- `test/services/chord_shape_service_test.dart` — open shapes, barre fallback,
  slash chords, harmonium note sets (major/minor/7/maj7/sus/dim), and bad-input
  safety.
- `test/widgets/chord_reference_dialog_test.dart` — both tabs render, tab
  switching shows keyboard diagrams, empty list shows the message.

## Changed files

- `lib/screens/song_performance_screen.dart` — `_OverflowMenu` now takes the
  current song id. The Chord Reference Guide item is enabled: it reads the song
  and the live transpose amount, builds the sounding chords with
  `ChordTransposer.chordsUsed(...)`, and opens the dialog. It stays disabled
  when there is no song or the song has no chords.
- `docs/implementation_progress.md` — Phase 6 marked done; Phase 7 is next.

## Notes

- No new packages: diagrams are drawn with `CustomPainter`, so the app stays
  fully offline (architecture §20).
- Layer boundary kept: the widgets do no note theory — the service works out the
  shapes and notes; the widgets only draw what they are handed.
- The original Android fret-data map was not available in this repo, so the
  guitar shapes use standard, well-known fingerings rather than an exact copy.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 153 tests pass.
- `dart format .` applied to the new and changed files.
- Not yet run on a device/emulator.
