# Store the song tradition properly (raga, tala, tradition)

**Status:** completed

## The issue

The app already keeps Western and Indian songs apart, and that part works. But
the information it uses to tell them apart is not stored anywhere. It is read
out of the lyrics text every time it is needed.

Four problems follow from that.

### 1. Raga and tala are not columns

The `song_notes` table
([lib/data/app_database.dart:15-36](../lib/data/app_database.dart)) has `title`,
`artist`, `lyrics`, `key`, `bpm`, `favorite`, `timestamp`, `scrollSpeed` and
`scrollMeasures`. There is no `raga`, no `tala`, no `tradition`.

The raga and tala live as `{raga: …}` and `{tala: …}` header lines inside the
`lyrics` text. Every place that needs them re-parses the whole song
(`ChordSheetParser.parseSheet`). The song editor has no field for them — the
user has to know the curly-brace syntax and type it into the lyrics box.

### 2. A typo silently turns an Indian song Western

`ParsedSheet.isIndianNotation` is
`raga != null` ([lib/services/chord_sheet_parser.dart:113](../lib/services/chord_sheet_parser.dart)).

So writing `{ragam: Kalyani}` or `{raaga: Kalyani}` makes `raga` null. The song
becomes Western. Then
[lib/services/chord_transposer.dart:111](../lib/services/chord_transposer.dart)
no longer skips it, and a transpose will shift the swara markers `[Sa]` and
`[Ma]` as if they were the chord letters Sa and Ma. The song text is rewritten
and the notation is wrong. There is no warning and no undo.

This is the most serious of the four. It silently damages the user's data.

### 3. The same song can read differently on two phones

`PitchNamingService.detect`
([lib/services/pitch_naming_service.dart:142-163](../lib/services/pitch_naming_service.dart))
decides Carnatic vs Hindustani from the **tala**, not the raga. That rule is
correct and should stay — tala names split cleanly between the two traditions,
raga names do not.

But when a song names a raga and no tala, or a tala the app does not know, the
code falls back to the user's global "Pitch naming" setting. So one song is
Carnatic on my phone and Hindustani on yours. Tradition belongs to the song, not
to the app settings.

### 4. Nothing checks that raga and tala agree

A song can name a Carnatic raga with a Hindustani tala. Nothing notices.

### Why fix this before the learning screen

The melody/learning feature will hang off the tradition field — Indian songs get
a swaram grid, Western songs get something else. Changing where tradition is
stored after users have their own songs means a data migration on real data.
Cheap now, expensive later.

## The plan

### Storage

Add three columns to `song_notes` at schema version 9:

| Column | Type | Default | Meaning |
|---|---|---|---|
| `raga` | text | `''` | Raga name, empty for Western songs |
| `tala` | text | `''` | Tala name, empty for Western songs |
| `tradition` | text | `''` | `western`, `carnatic`, `hindustani`, or empty = not yet set |

`tradition` is stored, not computed. It is the single source of truth once set.
`raga` and `tala` stay as separate fields because the learning screen needs the
tala's beat count, and the user should be able to see and edit them.

### Migration (version 8 → 9)

For every existing song, run the current detection once and write the answer in:

1. Parse the lyrics with `ChordSheetParser.parseSheet`.
2. Copy `directives['raga']` and `directives['tala']` into the new columns.
3. Set `tradition` from `PitchNamingService.detect(raga:, tala:)`, with
   `PitchTradition.carnatic` as the fallback so the migration never depends on a
   user setting.
4. Leave the lyrics text untouched. The `{raga:}` and `{tala:}` lines stay where
   they are; the parser keeps hiding them from the sheet.

Nothing visible changes for the user after the upgrade. Every song keeps reading
exactly as it did.

### Reading

`isIndianNotation` becomes a property of the song, not of the parsed text:

- `SongNote.isIndian` → `tradition != PitchTradition.western`.
- `ParsedSheet.isIndianNotation` stays, but is only used for imported text that
  has no song row yet.

