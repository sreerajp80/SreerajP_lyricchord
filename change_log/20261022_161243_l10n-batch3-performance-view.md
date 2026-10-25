# Change log: Localization batch 3 — performance view

Implements
[plans/20261022_155812_l10n-batch3-performance-view.md](../plans/20261022_155812_l10n-batch3-performance-view.md).

## What changed

All user-visible text in the song performance view now comes from
`lib/l10n/app_en.arb` through `AppLocalizations`.

- **`lib/l10n/app_en.arb`:** 137 new keys, each with an `@key` description
  (343 keys in all). Reused `cancel`, `share`, `settings`,
  `editorMoreOptions`, `songListFormatChordPro`, `songListFormatPdf` and
  `setlistSongCount`. New shared keys: `close`, `export`, `play`, `pause`,
  `reset`, and `info…` keys for the song info line used by both the
  performance controls and the Stage HUD. `flutter gen-l10n` re-run.
- **Screen:** `song_performance_screen.dart`.
- **Widgets:** `performance_controls.dart`, `auto_scroll_controls.dart`,
  `transpose_sheet.dart`, `chord_reference_dialog.dart`, `stage_hud.dart`,
  `stage_help_overlay.dart`, `gestures_help_dialog.dart`,
  `scroll_gesture_layer.dart`, `metronome_tempo_sheet.dart`,
  `metronome_beat.dart`, `pitch_drone_controls.dart`, `chord_sheet_view.dart`,
  `guitar_chord_diagram.dart`, `harmonium_chord_diagram.dart`,
  `swara_keyboard_diagram.dart`, `melody_beat_grid.dart`.
- The gesture lists in `stage_help_overlay.dart` and
  `gestures_help_dialog.dart` were `const` lists of English text. They are now
  small functions that build the list from `AppLocalizations`.
- The status line and Stage HUD read-out are built from translated parts
  joined with the same `  ·  ` separator as before.

## "M" / "T" mode buttons

- The letters are now keys (`autoScrollManualShort`, `autoScrollTempoShort`).
- `stage_hud.dart` used to pick the tooltip with `label == 'M'`. `_ModeButton`
  now takes its tooltip as a parameter, so it works whatever the letters are.

## Text the user sees

The English is the same as before, except:

- Performance screen setlist sheet: "1 songs" → "1 song".
- Bar counts (status line and the double-tap flash): "1 bars" → "1 bar".

## Small additions found on the way

- The pitch drone button in the Stage HUD had no tooltip, so a screen reader
  could not name it. It now uses "Pitch pipe & shruti box", like the same
  button on the normal screen.
- The close (X) button of the pitch pipe sheet had no tooltip. It now says
  "Close".

## Left as code (allowed literals)

Numbers shown alone, the `1.25x` speed and `m:ss` time formats, the `+2`
transpose sign, the `%` text-scale values, `'monospace'`, format and segment
values (`'chordpro'`, `'pdf'`, `'airqr'`, `'Pa'`, `'Ma'`), route paths, file
names, the `tonic` directive key, and the minor-chord regex.

## Not changed (as planned)

- Provider error messages in `pitch_drone_provider.dart` (batch 8).
- `DroneMode.displayName` / `ChordQuality.displayName` (batch 4, settings).

## Tests

- Localization setup added to the `MaterialApp` in 11 widget tests:
  `performance_controls`, `stage_hud`, `scroll_gesture_layer`,
  `metronome_beat`, `metronome_tempo_sheet`, `pitch_drone_controls`,
  `chord_reference_dialog`, `chord_diagram_semantics`,
  `gestures_help_dialog`, `swara_keyboard_diagram`, `melody_beat_grid`.
  Their text checks did not change.
- `test/l10n/app_localizations_plural_test.dart`: 2 more tests (bar and tap
  plurals; setlist position, transposed key, metronome and drone
  placeholders).

## Checks

- `dart format`, `flutter analyze`: no issues.
- `flutter test`: 962 tests, all pass.
- A search of the 18 files finds only the allowed literals listed above.
- No Android, iOS or database change, so no Gradle build was needed.
