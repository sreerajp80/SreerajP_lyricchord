# Fix `onReorder` deprecation warning in setlist detail screen

**Status:** completed

## The issue

`flutter analyze` reported a deprecation warning:
`'onReorder' is deprecated and shouldn't be used. Use the onReorderItem callback instead. The onReorderItem callback adjusts the newIndex parameter for a removed item at the oldIndex.`

## Files to change

- `lib/screens/setlist_detail_screen.dart`

## The fix

1. In `ReorderableListView.builder`, replace deprecated `onReorder:` with `onReorderItem:`.
2. In `_reorderSongs`, remove `if (oldIndex < newIndex) newIndex -= 1;` because `onReorderItem` automatically adjusts `newIndex` for items removed at `oldIndex`.
3. Run `flutter analyze` and `flutter test` to verify zero issues.
4. Record change log in `change_log/`.
