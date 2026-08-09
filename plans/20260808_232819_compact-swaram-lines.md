# Make swaram lines smaller and tighter

**Status:** completed

## What the user saw

In "Raghupati Raghava Raja Ram", the `Swaram:` block shows two long rows that run
off the right edge of the screen. The user asks (a) why there are two rows and
(b) whether the swaram can be drawn smaller and tighter.

## What is actually happening

1. **Two rows is the data, not wrapping.** The seed song text has two swaram
   lines — two cycles of Keherwa, 8 beats each — in
   `lib/data/app_database.dart:447-449`. Each swaram line is drawn as one
   unbroken row that never wraps and scrolls sideways
   (`lib/widgets/chord_sheet_view.dart:112-125`). So the two rows are two written
   lines, not one line broken in half.

2. **The row is wide because the style is big.** The swaram style uses the full
   lyric font size plus `letterSpacing: 1.2`
   (`lib/widgets/chord_sheet_view.dart:72-78`), and the text itself uses the long
   swara names (`Sa - Sa - Pa - Pa -`). Together they push the row past the screen
   width.

3. **The `S M S` above the words is a different thing from the swaram block.**
   The `[S]`, `[M]`, `[P]` marks inside the lyric lines
   (`lib/data/app_database.dart:441-445`) are typed into the lyric text and are
   drawn above the words. The `Swaram:` block is a separate phrase typed further
   down. The app never derives one from the other — `swara_notation_service.dart`
   only recognises swara text, it does not convert
   (`lib/services/swara_notation_service.dart:5-9`). The two were written
   separately in the seed data and were never matched to each other, which is why
   the lyric marks read `S … M … S` while the swaram phrase starts
   `Sa - Sa - Pa - Pa -`. That is a content problem in the seed song, not a
   rendering bug.

## Files to change

- `lib/widgets/chord_sheet_view.dart` — smaller, tighter swaram style.
- `test/widgets/chord_sheet_view_test.dart` — update/extend the style test.

## The fix

In `chord_sheet_view.dart`, change the swaram style so the beat grid still reads
clearly but takes far less width and height:

- `fontSize`: `fontSize` → `fontSize * 0.8` (same size as the chord badges, so
  the sheet keeps one visual scale).
- `letterSpacing`: `1.2` → `0.0` (the ` - ` beat dashes already separate the
  swaras; the extra tracking only added width).
- `height`: `1.4` → `1.15` (less vertical gap between the two swaram rows).

Nothing else changes: the row still never wraps and still scrolls sideways, so
the beat grid stays intact.

## Out of scope (ask before doing)

Aligning the seed swaram phrase in "Raghupati Raghava Raja Ram" with the `[S]`
`[M]` `[P]` marks on its lyric lines. That is a music-content decision and needs
the user to say which of the two is correct.

## Checks after the change

- `flutter analyze` clean.
- `flutter test` passes.
