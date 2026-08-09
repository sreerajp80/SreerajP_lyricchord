# Keep Indian and Western notation separate (stop converting)

**Status:** completed

## What is wrong now

The screenshots show a Carnatic song ("Krishna Nee Begane Baro") rendered badly.
There are four separate problems.

### 1. The app converts Western chords into swara symbols

`SwaraNotationService.formatChord()` takes a Western chord, maps only its **root**
to a swara symbol, and then glues the Western quality back on
([swara_notation_service.dart:142](../lib/services/swara_notation_service.dart#L142)).

That is where `P7`, `M₁` and `Sm` in the screenshot come from. There is no such
thing as a "P7 chord" in Indian classical music, so the result is meaningless.
The subscript digits (`R₁`, `M₁`) also read like footnote marks at chord size.

The user's decision: **no conversion in either direction.** A Western song stays
Western. An Indian song stays Indian.

### 2. `{raga: ...}` and `{tala: ...}` print as raw text

`ChordSheetParser` has no idea what a `{name: value}` directive is
([chord_sheet_parser.dart:90](../lib/services/chord_sheet_parser.dart#L90)), so the
whole curly-brace line falls through as ordinary lyric text and is drawn on the
sheet — the `{raga: Yamunakalyani}` line in the screenshot.

### 3. The Swaram block is plain lyric text

The seeded songs write the swaram as one long lyric line
([app_database.dart:367](../lib/data/app_database.dart#L367)). It is drawn in the
proportional lyric font and wraps in the middle of the phrase, which is the ugly
two-line break in the screenshot. A swaram must line up in a fixed-width grid.

### 4. The seeded Carnatic songs are written in Western chords

`[E]Krishna nee be[A]gane baro` puts Western chords over Carnatic lyrics
([app_database.dart:359](../lib/data/app_database.dart#L359)). Under the new rule
these songs must carry swaras, not chords.

---

## The plan

### A. Remove the conversion engine

- `lib/services/swara_notation_service.dart` — delete `SwaraDisplayMode`,
  `formatChord()`, `_tokenToSwara()` and `pitchToSwaraSymbol()`. Keep the file as
  a plain **swara vocabulary**: the symbol list, the full-name list, and one new
  helper `bool isSwaraToken(String)` used to recognise swara text. Rename the
  class to `SwaraNotation` to make clear it no longer converts anything.
- `lib/services/chord_transposer.dart` — drop the `mode:` parameter from
  `transposeLyrics()` and `chordsUsed()` and the `_swara` field.
  No further change is needed for Indian songs: `_transposeToken()` already
  returns `null` for anything that is not a Western note letter, so a `[S]` or
  `[Ma]` marker is passed through untouched by a transpose. Swaras are relative
  to Sa already, so this is the correct behaviour.
- `lib/providers/performance_provider.dart` — remove the `swaraDisplayMode`
  field, `cycleSwaraDisplayMode()` and `setSwaraDisplayMode()`.
- `lib/screens/song_performance_screen.dart` — remove the "Notation System" menu
  item and its radio dialog (`_notationSystemItem`, `_showNotationSystemDialog`),
  and the `mode:` argument at line 722.
- `lib/widgets/harmonium_chord_diagram.dart` — it holds a
  `SwaraNotationService` field; point it at the renamed class or drop the field
  if it is unused after A.

**No notation picker is left anywhere in the app.** I checked: the only notation
UI that exists is the "Notation System" item in the song-page menu. There is no
default-notation option in Settings, General Settings or `app_config.json`, and
nothing is saved to `shared_preferences`. Removing the menu item and the
`swaraDisplayMode` field (with its `SwaraDisplayMode.western` default) takes the
whole feature out — the picker, the default, and the stored state.

### B. Parse directives out of the sheet

- `lib/services/chord_sheet_parser.dart` — recognise a line that is only
  `{name: value}` as a **directive**. Add a small `ParsedSheet` result holding
  `Map<String, String> directives` and `List<ChordLine> lines`, exposed by a new
  `parseSheet()`. Existing `parse()` keeps its signature but now **skips**
  directive lines, so every current caller (PDF export, import preview) stops
  printing them with no other change.
  Unknown directive names are kept in the map and simply not displayed —
  never an error (CLAUDE.md hard rule 4).

### C. Mark and draw swaram lines properly

- `lib/services/chord_sheet_parser.dart` — add `ChordLineKind { lyric, swaram }`
  on `ChordLine`. A line is `swaram` when, after removing separators
  (`-`, `|`, `,`, spaces), every token is a swara token per
  `SwaraNotation.isSwaraToken`. The widget therefore never has to know swara
  syntax, which keeps the layer boundary in architecture §4.
- `lib/widgets/chord_sheet_view.dart` — draw a `swaram` line in the monospace
  chord font, in the primary colour, inside a horizontally scrollable row so a
  long phrase never wraps mid-line.
- `lib/services/pdf_export_service.dart` — mirror both behaviours: print the
  raga/tala directives as a small header under the title, and draw swaram lines
  in the monospace font.

### D. Show raga and tala as a header, not as lyrics

- `lib/screens/song_performance_screen.dart` — read `parseSheet()` and, when the
  song has `raga` or `tala`, show one small subtitle row above the sheet
  (e.g. `Raga Yamunakalyani · Tala Adi`) in the same muted style as the existing
  "Auto-scroll · Key E · 68 BPM" row.
- For a song that has a `{raga}` directive, that same row shows `Sa = E` in place
  of `Key E`, because in Indian notation the key names the tonic, not a chord.

### E. Rewrite the seeded Carnatic songs in real Indian notation

- `lib/data/app_database.dart` — the three classical songs are currently
  hard-coded in **four** near-identical blocks (lines ~312, ~388, ~474, ~566).
  Extract them into one private `const _classicalSeedSongs` list and have all
  four call sites use it, so they cannot drift apart again.
- Rewrite their bodies so the markers hold swaras, not chords:
  `[S]Krishna nee be[M]gane baro`, and keep the `{raga}` / `{tala}` lines and the
  swaram block (which now renders as a proper monospace grid).
- **Existing installs are fixed too.** The database is at schema v6 and already
  has two migrations that rewrite seeded song text the same way —
  `_updateSwaraNotationWithHyphens` (v5) and `_updateSwaraNotationWithFullNames`
  (v6), at [app_database.dart:99](../lib/data/app_database.dart#L99). I will follow
  that precedent: bump to v7 and add
  `_rewriteClassicalSongsInSwaraNotation()`, which matches the three songs by
  title and replaces their lyrics with the new swara text. A song the user has
  edited or renamed is left alone, so no one's own work is overwritten.

### F. Tempo-Auto must follow the tala, not assume 4/4

Auto-scroll itself is notation-blind — it is geometry and time. Manual mode
(40 px/s × multiplier) needs no change. **Tempo-Auto is wrong for classical
songs**, because the beat count per measure is hard-coded to 4
([auto_scroll_calculator.dart:17](../lib/services/auto_scroll_calculator.dart#L17)):

```
duration = measures × beatsPerMeasure × 60 / bpm
speed    = contentExtent / duration
```

An Adi tala song has 8 aksharas per cycle, not 4, so today it scrolls twice as
fast as it should and runs off the end of the song. `tempoDuration()` already
accepts a `beatsPerMeasure` parameter — nothing ever passes it.

- `lib/services/swara_notation_service.dart` — add a `talaBeats` lookup, since
  this is Indian-music vocabulary and belongs beside the swara vocabulary:

  | Carnatic | Beats | Hindustani | Beats |
  |----------|-------|------------|-------|
  | Adi | 8 | Teental | 16 |
  | Rupaka | 6 | Ektal | 12 |
  | Misra Chapu | 7 | Jhaptal | 10 |
  | Khanda Chapu | 5 | Keherwa | 8 |
  | Ata | 14 | Dadra | 6 |
  | Jhampa | 10 | Rupak | 7 |

  Matching is case-insensitive and ignores a trailing "tala"/"talam", so
  `{tala: Adi}`, `{tala: adi talam}` and `{tala: ADI}` all give 8. An unknown or
  missing tala falls back to 4 — never an error (hard rule 4).

- `lib/providers/auto_scroll_provider.dart` — add `beatsPerMeasure` to
  `AutoScrollSettings` (default 4) and to `loadForSong()`. Putting it in the
  state rather than passing it down is deliberate: four widgets call
  `tempoDuration()` — [song_performance_screen.dart:658](../lib/screens/song_performance_screen.dart#L658),
  [auto_scroll_controls.dart:40](../lib/widgets/auto_scroll_controls.dart#L40),
  [performance_controls.dart:97](../lib/widgets/performance_controls.dart#L97) and
  [stage_hud.dart:56](../lib/widgets/stage_hud.dart#L56) — and they must all agree,
  or the read-out will disagree with the real scroll speed.
- Those four call sites pass `beatsPerMeasure: settings.beatsPerMeasure`.
- `lib/screens/song_performance_screen.dart` — when loading a song, read the
  `{tala}` directive from `parseSheet()` (section B) and hand its beat count to
  `loadForSong()`.
- This is **not stored in the database**. The tala comes from the song text, so
  editing `{tala: Adi}` to `{tala: Rupaka}` re-times the scroll straight away.

Effect on the plan's other changes: hiding the directive lines and un-wrapping
the swaram lines makes the sheet shorter, so `contentExtent` shrinks. That needs
no fix — the extent is measured after layout and reported back
([song_performance_screen.dart:690](../lib/screens/song_performance_screen.dart#L690)),
so Tempo-Auto simply scrolls slower and still ends at the song end.

### G. Tests

- `test/services/swara_notation_service_test.dart` — drop the conversion tests,
  add tests for `isSwaraToken` and for `talaBeats` (known tala, case and
  "talam" suffix, unknown tala falls back to 4).
- `test/services/auto_scroll_calculator_test.dart` — add an Adi tala case:
  8 beats per measure gives twice the duration of the 4/4 default, and the
  "ends exactly at song end" check still holds.
- `test/services/chord_sheet_parser_test.dart` — directive lines are extracted
  and not rendered; swaram lines are detected; a normal lyric line with a stray
  `{` stays plain text.
- `test/services/chord_transposer_test.dart` — remove `mode:` usages; add a test
  that a `[S]` marker survives a transpose unchanged.
- `test/widgets/chord_sheet_view_test.dart` — a swaram line renders in the
  monospace style and does not wrap.
- `test/services/pdf_export_service_test.dart` — directives are not printed as
  lyric text.
- Run `flutter analyze` (must be zero) and `flutter test`.

---

## Files to change

| File | Change |
|------|--------|
| `lib/services/swara_notation_service.dart` | Strip conversion; keep vocabulary + `isSwaraToken` + `talaBeats` |
| `lib/providers/auto_scroll_provider.dart` | `beatsPerMeasure` in state and `loadForSong()` |
| `lib/widgets/auto_scroll_controls.dart` | Pass `beatsPerMeasure` to `tempoDuration()` |
| `lib/widgets/performance_controls.dart` | Pass `beatsPerMeasure` to `tempoDuration()` |
| `lib/widgets/stage_hud.dart` | Pass `beatsPerMeasure` to `tempoDuration()` |
| `test/services/auto_scroll_calculator_test.dart` | Adi tala timing test |
| `lib/services/chord_transposer.dart` | Remove swara mode parameters |
| `lib/services/chord_sheet_parser.dart` | Directives + `ChordLineKind.swaram` |
| `lib/widgets/chord_sheet_view.dart` | Monospace non-wrapping swaram lines |
| `lib/services/pdf_export_service.dart` | Same directive + swaram handling in PDF |
| `lib/providers/performance_provider.dart` | Remove `swaraDisplayMode` state |
| `lib/screens/song_performance_screen.dart` | Remove Notation System menu; add raga/tala header |
| `lib/widgets/harmonium_chord_diagram.dart` | Follow the renamed class |
| `lib/data/app_database.dart` | One shared classical seed list, written in swaras |
| `test/services/swara_notation_service_test.dart` | Rewrite for vocabulary only |
| `test/services/chord_sheet_parser_test.dart` | New directive + swaram tests |
| `test/services/chord_transposer_test.dart` | Drop mode; swara marker passthrough |
| `test/widgets/chord_sheet_view_test.dart` | Swaram rendering test |
| `test/services/pdf_export_service_test.dart` | Directive handling test |

## What this does not do

- No new database column for "song notation type" — the `{raga}` directive is
  enough to tell an Indian song from a Western one.
- No new column for the tala either; it is read from the song text (see F).
- Nothing is added to the Western side; Western songs behave exactly as today.
