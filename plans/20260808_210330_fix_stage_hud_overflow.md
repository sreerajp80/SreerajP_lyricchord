# Fix Stage Mode Floating HUD Layout Overflow

**Status:** Proposed

## Issue
In Stage Mode (full-screen song view), the bottom translucent floating control HUD (`StageHud`) overflows horizontally by 56 pixels on standard phone screens in portrait mode (`RIGHT OVERFLOWED BY 56 PIXELS`). This happens because 7 control action buttons, 2 mode buttons (M & T), and the speed/bars stepper row are laid out in a single fixed `Row` with a `Spacer()`.

## Fix
In `lib/widgets/stage_hud.dart`:
- Wrap the main controls `Row` in a `SingleChildScrollView` configured with `scrollDirection: Axis.horizontal`.
- Replace the `const Spacer()` between the action buttons and the speed stepper with `const SizedBox(width: 8)`.
- This ensures all buttons remain accessible and responsive without overflowing on smaller phone screens or portrait orientation.

## Target Files
- `lib/widgets/stage_hud.dart`

## Verification Plan
1. Run `flutter analyze` to confirm clean analysis.
2. Run `flutter test test/widgets/stage_hud_test.dart` to verify all Stage Mode HUD interactions pass.
