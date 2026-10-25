# Tablet split view: drag to resize and collapse the song list

Plan: [plans/20261025_180538_tablet-resizable-split.md](../plans/20261025_180538_tablet-resizable-split.md)

## What was wrong

On a tablet the line between the song list and the song was a fixed 38/62
`Row` with a 1-pixel `VerticalDivider`. It had no gesture, so it could not be
dragged and the list could not be hidden.

## What changed

- **New widget** `lib/widgets/resizable_split_view.dart` (`ResizableSplitView`):
  - The list is on the left, then a 24 dp divider handle, then the song.
  - Drag the handle to resize the list. The width stays between 240 dp and
    60% of the screen.
  - Dragging the list narrower than 120 dp hides it. Double-tapping the handle, or
    tapping the chevron button on it ("Hide list" / "Show list"), hides or shows it.
    When hidden, the handle stays at the left edge; dragging it right opens the list again.
  - The drag counts from touch-down (`DragStartBehavior.down`), so the divider
    stays under the finger.
  - While hidden or closing, the list keeps a minimum width and slides out of view
    (clipped) instead of being squashed. It stays in the tree, so its scroll
    position and search text are kept. It is left out of focus and screen-reader
    order while hidden.
  - The handle has a screen-reader label and a resize mouse cursor.
- **New provider** `lib/providers/split_view_provider.dart` (`splitViewProvider`,
  `SplitViewLayout`): holds the list width and hidden state, saved in
  `shared_preferences`. A missing or out-of-range saved width falls back to 38%.
  The width is saved once, when the drag ends.
- `lib/core/constants/app_constants.dart`: new pref keys
  `prefSplitListFraction`, `prefSplitListCollapsed`, and the width limits.
- `lib/screens/home_shell.dart`: uses `ResizableSplitView` instead of the fixed `Row`.
  The default layout (38/62, list shown) is unchanged from the Android app.
- Strings: `tooltipHideList`, `tooltipShowList`, `descResizeListHandle` added to
  `app_en.arb`, `app_ml.arb`, `app_sa.arb`; `flutter gen-l10n` re-run.
- `docs/features.md`: added the resizable, collapsible split.

## Tests

- `test/providers/split_view_provider_test.dart`: defaults, loading, bad saved
  values, saving width and hidden state.
- `test/widgets/resizable_split_view_test.dart`: default width, drag resize and
  save, min/max limits, drag-to-hide and drag-to-open, chevron button,
  double-tap, restoring a saved hidden list, tooltips present.
- `flutter analyze`: no issues. `flutter test`: all 1286 tests pass.
  `tool/check_sanskrit_hindi_markers.sh`: passed.

## Needs native-reader review

- Malayalam: `tooltipHideList` "പട്ടിക മറയ്ക്കുക", `tooltipShowList`
  "പട്ടിക കാണിക്കുക", `descResizeListHandle`.
- Sanskrit: `tooltipHideList` "सूची गोप्यताम्", `tooltipShowList`
  "सूची दर्श्यताम्", `descResizeListHandle`.

## Not done

- Not yet checked on a real tablet. Only widget tests cover it so far.
