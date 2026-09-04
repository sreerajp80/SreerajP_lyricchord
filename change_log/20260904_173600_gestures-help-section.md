# Add Gestures Help to Lyrics Display Screen and Full Screen HUD

**Plan reference:** [plans/20260904_172600_gestures-help-section.md](../plans/20260904_172600_gestures-help-section.md)

## Summary of Changes

Added on-demand Gestures Help for performers across both the standard Lyrics Display Screen and in Full Screen (Stage Mode):

1. **Gestures & Shortcuts Dialog (`lib/widgets/gestures_help_dialog.dart`)**:
   - Created `GesturesHelpDialog` and helper `showGesturesHelpDialog(BuildContext context)` to present sheet touch gestures in a clean, themed dialog.
   - Clarified all gestures: double-tap upper half (faster / +4 bars), double-tap lower half (slower / -4 bars), two-finger tap (play/pause), one-finger drag (manual scroll with smooth pause & resume), pinch (font size), and full screen shortcuts.
   - Added direct button to navigate to `/settings/help/auto-scroll` in the Help Center, and a dismiss action button.

2. **Full Screen HUD Help Trigger (`lib/widgets/stage_hud.dart` & `lib/screens/song_performance_screen.dart`)**:
   - Added an optional `onHelpPressed` callback and `IconButton` with `Icons.help_outline` (tooltip: 'Gestures help') to the Stage HUD toolbar.
   - In `_SongPageState`, wired `onHelpPressed` to toggle `_showStageHelp = true`, allowing performers in full screen to re-open the high-contrast `StageHelpOverlay` on demand anytime.

3. **Lyrics Screen Overflow Menu (`lib/screens/song_performance_screen.dart`)**:
   - Added a "Gestures help" menu item to `_OverflowMenu` in the AppBar, making the gestures guide easily accessible directly from any song performance view without digging into settings.

4. **Tests**:
   - Added `test/widgets/gestures_help_dialog_test.dart` verifying all gesture labels and dialog open/close actions.
   - Updated `test/widgets/stage_hud_test.dart` to verify that tapping the new Gestures Help button invokes the callback.

## Verification

- `flutter analyze` completed with zero warnings or errors.
- `flutter test` passed all 906 tests in the test suite.
