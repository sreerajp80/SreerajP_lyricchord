# Add Gestures Help to Lyrics Display Screen and Full Screen HUD

**Status:** completed

## Problem
The app supports several touch gestures on both the normal lyrics display screen and in full screen (Stage Mode):
- Double-tap upper half: increase scroll speed (Manual) or increase bars (Tempo)
- Double-tap lower half: decrease scroll speed (Manual) or decrease bars (Tempo)
- Two-finger tap: play or pause auto-scroll
- One-finger drag: scroll the sheet manually (auto-scroll pauses and resumes smoothly)
- Pinch: adjust lyrics font size
- Full screen only: single tap to toggle controls HUD, and back gesture to leave full screen

While these gestures are described in `Settings > Help` and in a one-time overlay on the first visit to Stage Mode (`StageHelpOverlay`), there is currently no direct way for a user to:
1. Open a gestures help guide on-demand from the standard Lyrics Display Screen.
2. Re-open the gestures help guide from Full Screen (Stage Mode) once the first-time overlay has been dismissed.

## Proposed Changes

### [lib/widgets/gestures_help_dialog.dart](lib/widgets/gestures_help_dialog.dart) [NEW]
- Create a new dialog widget `GesturesHelpDialog` and helper function `showGesturesHelpDialog(BuildContext context)`.
- List all sheet gestures clearly with icons and plain English descriptions:
  - **Double-tap top**: Faster (Manual) / More bars (Tempo)
  - **Double-tap bottom**: Slower (Manual) / Fewer bars (Tempo)
  - **Two-finger tap**: Play or pause auto-scroll
  - **Pinch**: Change font size
  - **Drag**: Move sheet by hand (scroll pauses and resumes)
  - **Full screen**: Single tap toggles controls bar; Back leaves full screen
- Provide an action button to open the full Help Center topic (`/settings/help/auto-scroll`) and a "Close" button.

### [lib/screens/song_performance_screen.dart](lib/screens/song_performance_screen.dart)
- In `_OverflowMenu` (the 3-dot AppBar menu on the lyrics display screen), add a menu item for **Gestures help** that calls `showGesturesHelpDialog(context)`.
- In `_SongPageState`, maintain state `bool _showStageHelp = false;` so that full-screen users can trigger the overlay on-demand.
- Pass an `onHelpPressed` callback to `StageHud`.
- Show `StageHelpOverlay` if `!helpSeen || _showStageHelp`, and reset `_showStageHelp = false` in `onDismiss`.

### [lib/widgets/stage_hud.dart](lib/widgets/stage_hud.dart)
- Add an optional `VoidCallback? onHelpPressed` parameter.
- Add an `IconButton` with `Icons.help_outline` and tooltip `'Gestures help'` to the scrollable row of HUD controls (next to lock/quiet/drone buttons).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero warnings or lint errors.
- Run `flutter test` to ensure all existing tests pass.
- Add a widget test in `test/widgets/gestures_help_dialog_test.dart` to verify that `GesturesHelpDialog` renders all gesture rows and can be dismissed.

### Manual Verification
1. Open any song in normal performance mode.
2. Tap the 3-dot menu (`...`) at the top right and select "Gestures help".
3. Verify the gestures dialog opens with all gesture explanations and buttons.
4. Tap the full screen icon to enter Stage Mode.
5. Tap on the screen to show the Stage HUD.
6. Tap the new `?` (Help) button in the Stage HUD.
7. Verify the `StageHelpOverlay` appears on top of full screen, and tapping anywhere dismisses it smoothly.
