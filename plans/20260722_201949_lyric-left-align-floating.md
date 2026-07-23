# Fix lyrics floating in the middle of the performance screen

**Status:** completed

## The issue

On the song performance screen, short lyric lines look like they are centered
on the screen (they float in the middle), even though the chord sheet is meant
to be left-aligned.

The chord sheet renderer (`ChordSheetView`) is already left-aligned and is not
the problem. The real cause is one level up:

- The outer `Column` in the performance screen build has **no**
  `crossAxisAlignment`, so it defaults to `CrossAxisAlignment.center`.
- Its child is an `Expanded` holding a vertical `SingleChildScrollView`.
- A vertical scroll view shrink-wraps its **width** to its content. For a short
  song this content is narrow.
- The centering `Column` then places that narrow block in the middle of the
  screen.

Measured proof (400 px-wide test surface, line `പക്ഷേ[C] കാരി`):
`SingleChildScrollView` sits at left = 92.8 with width ~214 instead of filling
the screen; the lyric therefore starts at x ≈ 109 instead of the 16 px left
padding.

`PerformanceControls` (the header) already fills the full width, because its
controls row is full-width, so it does not float — only the scroll view does.

## Files to change

- `lib/screens/song_performance_screen.dart` — the outer `Column` in the
  `data:` branch of `build` (around line 390).

## The fix

Add `crossAxisAlignment: CrossAxisAlignment.stretch` to that outer `Column`.

This gives both children a tight full-width constraint. The scroll view then
fills the whole width, and `ChordSheetView` (already `CrossAxisAlignment.start`)
lays the lyrics from the left padding edge. Short lines will hug the left,
matching the intended left alignment. `PerformanceControls` is unaffected
because it already occupies the full width.

## Testing

- Add a widget test that pumps the real `SongPerformanceScreen` with a short
  single-line lyric and asserts the lyric text's left edge is at the left
  padding (≈16 px), not near the screen centre. This guards against the
  regression returning.
- Run `flutter analyze` (must be clean) and `flutter test` (all pass).
- Verify on the attached moto g54 device that a short line starts at the left.

## Risk

Low. The change is one line and only affects horizontal sizing of the two
children, both of which already render at full width in practice.
