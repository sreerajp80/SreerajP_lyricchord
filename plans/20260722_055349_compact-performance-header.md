# Compact performance-view header (M/T · play · speed · status line)

**Status:** completed

## The issue

The performance view puts the auto-scroll controls in a collapsible `Card`
(`ExpansionTile`) below the app bar. The user wants a **more compact**,
always-visible header that matches a supplied mockup:

- A row with a round **M / T** mode toggle, a filled round **play** button, and
  the mode's control on the right (Manual = `0.5x 1x 2x` speed chips).
- A single muted status line: **`Auto-scroll · Key G · 120 BPM`**.

The mockup draws the Manual speed chips even while **T** looks selected. That is
just the mockup; in our app each mode must still show its own correct control —
Manual shows the speed chips, Tempo shows the measures stepper (confirmed with
the user).

Decisions confirmed with the user:
1. **Always-visible bar** — remove the `ExpansionTile`; no expand/collapse.
2. **Tempo mode shows the compact measures stepper** (`− 32 +`) in the same spot
   the speed chips occupy in Manual mode.

## Files to change

- `lib/widgets/performance_controls.dart` — drop the `Card` + `ExpansionTile`.
  Build a compact, always-visible header: the controls row plus the status line
  `Auto-scroll · Key {key} · {bpm} BPM`.
- `lib/widgets/auto_scroll_controls.dart` — the compact controls row: round
  **M / T** toggle, round filled **play**, and the mode control on the right
  (Manual = speed chips; Tempo = compact `− count +` stepper). Move the long
  Tempo duration/px read-out out of the row into the status line.
- `test/screens/song_performance_screen_test.dart` — the controls are no longer
  hidden behind an expand tap. Remove the "expands to show the controls" tap in
  the three tests that first tap the `Auto-scroll` header, and assert the
  controls are visible straight away.

No provider, service, or model changes — `autoScrollProvider`,
`AutoScrollCalculator`, and the play/speed/measures logic all stay exactly as
they are. This is a UI-layout change only.

## The plan for the fix

### 1. `performance_controls.dart` — compact header shell
- Replace the `Card` + `ExpansionTile` with a slim `Container` / `Column`
  (tight padding, e.g. `EdgeInsets.fromLTRB(12, 4, 12, 6)`), always visible.
- **Controls row:** `AutoScrollControls(bpm: bpm)` (the row below).
- **Status line:** one muted line built here (it already computes `currentKey`
  and holds `bpm`):
  - Manual mode: `Auto-scroll · Key {key} · {bpm} BPM`
    (append the transpose hint `(+2)` when transposed, as today).
  - Tempo mode: same line plus ` · {measures} bars · {m:ss}` so the
    "ends at song end" info the old read-out gave is not lost. It reads the mode
    and measures from `autoScrollProvider` and the duration from
    `AutoScrollCalculator` (same call the tempo controls use).
- Keep the `Key {key}` label and its `(+n)` hint exactly as the current header
  builds them.

### 2. `auto_scroll_controls.dart` — one compact row
- Layout: `Row` → `[ M/T toggle ] [ play ] [ Spacer/Expanded ] [ mode control ]`,
  the mode control right-aligned like the mockup.
- **M / T toggle:** two small **circular** toggle buttons to match the mockup
  (M outlined when unselected, T filled with the primary colour when selected).
  Each stays a comfortable tap target (~40 dp) and keeps a tooltip
  (`Manual` / `Tempo`) for accessibility. Selecting a mode calls
  `controls.setMode` unchanged.
- **Play button:** round **filled** button (`IconButton.filled`, primary fill to
  match the mockup's purple), same play/pause toggle and tooltip as now. In
  Tempo mode it stays disabled until there is a length (`duration == 0`), exactly
  as today.
- **Manual mode control:** the existing `0.5x 1x 2x` `ChoiceChip`s
  (no checkmark), unchanged behaviour.
- **Tempo mode control:** the compact `− {measures} +` stepper only (the multi-
  line duration/px text moves to the status line in step 1).
- Delete the now-unused multi-line `Text` read-out from `_TempoControls`; keep
  its `_formatDuration` only if the status line needs it, otherwise move that
  helper next to where the duration is formatted.

### 3. Tests (`song_performance_screen_test.dart`)
- The three tests that first tap the `Auto-scroll` header to expand
  (`the auto-scroll card expands…`, `switching to Tempo mode…`, and the
  `PerformanceControls` play test) no longer need the expand tap — the controls
  render immediately. Update them to:
  - assert `M` / `T` (or their tooltips) and `1x` are visible without any tap;
  - keep the Tempo test's `tap('T')` then assert the measures stepper tooltips;
  - keep the play test tapping `Play` / `Pause` directly (no expand first).
- Rename the "expands" test to reflect that the controls are always visible.

## Verification

- `flutter analyze` — clean, zero warnings.
- `flutter test` — all green, including the auto-scroll calculator tests
  (untouched) and the updated performance-screen tests.
- Manual check intent: header is one compact block under the app bar; Manual
  shows chips, Tempo shows the stepper, status line reads
  `Auto-scroll · Key G · 120 BPM`.
- `dart format .` before finishing.
