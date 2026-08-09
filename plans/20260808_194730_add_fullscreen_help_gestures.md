# Add Gesture Icons & Descriptions to Full Screen Help Page

**Status:** Proposed

## Problem
The "Full screen" help page currently lists gestures only as text bullet points. When first entering full screen mode (Stage Mode), a custom overlay (`StageHelpOverlay`) displays visual gesture items with icons, titles, and short explanations. Users expect to see these same visual gesture icons and explanations on the "Full screen" help page under "The gestures" section.

## Proposed Changes

### [lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart)
- Define a `GestureHelpItem` data class with `icon`, `title`, and `description`.
- Add an optional `gestureItems` parameter (`List<GestureHelpItem>?`) to `HelpSection`.
- Update the `full-screen` help topic's "The gestures" section to include the 6 full screen gestures (matching `StageHelpOverlay`):
  1. `Icons.touch_app_outlined`: **Tap once** — *Show or hide the control bar*
  2. `Icons.keyboard_double_arrow_up`: **Double-tap up top** — *Faster (adds bars in Tempo mode)*
  3. `Icons.keyboard_double_arrow_down`: **Double-tap down low** — *Slower (removes bars in Tempo mode)*
  4. `Icons.pan_tool_outlined`: **Tap with two fingers** — *Play or pause*
  5. `Icons.zoom_out_map`: **Pinch** — *Change the text size*
  6. `Icons.arrow_back`: **Back** — *Leave full screen*

### [lib/screens/help/help_detail_screen.dart](../lib/screens/help/help_detail_screen.dart)
- Update `_SectionBlock` to check if `section.gestureItems` is present.
- If `gestureItems` is present, render visual gesture rows with icons, titles, and descriptions, matching the aesthetic of `StageHelpOverlay` while respecting theme colors.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero warnings.
- Run `flutter test` to ensure all existing tests pass.

### Manual Verification
- Navigate to **Settings > Help > Full screen**.
- Verify that "The gestures" section displays the gesture icons alongside gesture names and descriptions.
