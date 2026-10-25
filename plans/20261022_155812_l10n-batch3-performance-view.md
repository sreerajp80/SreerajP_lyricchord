# Plan: Localization batch 3 — performance view

**Status:** completed

## The issue

`CLAUDE.md` says every user-visible text must come from `lib/l10n/*.arb`
through `AppLocalizations`. Batches 1 and 2 did the songbook, setlists and
editor. This batch does the song performance view: the screen itself, its
controls, Stage Mode (full screen), the chord/swara reference, the metronome,
the pitch drone controls, and the chord diagrams' screen-reader labels.

This is the largest batch: about 170 texts in 18 files.

## What changes

The English the user sees stays the same, except one plural fix (below).

### Rules (same as batches 1 and 2)

- Reuse existing keys where the text is the same: `cancel`, `share`,
  `settings`, `editorMoreOptions`, `songListFormatChordPro`,
  `songListFormatPdf`, `setlistSongCount`, `traditionWestern`.
- New keys named by area: `perf…`, `perfControls…`, `autoScroll…`,
  `transpose…`, `chordRef…`, `stageHud…`, `stageHelp…`, `gestures…`,
  `metronome…`, `drone…`, `diagram…`, `melodyGrid…`; shared `close`,
  `export`, `play`, `pause`, `reset`.
- Counts use ICU plurals; names and numbers are placeholders.
- Every key gets an `@key` description.
- Not moved (allowed literals): numbers shown alone (`'$count'`, `'$bpm'`,
  `'${idx + 1}'`), the speed format `1.25x`, the `m:ss` time format, the
  `'monospace'` font name, map/format values (`'chordpro'`, `'pdf'`,
  `'airqr'`, `'Pa'`, `'Ma'`), route paths, file names and extensions, the
  `{tonic}` directive key, the regex in `pitch_drone_controls.dart`, and the
  melody grid's on-screen symbols (`,` and `|`).

### Plural fix

- Performance screen setlist header: "1 songs" → "1 song" (reuses
  `setlistSongCount` from batch 1).

### "M" and "T" mode buttons

The Manual / Tempo buttons show the letters "M" and "T". These are
abbreviations, so they become keys too (`autoScrollManualShort`,
`autoScrollTempoShort`). In `stage_hud.dart` the tooltip is chosen by
comparing the label to `'M'`; that check changes to pass the tooltip in
directly, so it keeps working in any language.

### Texts by file

- **`song_performance_screen.dart`** (~45): "Song", Previous / Next song,
  "Setlist songs", "Edit song", setlist header and title
  ("{name} ({index}/{total})"), "Song not found" and its message, the
  overflow menu (Performance controls, Export, Share, Gestures help,
  Settings), the reference dialog title (Swara Reference / Chord Reference
  Guide), the Export and Share dialogs (titles, format options incl.
  "AirQR Stream (Animated QR)", Cancel, Export, Share), save-dialog titles
  ("Export as PDF", "Export as ChordPro"), and all export/share SnackBars.
- **`performance_controls.dart`** (~12): drone tooltip; the summary line
  parts ("Raga {raga}", "Tala {tala}", "Key {key}", "({signed})",
  "Auto-scroll · {bpm} BPM", "{count} bars"); the speed tooltip; Hide /
  Show chords; Hide / Show melody.
- **`auto_scroll_controls.dart`** (5): Full screen, Manual, Tempo, M, T.
- **`transpose_sheet.dart`** (10): title, Transpose, Transpose down / up,
  Reset, Show chords, Show melody and its subtitle, the pinch tip.
- **`chord_reference_dialog.dart`** (6): Swara Reference / Chord Reference,
  Close, the two empty messages, Guitar / Harmonium tabs.
- **`stage_hud.dart`** (~15): Exit full screen, Lock Stage View, the two
  Quiet Mode tooltips, Gestures help, Play / Pause, Fewer / More bars,
  Slower / Faster, M / T, the info line ("Raga …", "Tala …", "Key …",
  "{bpm} BPM").
