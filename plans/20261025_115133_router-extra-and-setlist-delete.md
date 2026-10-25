# Plan: Safe routes without their data, and no flicker when deleting a setlist

**Status:** completed

Two small issues found during the gap review
([change_log/20261025_110157_gap-review-fixes.md](../change_log/20261025_110157_gap-review-fixes.md),
"Found during the work, not fixed").

---

## 1. Two routes crash when opened without their data

**Issue.** In `lib/core/router/app_router.dart`, two routes read their data with a hard
cast:

- `/air-qr-transmit` → `state.extra as AirQrTransmitterArgs`
- `/import-preview` → `state.extra as ImportPreviewArgs`

If either route is reached without that data, the cast throws, and the user gets an
error screen instead of the app. This can happen when the extra is lost, for example:

- a `go`/`push` to that path with no `extra`,
- the router rebuilding the page after its data is gone.

CLAUDE.md hard rule 4 says the app must never crash on bad input. All six places that
open these routes today do pass the data, so a normal tap does not hit this.

**Fix.**
- Give each of the two routes its own `redirect`. When `state.extra` is not the
  expected type, it returns `'/'`, so the user lands on the songbook — the same thing
  the router's `errorBuilder` already does for an unknown path.
- In the builders, use a checked read (`state.extra as AirQrTransmitterArgs?`, already
  guaranteed by the redirect) instead of the hard cast, with a short comment explaining
  why.
- No new UI text is needed.

**Tests** (`test/core/router/app_router_test.dart`):
- `go('/import-preview')` with no extra lands on `HomeShell` and throws nothing.
- `go('/air-qr-transmit')` with no extra does the same.
- With the right extra, each route still opens its screen (`ImportPreviewScreen`,
  `AirQrTransmitterScreen`).

## 2. Deleting a setlist briefly shows "Setlist not found."

**Issue.** In `lib/screens/setlist_detail_screen.dart`, `_deleteSetlist` deletes the
setlist first and calls `context.pop()` afterwards. The screen watches the setlist as a
live stream. The delete makes that stream send `null` straight away, so the screen
redraws as "Setlist not found." for a moment before it closes.

**Fix.** In `_deleteSetlist`, after the user confirms:

1. Keep what is needed after the screen has gone: the setlist repository, the
   `ScaffoldMessenger`, and the localized texts.
2. Close the screen first (`context.pop()`).
3. Then delete through the kept repository.
4. Show "Deleted setlist …" through the kept messenger, or the storage error if the
   delete fails. On a failure the setlist is still there in the list, so nothing is
   lost.

This only changes the order of the steps, so the screen never draws the missing
setlist.

**Tests** (`test/screens/setlist_detail_screen_test.dart`):
- Make the existing delete test check, frame by frame after "Delete" is tapped, that
  "Setlist not found." never appears.
- Keep its checks that the setlist is gone, the songbook page is shown, and the
  "Deleted setlist …" message appears.
- Add a case where the delete fails (the fake repository throws a `StorageException`):
  the error message is shown, and the setlist still exists.

## Files to change

- `lib/core/router/app_router.dart`
- `lib/screens/setlist_detail_screen.dart`
- `test/core/router/app_router_test.dart`
- `test/screens/setlist_detail_screen_test.dart`
- `test/helpers/fake_setlist_repository.dart` (an option to make `deleteSetlist` fail)

## Checks after the change

`dart format .`, `flutter analyze` (clean), `flutter test` (all pass). No Android or
Kotlin changes, so no app build is needed.
