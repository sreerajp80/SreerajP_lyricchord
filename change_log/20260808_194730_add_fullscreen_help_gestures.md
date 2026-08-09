# Change Log: Add Gesture Icons & Descriptions to Full Screen Help Page

**Plan Reference:** [plans/20260808_194730_add_fullscreen_help_gestures.md](../plans/20260808_194730_add_fullscreen_help_gestures.md)

## Summary of Changes
Added visual gesture icons, titles, and descriptions to the "Full screen" help detail page under "The gestures" section to match the first-time full screen overlay (`StageHelpOverlay`).

## Files Changed
- [lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart): Defined `GestureHelpItem` model, updated `HelpSection` with optional `gestureItems`, and added the 6 gesture items to the "full-screen" help topic.
- [lib/screens/help/help_detail_screen.dart](../lib/screens/help/help_detail_screen.dart): Updated `_SectionBlock` to render `_GestureRow` instances when `gestureItems` is present on a section.

## Verification
- Executed `flutter analyze` — zero static analysis issues.
- Executed `flutter test` — all test suites passed.
