# Change Log: Keep Indian and Western notation separate

**Plan Reference:** `plans/20260808_231500_keep_indian_and_western_notation_separate.md`

## Why

The song page turned Western chords into swara symbols and kept the Western
quality glued on, so a Carnatic song showed `P7`, `M₁` and `Sm` above the words.
None of those exist in Indian classical music. On top of that, `{raga: …}`
printed as a lyric line and the Swaram block wrapped in the middle of a phrase.

The rule now is simple: **no conversion in either direction.** A Western song
stays Western. An Indian song stays Indian.

## What changed

### The conversion engine is gone
- `lib/services/swara_notation_service.dart` — rewritten. `SwaraNotationService`
  is now `SwaraNotation`, a vocabulary only: `isSwaraToken`, `isSwaramLine` and
  `talaBeats`. `formatChord`, `pitchToSwaraSymbol` and `SwaraDisplayMode` were
  deleted.
- `lib/services/chord_transposer.dart` — the `mode:` parameter is gone from
  `transposeLyrics()` and `chordsUsed()`.
- `lib/providers/performance_provider.dart` — `swaraDisplayMode`,
  `cycleSwaraDisplayMode()` and `setSwaraDisplayMode()` removed.
- `lib/screens/song_performance_screen.dart` — the "Notation System" menu item
  and its radio dialog removed. No notation picker and no default-notation
  setting is left anywhere in the app.
- `lib/widgets/harmonium_chord_diagram.dart` — the swara labels painted on the
  keys were the same conversion (a Western chord's notes named as swaras), so
  they were removed along with the now-unused `showSwaraLabels` and `labelColor`
  parameters. The keyboard still highlights the chord's notes as before.

### Raga and tala are header information, not lyrics
- `lib/services/chord_sheet_parser.dart` — a whole-line `{name: value}` is now
  read as a directive. New `parseSheet()` returns a `ParsedSheet` holding the
  directives and the drawable lines; `parse()` keeps its old signature and
  simply leaves directive lines out, so every existing caller stopped printing
  them with no other change. A lyric that merely contains a brace is untouched.
- `lib/widgets/performance_controls.dart` — shows `Raga … · Tala …` under the
  status line, and reads `Sa = E` instead of `Key E` for a song that names a
  raga.

### Swaram lines are drawn as a beat grid
- `lib/services/chord_sheet_parser.dart` — added `ChordLineKind`. A chordless
  line whose tokens are all swaras is tagged `swaram`. A line like
  `[S]Krishna nee be[M]gane baro` stays `lyric`, so it keeps wrapping normally.
- `lib/widgets/chord_sheet_view.dart` — a swaram line draws in the fixed-width
  font at full lyric size and scrolls sideways instead of wrapping.

### Tempo-Auto follows the tala (was always 4/4)
This was a real timing bug, not only a display one. `beatsPerMeasure` was
hard-coded to 4, so an Adi tala song (8 aksharas) scrolled **twice as fast** as
it should and ran off the end.
- `lib/services/swara_notation_service.dart` — `talaBeats` covers the Carnatic
  talas (Adi 8, Rupaka 6, Misra Chapu 7, Khanda Chapu 5, Ata 14, Jhampa 10 and
  others) and the Hindustani ones (Teental 16, Ektal 12, Jhaptal 10, Keherwa 8,
  Dadra 6, Rupak 7). Case and a trailing "tala"/"talam" are ignored. Unknown
  falls back to 4.
- `lib/providers/auto_scroll_provider.dart` — `beatsPerMeasure` added to
  `AutoScrollSettings` and `loadForSong()`. It lives in the state because four
  widgets compute the duration and must all agree. Changing the `{tala}` line
  re-times the scroll immediately, without reopening the song.
- The four call sites now pass it: the performance screen,
  `auto_scroll_controls.dart`, `performance_controls.dart` and `stage_hud.dart`.

### PDF export matches the screen
- `lib/services/pdf_export_service.dart` — prints Raga/Tala in the header, uses
  `Sa:` instead of `Key:` for an Indian song, and prints a swaram line as one
  fixed-width row (`.swaram` CSS class).

### The seeded classical songs are written in swaras
- `lib/data/app_database.dart` — the three classical songs were hard-coded in
  four near-identical blocks. They are now one shared `_classicalSeedSongs()`
  list built from three named constants, used by first-run seeding, by the
  "seed anything missing" upgrade and by the new migration.
- Their markers now hold swaras: `[S]Krishna nee be[M]gane baro`, not `[E]`/`[A]`.
- Schema bumped to **v7**. The old v5 and v6 text-rewrite migrations were
  replaced by one `_rewriteClassicalSongsInSwaraNotation()` that runs for anyone
  below v7, so existing installs are fixed too. Matching is by title, so a song
  the user renamed or wrote themselves is never overwritten.

## Notes on two judgement calls

- **Harmonium swara labels were removed, not kept.** The plan said to point that
  widget at the renamed class or drop the field. Since the label was produced by
  the deleted converter, dropping it was the only choice consistent with "no
  conversion".
- **`{tala: Keherwa}` was added to "Raghupati Raghava Raja Ram".** It had no tala
  line before. Keherwa (8 beats) is the standard bhajan cycle. If you would
  rather it carried no tala, deleting that one line restores the 4/4 default.

## Verification

- `flutter analyze` — **No issues found.**
- `flutter test` — **380 tests, all passed.**
- `dart format lib test` — applied.

New and updated tests:
- `test/services/swara_notation_service_test.dart` — rewritten for the
  vocabulary: `isSwaraToken`, `isSwaramLine`, `talaBeats` (11 tests).
- `test/services/chord_sheet_parser_test.dart` — directives extracted and not
  drawn, unknown directives kept, a braced lyric left alone, swaram detection,
  and swara-marked lyrics staying lyric.
- `test/widgets/chord_sheet_view_test.dart` — swaram lines use the fixed-width
  font, do not wrap, and scroll horizontally.
- `test/services/chord_transposer_test.dart` — swara markers, swaram lines and
  raga directives all survive a transpose unchanged.
- `test/services/auto_scroll_calculator_test.dart` — an Adi tala cycle is twice
  a 4/4 measure, and still ends exactly at song end.
- `test/services/pdf_export_service_test.dart` — directives print in the header
  and never as lyric text; Western songs still read "Key".

A test caught a real bug while writing this: the first `talaBeats` stripped a
trailing "tal" before looking the name up, which turned `Teental` into `teen`.
It now tries the whole name first.
