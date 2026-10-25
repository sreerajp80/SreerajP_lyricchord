# Change log: Safe routes without their data, and no flicker when deleting a setlist

Implements [plans/20261025_115133_router-extra-and-setlist-delete.md](../plans/20261025_115133_router-extra-and-setlist-delete.md).

## 1. Routes that need data no longer crash without it

`lib/core/router/app_router.dart`:
- `/air-qr-transmit` and `/import-preview` each have a `redirect`. When `state.extra`
  is not `AirQrTransmitterArgs` / `ImportPreviewArgs`, the redirect sends the user to
  `'/'` (the songbook).
- Both builders also check the type and build `HomeShell` instead of casting, so they
  can never throw even if reached directly. This goes slightly beyond the plan, which
  only asked for a checked read.
- No new UI text.

Tests (`test/core/router/app_router_test.dart`), in a new group:
- `/import-preview` with no data lands on the songbook, with no exception.
- `/air-qr-transmit` with the wrong data does the same.
- With the right data, both routes still open their screens.

## 2. Deleting a setlist no longer flashes "Setlist not found."

`lib/screens/setlist_detail_screen.dart`, `_deleteSetlist`: after the confirm dialog,
the method now:
1. keeps the repository and the `ScaffoldMessenger`,
2. closes the screen (`context.pop()`),
3. waits for the page's closing animation to finish (`ModalRoute.completed`),
4. deletes,
5. shows "Deleted setlist …", or the storage error if the delete fails.

If the dialog's context is gone by the time the user confirms, it stops there.

Step 3 was added during the work and was not in the plan. The page stays on screen
while it slides away, so a delete straight after `pop()` still flashed "Setlist not
found." during the animation. The new frame-by-frame test caught this.

Tests:
- `test/screens/setlist_detail_screen_test.dart`: the delete test now checks 30 frames
  after "Delete" and fails if "Setlist not found." ever appears.
- A new test: a failed delete shows "Could not delete setlist." and keeps the setlist.
- `test/helpers/fake_setlist_repository.dart` has a new `deleteError` option.

## Checks

- `dart format` — clean.
- `flutter analyze` — no issues.
- `flutter test` — 1270 tests, all pass (1266 before; 4 new).
- No Android or Kotlin change, so no app build was run.
