# Tablet split view: drag to resize and collapse the song list

**Status:** completed

## The issue

On a tablet (600 dp and wider) the home screen shows the song list on the left and
the song on the right. The line between them cannot be dragged, and the list cannot
be hidden.

Cause: `lib/screens/home_shell.dart` builds a fixed `Row` with
`Expanded(flex: 38)` + `VerticalDivider(width: 1)` + `Expanded(flex: 62)`. The divider
is only a 1-pixel line with no gesture. In portrait on a small tablet the list is
very narrow (song titles are cut to "Jingle ...", "House ..."), and while performing
there is no way to give the song the full width.

Note: the original Android app also used a fixed 38/62 split. This change adds a
small new feature beyond the like-for-like port. The default (38/62, list visible)
stays the same as Android, so nothing changes until the user drags.

## The fix

1. **New widget `ResizableSplitView`** (layer: `widgets/`, pure UI, no business logic).
   - A `Row`: left pane with width = `fraction × available width`, then a divider
     handle, then the right pane in `Expanded`.
   - The handle is a 1 px line with a 16 dp wide touch area and a small grip pill
     in the middle, so it is easy to grab with a finger. It shows the
     resize-column mouse cursor on desktop-style pointers.
   - **Drag** the handle to resize. The list width is clamped: at least 240 dp,
     and at most 60% of the screen (so the song always keeps the larger side).
   - **Collapse:** dragging the handle left past the minimum (below about 120 dp)
     snaps the list closed. Double-tap on the handle also toggles it. When
     collapsed, the handle stays at the left edge with a small chevron
     `IconButton` (tooltip "Show list") to open it again; when open, the same
     button shows "Hide list".
   - Screen reader: the handle has a `Semantics` label and tap action.
2. **Remember the choice** — new provider `splitViewProvider`
   (layer: `providers/`), following the `ThemeModeNotifier` pattern. It holds the
   list fraction and the collapsed flag and saves them in `shared_preferences`
   under new keys `prefSplitListFraction` and `prefSplitListCollapsed`
   (in `AppConstants`). The fraction is saved when the drag ends, not on every frame.
   A bad or out-of-range saved value falls back to the 0.38 default.
3. **`HomeShell`** uses `ResizableSplitView` instead of the fixed `Row`.
4. **Strings** — new ARB keys in `app_en.arb`, `app_ml.arb`, `app_sa.arb`, with
   `@` descriptions in the English file:
   - `tooltipHideList` — "Hide list"
   - `tooltipShowList` — "Show list"
   - `descResizeListHandle` — "Drag to resize the song list. Double-tap to hide or show it."
   Malayalam and Sanskrit translations will use the glossary and be flagged as
   "needs native-reader review". Then run `flutter gen-l10n`.
5. **Tests**
   - `test/providers/split_view_provider_test.dart`: default values, saving,
     bad saved values fall back.
   - `test/widgets/resizable_split_view_test.dart`: drag changes the list width;
     width is clamped at min and max; dragging far left collapses; the chevron
     button and double-tap toggle collapse; tooltips present
     (`expectAllIconButtonsHaveTooltips`).
6. Run `dart format .`, `flutter analyze`, `flutter test`, the Sanskrit
   Hindi-marker check, then write the change log.

## Files to change

- `lib/screens/home_shell.dart` — use the new split view.
- `lib/widgets/resizable_split_view.dart` — new.
- `lib/providers/split_view_provider.dart` — new.
- `lib/core/constants/app_constants.dart` — two new pref keys, min/max/collapse widths.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb` — three new keys
  (plus regenerated `lib/l10n/app_localizations*.dart`).
- `test/providers/split_view_provider_test.dart` — new.
- `test/widgets/resizable_split_view_test.dart` — new.
- `docs/features.md` — mention the resizable / collapsible split.

## Not in scope

- Phones (below 600 dp) are unchanged.
- The uncommitted melody-grid and drift changes already in the working tree are
  separate work and are not touched.
