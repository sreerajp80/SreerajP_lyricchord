# Change log: Guideline compliance — Phase 6, part 2 (shorter UI texts)

Implements the rest of Phase 6 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md).
Part 1: [20261023_221456_guideline-compliance-phase6-part1.md](20261023_221456_guideline-compliance-phase6-part1.md).

The user approved all drafted texts on 2026-10-23: the 48 shorter texts, the 14 Help
edits and the 2 optional edits, exactly as listed in the plan section "Phase 6 — proposed
shorter texts".

## What changed

### `lib/l10n/app_en.arb` (+ generated files)

- **48 short UI texts** shortened to fit the 20-character limit, as drafted (for example
  "Share Setlist via AirQR Stream" → "Send via AirQR", "Stage Quiet Mode (Mute
  ringer/alerts)" → "Turn on Quiet Mode", "Carnatic & Hindustani songs" → "Indian songs").
  The full old → new list is the table in the plan.
- **2 optional edits:** "Pause Optical Stream" → "Pause stream", "Double-tap top half" →
  "Double-tap top".
- **14 Help strings** (15 replacements; `helpEditorS5P2` had two) now quote the new names.
- **132 translator notes** (`@…` descriptions, not shown in the app) that named an old text
  now name the new one, for example "Help › Pitch Pipe & Drone › …".
- `tooltipMetronomeStop`, `tooltipMetronomeStart` and `actionMetronomeUseSongTempo` no longer
  show the tempo number, so their unused `{bpm}` placeholder was removed.

### Code

- `lib/widgets/metronome_beat.dart`, `lib/widgets/metronome_tempo_sheet.dart` — stop passing
  the tempo to those three strings.

### Tests

- `test/l10n/label_length_test.dart` — the temporary exception list is now **empty**. Every
  short UI text fits its budget.
- Tests that looked for the old texts now look for the new ones (36 quoted texts replaced
  across 10 files, plus hand edits in `app_localizations_plural_test.dart`,
  `import_preview_screen_test.dart` and `metronome_tempo_sheet_test.dart`). The assertion on
  the old metronome tooltip text with a tempo was removed, because that text no longer
  exists.
- `test/widgets/carnatic_notation_sheet_test.dart` — the switch label now contains "Ma1"
  itself, so the test checks that "Ma2" is gone and "Ma1" appears twice (label and line).

### Docs

- `docs/features.md`, `docs/carnatic_notation.md` — quoted UI names updated (Chord
  Reference, Pitch Pipe & Drone, Paste Carnatic, Import ChordPro, Export all songs, Help
  topic names).
- Point-in-time docs (`docs/implementation_plan.md`, `docs/implementation_progress.md`) and
  the original-app description (`docs/lyriccord_idea.md`) were not changed.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1015 tests passed, including the length test with no exceptions.

## Not done

- Not checked on a device. The texts are shorter, so nothing should overflow, but a quick
  look at the song list, AirQR screens, metronome sheet, pitch pipe sheet and Help is worth
  doing.
- Like-for-like note: these labels now differ from the original Android app's wording. The
  user approved that to meet the guideline's length budget.
