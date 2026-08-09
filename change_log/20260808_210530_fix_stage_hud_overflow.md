# Change Log — Fix Stage Mode Floating HUD Layout Overflow

**Plan Reference:** `plans/20260808_110330_fix_stage_hud_overflow.md`

## Summary of Changes
Fixed horizontal layout overflow on the floating Stage Mode HUD (`StageHud`) when viewed on standard phone screens in portrait mode.

### Modified Files
- `lib/widgets/stage_hud.dart`:
  - Wrapped the row of control buttons inside a `SingleChildScrollView` with `scrollDirection: Axis.horizontal`.
  - Replaced `const Spacer()` with `const SizedBox(width: 8)` to allow horizontal scrolling without layout constraint issues.

## Verification
- `flutter analyze` — zero warnings.
- `flutter test test/widgets/stage_hud_test.dart` — passed.
