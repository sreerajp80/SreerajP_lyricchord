# Change Log: Stabilize Lyrics Vertical Scroll & Pinch Zoom

**Date:** 2026-07-25
**Plan:** [plans/20260725_190719_stabilize-lyrics-scroll-and-pinch-zoom.md](../plans/20260725_190719_stabilize-lyrics-scroll-and-pinch-zoom.md)

## Changes Implemented

1. **Gesture Disambiguation in Song Performance Screen**:
   - Updated `_SongPerformanceScreenState` in `lib/screens/song_performance_screen.dart` with pointer tracking fields (`_pointersDown`, `_allowPageSwipe`, `_gestureLocked`, `_startPosition`).
   - Wrapped `PageView.builder` in a `Listener` to catch pointer events.
   - Set `PageView` physics dynamically: locked to `NeverScrollableScrollPhysics()` during multi-finger pinch gestures (`_pointersDown >= 2`) or vertical lyric scrolling (`dy >= dx`), and restored to `PageScrollPhysics()` when all pointers release.

2. **Automated Testing**:
   - Added widget tests in `test/screens/song_performance_screen_test.dart` for vertical drag over lyrics and two-finger pinch zoom on a multi-song pager.
   - Ran `dart format .` and `flutter analyze` (zero warnings/errors).
   - Verified that all unit and widget tests pass.
