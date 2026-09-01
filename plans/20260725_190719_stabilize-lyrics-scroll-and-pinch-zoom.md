# Plan: Stabilize Lyrics Vertical Scroll & Pinch Zoom

**Status:** completed

## Problem
1. When scrolling down/up long lyrics on the song performance screen, slight horizontal finger movement caused the parent `PageView` to start swiping left/right to adjacent songs, making the view jumpy and unstable.
2. When performing a two-finger pinch gesture to zoom lyric text, finger displacement on the X-axis triggered horizontal `PageView` page swiping, causing the page to slide sideways during pinch zooming.

## Fix Strategy
1. Wrap `PageView.builder` in `SongPerformanceScreen` with a raw `Listener` to monitor pointer touch events (`_pointersDown`, touch start position, drag deltas).
2. **Pinch Zoom Isolation**: When 2 or more fingers are down (`_pointersDown >= 2`), dynamically set `PageView` physics to `NeverScrollableScrollPhysics()` so multi-touch pinch gestures never cause horizontal page sliding.
3. **Vertical Scroll Isolation**: When 1 finger drags and the movement exceeds 8 logical pixels with vertical delta larger than or equal to horizontal delta (`dy >= dx`), lock `PageView` physics to `NeverScrollableScrollPhysics()` for the rest of that drag session.
4. **Horizontal Swipe**: Allow standard horizontal page swiping when the user explicitly swipes sideways (`dx > dy`).
5. **Pointer Reset**: Re-enable `PageScrollPhysics()` when all pointers lift off (`_pointersDown == 0`).

## Files Modified
- `lib/screens/song_performance_screen.dart`
- `test/screens/song_performance_screen_test.dart`
