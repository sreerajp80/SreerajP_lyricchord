# Change log: Guideline compliance — Phase 6, part 1 (tooltips and length checks)

Implements part of Phase 6 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gaps E1–E3). The shorter English texts are **drafted for review, not applied** — the user
asked to review them first. Part 2 applies them once approved.

## What changed

### Draft for review (in the plan, nothing applied)

- New plan section "Phase 6 — proposed shorter texts (for review)":
  - **48** short-category English strings are over the 20-character limit, counted the way
    the new test counts (a plural one branch at a time, a `{placeholder}` as 3 characters).
    Phase 5's rough count was 55.
  - A proposed shorter text for each, with a note where detail moves (a subtitle or Help).
  - 14 matching Help edits, where Help quotes one of these texts by name, so Help keeps
    pointing at real button names.
  - 2 optional consistency edits that are already within the limit.

### Tooltips (gap E1)

- `lib/screens/air_qr_receiver_screen.dart` — the 3 icon buttons that had no tooltip now
  have one: back ("Back"), flashlight ("Turn on flashlight" / "Turn off flashlight", by
  state — the tooltip names the action), and camera switch ("Switch camera").
- `lib/l10n/app_en.arb` (+ generated files) — new keys `tooltipBack`,
  `tooltipAirQrReceiverTorchOn`, `tooltipAirQrReceiverTorchOff`,
  `tooltipAirQrReceiverSwitchCamera`.
- `lib/widgets/auto_scroll_controls.dart` — the Manual/Tempo mode buttons had their tooltip
  in a wrapping `Tooltip` widget. It is now the buttons' own `tooltip:` (which builds the
  same `Tooltip` inside), so the standard's check recognises it. No visible change.

### Tooltip test helper (gap E2)

- New `test/helpers/tooltip_expectations.dart` — `expectAllIconButtonsHaveTooltips(tester)`
  fails for any `IconButton`, non-extended `FloatingActionButton` or `PopupMenuButton`
  without a tooltip (engineering standard §7.8).
- Called in the first widget test of the 15 test files whose screen or widget has icon
  buttons: `test/widget_test.dart` (home screen), `test/screens/` song list, song
  performance, song editor, import preview and chord settings; `test/widgets/` stage HUD,
  song card, performance controls, metronome tempo sheet, pitch drone controls, melody line
  row, melody keypad sheet, gestures help dialog and chord reference dialog. It found the
  mode-button case above.
- Not covered: the AirQR receiver screen has no widget test (it needs the camera), so its
  three new tooltips are checked by reading the code only.

### Label length test (gap E3)

- New `test/l10n/label_length_test.dart`:
  - every key in `app_en.arb` must start with a known category prefix;
  - every `action…`/`label…`/`title…`/`tab…`/`nav…`/`tooltip…` string must fit its
    language's limit (`en` 20; `ml` and `sa` 22, from the language pack), counted in visible
    characters (grapheme clusters), a plural one branch at a time, a placeholder as 3;
  - unit checks for the counting rule, including a Malayalam word counted by visible letters.
  - **Temporary:** the 48 over-limit English keys are listed as known exceptions until the
    texts are approved. The test fails if a listed key is already short enough, so the list
    can only shrink. Part 2 empties it.
- `CLAUDE.md` / `AGENTS.md` — point to the length test and the tooltip helper; put tooltips
  on the button's own `tooltip:`.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1015 tests passed.
- No build was run: only Dart widget code and tests changed.

## Waiting for the user

- Review of the 48 shorter texts, the 14 Help edits and the 2 optional edits in the plan.