- **`stage_help_overlay.dart`** (15): the six gesture rows (name + effect),
  title, subtitle, "Tap anywhere to start".
- **`gestures_help_dialog.dart`** (16): the six gesture rows (name +
  explanation), title, subtitle, Close, "Help Center", "Got it".
- **`scroll_gesture_layer.dart`** (4): the "Playing" / "Paused" and
  "{count} bars" flashes, "Stage Locked".
- **`metronome_tempo_sheet.dart`** (~14): tap-tempo hints (with a plural for
  "{count} more taps"), title, the tempo source line, Slower / Faster by 1,
  "BPM", "{bpm} BPM", "Tap tempo", "Use song tempo ({bpm} BPM)", "No song
  tempo to go back to".
- **`metronome_beat.dart`** (2): Start / Stop metronome tooltip.
- **`pitch_drone_controls.dart`** (~18): the "Could not play the sound."
  fallback, title, mode segments (Classical (Shruti), Western (Chords)), the
  Sa + Pa / Sa + Ma and Major / Minor segments, Chord / Pitch Cue (2s),
  Stop / Chord / Shruti Drone, "Stage Text Scale", the key line ("Your Sa:
  {name}", "Song key: {key}", "Root Pitch Key").
- **`chord_sheet_view.dart`** (1): "This song has no lyrics yet."
- **`guitar_chord_diagram.dart`**, **`harmonium_chord_diagram.dart`**,
  **`swara_keyboard_diagram.dart`** (5): screen-reader labels and
  "No diagram".
- **`melody_beat_grid.dart`** (3): screen-reader words "hold", "bar line",
  "could not read {text}".

### Not in this batch

- Error messages made in providers (`pitch_drone_provider.dart`: "Could not
  play the chord cue.", "Could not play the pitch cue.", "Could not start the
  drone.") go to the proposed **batch 8 — service and provider messages**,
  together with the melody/Carnatic parser problems. The providers would
  return an error kind, and the widget would pick the text.
- `DroneMode.displayName` and `ChordQuality.displayName` (model labels) are
  only used by the pitch drone settings screen, so they move in **batch 4**.

## Tests

Tests that pump these widgets in a bare `MaterialApp` get the localization
delegates (same change as batch 2):

`performance_controls_test`, `stage_hud_test`, `scroll_gesture_layer_test`,
`metronome_beat_test`, `metronome_tempo_sheet_test`,
`pitch_drone_controls_test`, `chord_reference_dialog_test`,
`chord_diagram_semantics_test`, `gestures_help_dialog_test`,
`swara_keyboard_diagram_test`, `melody_beat_grid_test`.

Their English text checks stay the same, except the "1 song" fix if a test
checks it.

New checks in `test/l10n/app_localizations_plural_test.dart`: the
"{count} more taps" plural, the setlist position title, the signed transpose
part, and the bar count flash.

## Files to change

- `lib/l10n/app_en.arb` (+ regenerated `app_localizations*.dart`)
- `lib/screens/song_performance_screen.dart`
- `lib/widgets/performance_controls.dart`, `auto_scroll_controls.dart`,
  `transpose_sheet.dart`, `chord_reference_dialog.dart`, `stage_hud.dart`,
  `stage_help_overlay.dart`, `gestures_help_dialog.dart`,
  `scroll_gesture_layer.dart`, `metronome_tempo_sheet.dart`,
  `metronome_beat.dart`, `pitch_drone_controls.dart`, `chord_sheet_view.dart`,
  `guitar_chord_diagram.dart`, `harmonium_chord_diagram.dart`,
  `swara_keyboard_diagram.dart`, `melody_beat_grid.dart`
- The 11 tests listed above, and `test/l10n/app_localizations_plural_test.dart`

No files in the `docs/guidelines/` submodule are touched. No database, Android
or iOS change.

## Checks after the change

- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass).
- A search of the 18 files finds no user-visible string literal left, except
  the allowed ones and the provider messages noted above.

## Change log

`change_log/<timestamp>_l10n-batch3-performance-view.md` after the work.
