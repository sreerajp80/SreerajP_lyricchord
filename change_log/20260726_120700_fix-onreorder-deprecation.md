# Fix `onReorder` deprecation warning in setlist detail screen

Implements plan: `plans/20260726_120700_fix-onreorder-deprecation.md`

## What changed

1. `lib/screens/setlist_detail_screen.dart`:
   - Replaced deprecated `onReorder:` parameter on `ReorderableListView.builder` with `onReorderItem:`.
   - Removed `if (oldIndex < newIndex) newIndex -= 1;` inside `_reorderSongs` because `onReorderItem` pre-adjusts `newIndex`.

## Verification

- `flutter analyze` — 0 issues found.
- `flutter test` — all 269 tests passed.
