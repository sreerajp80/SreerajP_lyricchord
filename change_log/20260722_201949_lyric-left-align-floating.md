# Change log — fix lyrics floating in the middle of the performance screen

Implements plan
[plans/20260722_201949_lyric-left-align-floating.md](../plans/20260722_131949_lyric-left-align-floating.md).

## What was wrong

On the song performance screen, short lyric lines looked centred (they floated
in the middle) instead of being left-aligned.

The chord sheet renderer was already left-aligned. The real cause was the outer
`Column` in `SongPerformanceScreen.build`: it had no `crossAxisAlignment`, so it
defaulted to `center`. Its child is a vertical `SingleChildScrollView`, which
shrink-wraps its width to its content. For a short song that block is narrow, so
the centring `Column` placed it in the middle of the screen.

## What changed

- `lib/screens/song_performance_screen.dart`
  - Added `crossAxisAlignment: CrossAxisAlignment.stretch` to the outer `Column`
    in the `data:` branch of `build`, with a comment explaining why. This forces
    the scroll view to fill the full width, so `ChordSheetView` (already
    `CrossAxisAlignment.start`) lays lyrics from the 16 px left padding edge.
    `PerformanceControls` was already full-width, so it is unchanged in look.

- `test/screens/song_performance_screen_test.dart`
  - Added the `models/song_note.dart` import.
  - Added a regression test: pumps the real `SongPerformanceScreen` with a short
    single-line lyric on a 500 px-wide surface and asserts the lyric's left edge
    is under 24 px (i.e. at the left padding, not near the centre). Before the
    fix this sat far to the right.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 220 tests pass, including the new regression test.
- Diagnosis was confirmed by measuring the real widget tree: the lyric's left
  edge moved from ~90 px (centred) to ~16 px (left) after the fix.
