# Change Log: Add SafeArea Bottom Protection Across All Screens

**Date:** 2026-09-04

**Plan Reference:** [../plans/20260904_164600_safe-area-bottom-screens.md](../plans/20260904_164600_safe-area-bottom-screens.md)

## 1. What Changed

1. **Fixed System Navigation Bar Overlap**:
   - On Android devices with system navigation bars (such as the 3-button navigation bar `< O |||` or gesture navigation), screens in edge-to-edge mode had the system bar overlapping content at the bottom of the screen.
   - On the Help screen, the bottom-most card ("Themes, fonts & text size") was partially clipped and covered by the navigation buttons.
   - Audited all screens and modal sheets across the application. Wrapped the screen bodies, scroll views, and sheets in `SafeArea` so that cards, buttons, text fields, and list tiles stop cleanly above the system navigation bar.

2. **Screens and Widgets Updated**:
   - `lib/screens/help/help_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/help/help_detail_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/settings_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/general_settings_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/chord_settings_screen.dart`: Wrapped `Column` in `SafeArea`.
   - `lib/screens/font_settings_screen.dart`: Wrapped `RadioGroup` in `SafeArea`.
   - `lib/screens/import_settings_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/metronome_settings_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/pitch_drone_settings_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/scroll_settings_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/theme_settings_screen.dart`: Wrapped `RadioGroup` in `SafeArea`.
   - `lib/screens/about_screen.dart`: Wrapped body in `SafeArea`.
   - `lib/screens/air_qr_receiver_screen.dart`: Wrapped the bottom HUD panel in `SafeArea(top: false, ...)` so it is offset above the system navigation bar.
   - `lib/screens/air_qr_transmitter_screen.dart`: Wrapped `SingleChildScrollView` in `SafeArea`.
   - `lib/screens/import_export_screen.dart`: Wrapped `ListView` in `SafeArea`.
   - `lib/screens/song_editor_screen.dart`: Wrapped body in `SafeArea(top: false, ...)` so the lyrics input area does not sit behind the navigation bar when the keyboard is closed.
   - `lib/screens/song_performance_screen.dart`: In `_shell`, wrapped body in `SafeArea(top: false, ...)` when not in stage mode.
   - `lib/widgets/carnatic_notation_sheet.dart`: Wrapped sheet in `SafeArea(top: false, ...)`.

## 2. Files Changed

| File | Status | Description |
|---|---|---|
| `lib/screens/help/help_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/help/help_detail_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/settings_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/general_settings_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/chord_settings_screen.dart` | Modified | Added `SafeArea` around `Column` |
| `lib/screens/font_settings_screen.dart` | Modified | Added `SafeArea` around `RadioGroup` |
| `lib/screens/import_settings_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/metronome_settings_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/pitch_drone_settings_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/scroll_settings_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/theme_settings_screen.dart` | Modified | Added `SafeArea` around `RadioGroup` |
| `lib/screens/about_screen.dart` | Modified | Added `SafeArea` around body |
| `lib/screens/air_qr_receiver_screen.dart` | Modified | Added `SafeArea(top: false)` around bottom HUD panel |
| `lib/screens/air_qr_transmitter_screen.dart` | Modified | Added `SafeArea` around `SingleChildScrollView` |
| `lib/screens/import_export_screen.dart` | Modified | Added `SafeArea` around `ListView` |
| `lib/screens/song_editor_screen.dart` | Modified | Added `SafeArea(top: false)` around body |
| `lib/screens/song_performance_screen.dart` | Modified | Added `SafeArea(top: false)` around body in normal mode |
| `lib/widgets/carnatic_notation_sheet.dart` | Modified | Added `SafeArea(top: false)` around sheet |

## 3. Verification

- `dart format .`: Applied cleanly.
- `flutter analyze`: Passed with 0 errors and 0 warnings.
- `flutter test`: All 903 tests passed.
