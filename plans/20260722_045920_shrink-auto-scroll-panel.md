# Shrink the Auto-scroll panel (slim header + one control row)

**Status:** completed

## The issue

On the Performance screen the Auto-scroll card takes too much vertical
space, leaving less room for the lyrics. When the card is open it stacks
three tall blocks:

1. A full `ListTile` header — leading icon + "Auto-scroll" title + "Key G"
   subtitle + expand arrow (~64 px).
2. A full-width "Manual / Tempo" `SegmentedButton` on its own row.
3. The mode controls row (play button + speed chips, or the measures
   stepper).

Together with card margins this is ~200 px. We want to cut it down
(chosen option: **B — one control row + slim header**), saving roughly
90–100 px.

## Files to change

- `lib/widgets/performance_controls.dart` — slim the `ExpansionTile`
  header.
- `lib/widgets/auto_scroll_controls.dart` — merge the mode toggle and the
  play/speed controls onto one row.
- `test/screens/song_performance_screen_test.dart` — update any test that
  looks for the old header text or layout (check and fix if needed).

## The plan for the fix

### 1. Slim the header (`performance_controls.dart`)

- Remove the `leading` icon from the `ExpansionTile`.
- Fold the key into the title so the subtitle can go away:
  `Auto-scroll · Key G` (and `· Key G (+2)` when transposed). Keep the
  same "signed semitones" hint logic.
- Make the header dense: set `dense: true` and a compact
  `visualDensity` / tighter `tilePadding` so the row is shorter.
- Keep the card, its margins, and the `ExpansionTile` expand/collapse
  behaviour unchanged.

### 2. One control row (`auto_scroll_controls.dart`)

- Replace the current `Column` (SegmentedButton, `SizedBox(height: 8)`,
  then the mode controls) with a single `Row`:
  `[ Manual|Tempo toggle ] [ play button ] [ mode controls ]`.
- Manual mode: the speed chips (`0.5x / 1x / 2x`) sit to the right of the
  play button, wrapped so they still fit on narrow phones.
- Tempo mode: the measures stepper and the computed-length read-out sit to
  the right. The length text stays (idea-doc read-out); it can drop below
  on very narrow widths if needed, but keep it visible.
- Use a compact `SegmentedButton` (smaller visual density) so it fits on
  the same row as the play button. Icons on the segments may be dropped to
  save width if they crowd the row.
- No change to `autoScrollProvider`, the calculator, or the scrolling
  logic — this is layout only.

### 3. Tests

- Run `flutter analyze` and `flutter test`.
- Fix any test that asserted on the old "Auto-scroll" subtitle "Key G"
  as a separate widget, or the old two-row structure. Behaviour (mode
  switch, play, speed, measures) must still pass.

## Out of scope

- No change to auto-scroll behaviour, speed math, or persistence.
- Not moving the controls into a bottom sheet (that was option C).