Update the three call sites to use the stored value:

- `ChordTransposer.transposeLyrics` and `chordsUsed` — take the tradition as an
  argument instead of re-parsing.
- `PdfExportService` — same.

### Writing

- The song editor gets a **Tradition** picker (Western / Carnatic / Hindustani)
  and, when it is not Western, a **Raga** and a **Tala** text field. The Key
  field hides for Indian songs, matching what the performance screen and the PDF
  already do.
- When the user picks a raga and tala whose traditions disagree, show a warning
  under the field. Warn only — do not block. The user may know better.
- Saving keeps the `{raga:}` / `{tala:}` lines in the lyrics text in step with
  the columns, so ChordPro export and AirQR transfer still carry them.

### Import and transfer

- `ChordProService.parse` fills the new fields from the directives it already
  reads, then sets `tradition` the same way the migration does.
- `ChordProService.format` writes `{raga:}` and `{tala:}` for Indian songs, and
  skips the `{key:}` line for them — right now it writes `{key: …}` for every
  song ([lib/services/chord_pro_service.dart:118](../lib/services/chord_pro_service.dart)),
  which is meaningless on an Indian sheet and is the same mistake the PDF export
  already avoids.
- AirQR sends songs as ChordPro text, so it inherits the fix with no separate
  change. To be confirmed while implementing.

## Files to change

**Data**
- `lib/data/app_database.dart` — three columns, schema version 9, migration.
- `lib/data/app_database.g.dart` — regenerated, never hand-edited.

**Models**
- `lib/models/song_note.dart` — `raga`, `tala`, `tradition` fields, `copyWith`,
  `isIndian` getter.

**Services**
- `lib/services/chord_transposer.dart` — take tradition as an argument.
- `lib/services/pdf_export_service.dart` — use the stored tradition.
- `lib/services/chord_pro_service.dart` — read and write raga/tala, skip `{key:}`
  for Indian songs.
- `lib/services/pitch_naming_service.dart` — add a `traditionsAgree(raga, tala)`
  check for the editor warning.

**Repository / providers**
- `lib/repositories/song_repository.dart` — map the new columns both ways.
- `lib/providers/song_editor_provider.dart` — hold and validate the new fields.

**Screens**
- `lib/screens/song_editor_screen.dart` — tradition picker, raga and tala fields,
  hide Key for Indian songs.
- `lib/screens/song_performance_screen.dart` — read the stored tradition.

**Docs**
- `docs/architecture.md` — the new columns and the tradition rule.
- `docs/features.md` — the editor fields.

## Tests

New or updated:

- `test/data/` — migration 8 → 9: a Western song, a Carnatic song (raga + Adi),
  a Hindustani song (raga + Keherwa), and a song with a raga but no tala all end
  up with the right `tradition`.
- `test/repositories/song_repository_test.dart` — new columns round-trip.
- `test/services/chord_transposer_test.dart` — an Indian song is left alone based
  on the stored field, and a song whose `{raga:}` line is misspelled is **still**
  left alone because the column says Indian. This is the bug from problem 2.
- `test/services/chord_pro_service_test.dart` — raga/tala round-trip; no `{key:}`
  line for an Indian song.
- `test/services/pitch_naming_service_test.dart` — `traditionsAgree`.
- `test/screens/song_editor_screen_test.dart` — the picker shows and hides the
  right fields; the mismatch warning appears and does not block saving.

## Out of scope

- Melody notation and the learning screen. This plan only prepares the ground.
- A raga name lookup table. Not needed — tala already decides the tradition.
- Any change to how swaras are parsed or drawn.

## Risks

- **Schema migration on real user data.** Mitigated by the migration only adding
  columns and never touching lyrics text, plus tests for each case.
- **Regenerating drift code** will touch `app_database.g.dart` widely. Expected;
  run `build_runner` and do not hand-edit.
- The editor gains fields, which makes it busier. The raga/tala fields only show
  when the tradition is not Western, so a Western user sees no change.
