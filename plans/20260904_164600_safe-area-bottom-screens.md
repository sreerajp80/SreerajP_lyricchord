# Plan: Add SafeArea Bottom Protection Across All Screens

**Status:** completed

**Date:** 2026-09-04

## 1. What the issue is

On devices with system navigation bars (such as the Android 3-button navigation bar `< O |||` or gesture navigation pill), edge-to-edge rendering causes the system navigation bar to sit directly on top of app content at the bottom of the screen.

In the Help screen (`lib/screens/help/help_screen.dart`), the list view content reaches the very bottom of the screen. When scrolled down to the end, the bottom-most item ("Themes, fonts & text size") is partially cut off and overlapped by the Android navigation bar.

A comprehensive check across all screens revealed that multiple screens lack bottom safe area insets on their scroll views, panels, or bodies, causing the bottom items, cards, buttons, or list tiles to get clipped or obscured by the system navigation bar:
- Help Hub (`help_screen.dart`)
- Help Topic Detail (`help_detail_screen.dart`)
- Settings Hub (`settings_screen.dart`)
- General Settings (`general_settings_screen.dart`)
- Chord Settings (`chord_settings_screen.dart`)
- Font Settings (`font_settings_screen.dart`)
- Import Settings (`import_settings_screen.dart`)
- Metronome Settings (`metronome_settings_screen.dart`)
- Pitch Pipe & Shruti Box Settings (`pitch_drone_settings_screen.dart`)
- Auto-scroll Settings (`scroll_settings_screen.dart`)
- Theme Settings (`theme_settings_screen.dart`)
- About Screen (`about_screen.dart`)
- AirQR Receiver Screen (`air_qr_receiver_screen.dart`)
- AirQR Transmitter Screen (`air_qr_transmitter_screen.dart`)
- Import & Export Screen (`import_export_screen.dart`)
- Song Editor Screen (`song_editor_screen.dart`)
- Song Performance Screen (`song_performance_screen.dart`)
- Carnatic Notation Sheet (`carnatic_notation_sheet.dart`)

Screens that already have proper bottom padding or safe area handling:
- `song_list_screen.dart`: List has `padding: EdgeInsets.only(bottom: 88)` for FAB and navigation bar.
- `setlist_list_screen.dart`: List has `padding: EdgeInsets.fromLTRB(16, 12, 16, 88)`.
- `setlist_detail_screen.dart`: Reorderable list has `padding: EdgeInsets.only(bottom: 88)`.
- `import_preview_screen.dart`: Bottom bar uses `bottomNavigationBar: SafeArea(...)`.
- `stage_hud.dart`: Floating stage HUD already wraps its container in `SafeArea(top: false, ...)`.
- `transpose_sheet.dart`, `metronome_tempo_sheet.dart`, `melody_keypad_sheet.dart`, `pitch_drone_controls.dart`: Already wrapped in `SafeArea`.

## 2. Files to be changed

| File | Change |
|---|---|
| `lib/screens/help/help_screen.dart` | Wrap body in `SafeArea` so the cards stop above the navigation bar |
| `lib/screens/help/help_detail_screen.dart` | Wrap body in `SafeArea` so the bottom text and bullets are visible |
| `lib/screens/settings_screen.dart` | Wrap body in `SafeArea` so the About card does not overlap the navigation bar |
| `lib/screens/general_settings_screen.dart` | Wrap body in `SafeArea` so the bottom card does not overlap the navigation bar |
| `lib/screens/chord_settings_screen.dart` | Wrap body in `SafeArea` so the bottom list tile and delete icon are clear of the navigation bar |
| `lib/screens/font_settings_screen.dart` | Wrap body in `SafeArea` so the last font choice is clear of the navigation bar |
| `lib/screens/import_settings_screen.dart` | Wrap body in `SafeArea` so the strategy cards stay above the navigation bar |
| `lib/screens/metronome_settings_screen.dart` | Wrap body in `SafeArea` so the "Test the sound" tile is visible |
| `lib/screens/pitch_drone_settings_screen.dart` | Wrap body in `SafeArea` so the bottom test buttons are easy to tap |
| `lib/screens/scroll_settings_screen.dart` | Wrap body in `SafeArea` so card and reset button are protected on smaller screens |
| `lib/screens/theme_settings_screen.dart` | Wrap body in `SafeArea` so all radio options are above the navigation bar |
| `lib/screens/about_screen.dart` | Wrap body in `SafeArea` so license tile is visible |
| `lib/screens/air_qr_receiver_screen.dart` | Wrap the bottom HUD matrix panel in `SafeArea(top: false, ...)` |
| `lib/screens/air_qr_transmitter_screen.dart` | Wrap body in `SafeArea` so the helper text at bottom is visible |
| `lib/screens/import_export_screen.dart` | Wrap body in `SafeArea` so all export tiles are above the navigation bar |
| `lib/screens/song_editor_screen.dart` | Wrap body in `SafeArea(top: false, ...)` so the lyrics textfield does not go behind the navigation bar |
| `lib/screens/song_performance_screen.dart` | In `_shell`, wrap body in `SafeArea(top: false, ...)` when not in stage mode |
| `lib/widgets/carnatic_notation_sheet.dart` | Wrap the sheet in `SafeArea(top: false, ...)` |

## 3. Detailed plan for the fix

1. Update `lib/screens/help/help_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

2. Update `lib/screens/help/help_detail_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

3. Update `lib/screens/settings_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

4. Update `lib/screens/general_settings_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

5. Update `lib/screens/chord_settings_screen.dart`:
   - Wrap the `Column` in `SafeArea(child: Column(...))`.

6. Update `lib/screens/font_settings_screen.dart`:
   - Wrap `RadioGroup` in `SafeArea(child: RadioGroup(...))`.

7. Update `lib/screens/import_settings_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

8. Update `lib/screens/metronome_settings_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

9. Update `lib/screens/pitch_drone_settings_screen.dart`:
   - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

10. Update `lib/screens/scroll_settings_screen.dart`:
    - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

11. Update `lib/screens/theme_settings_screen.dart`:
    - Wrap `RadioGroup` in `SafeArea(child: RadioGroup(...))`.

12. Update `lib/screens/about_screen.dart`:
    - Wrap the body in `SafeArea(child: ...)`.

13. Update `lib/screens/air_qr_receiver_screen.dart`:
    - Wrap the bottom panel in `SafeArea(top: false, ...)` so it is offset above the system navigation bar.

14. Update `lib/screens/air_qr_transmitter_screen.dart`:
    - Wrap `SingleChildScrollView` in `SafeArea(child: SingleChildScrollView(...))`.

15. Update `lib/screens/import_export_screen.dart`:
    - Wrap the `ListView` in `SafeArea(child: ListView(...))`.

16. Update `lib/screens/song_editor_screen.dart`:
    - Wrap the body in `SafeArea(top: false, child: ...)`.

17. Update `lib/screens/song_performance_screen.dart`:
    - In `_shell`, wrap body in `SafeArea(top: false, child: body)` when `!stageMode`.

18. Update `lib/widgets/carnatic_notation_sheet.dart`:
    - Wrap sheet content in `SafeArea(top: false, child: ...)`.

## 4. Testing & Verification

1. Run `flutter analyze` to ensure zero static analysis warnings.
2. Run `flutter test` to ensure all 903 unit and widget tests continue to pass without regression.
3. Write a change log in `change_log/20260904_164600_safe-area-bottom-screens.md`.
