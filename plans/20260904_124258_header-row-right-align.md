# Push the header read-out and icons to the right edge

**Status:** completed

Fixes a layout slip left by
[20260904_121334_header-icons-and-drag-resume.md](20260904_121334_header-icons-and-drag-resume.md).

## The issue

The speed, the chords icon and the melody icon sit right next to the full screen
button instead of at the right edge of the screen, leaving a wide empty gap after
them.

`PerformanceControls` puts the row in a `Wrap` with
`alignment: WrapAlignment.spaceBetween`, but that `Wrap` is a child of a `Column`
with `mainAxisSize: MainAxisSize.min` and `crossAxisAlignment: start`. The Column
gives the Wrap only as much width as it asks for, so the Wrap is exactly as wide
as its children and there is no spare space for `spaceBetween` to share out. The
two groups therefore end up touching.

## The plan

`lib/widgets/performance_controls.dart` — give the `Wrap` the full width of the
header by wrapping it in `SizedBox(width: double.infinity, …)`. Nothing else
changes: with real space to share, `spaceBetween` puts M / T / full screen on the
left and the read-out and icons hard against the right edge, and the run still
drops to a second line on a phone too narrow for both.

## Files to change

| File | Change |
|---|---|
| `lib/widgets/performance_controls.dart` | `Wrap` wrapped in a full-width `SizedBox` |
| `test/widgets/performance_controls_test.dart` | New test: the icons sit to the right of the mode buttons, near the right edge |

## Checks after the change

- `flutter analyze` clean, `flutter test` all green.
- The existing "controls row fits on a narrow phone" test still passes (no
  overflow at 360 dp with the metronome on).
