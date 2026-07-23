# Keep the screen awake in the performance view

**Status:** completed

## The issue

When a musician opens a song in the performance view and reads or plays it,
the phone can dim and lock itself after the normal screen-timeout. This
interrupts the song mid-performance. We want the screen to stay on the whole
time the performance view is open, then go back to the phone's normal timeout
when the user leaves that view.

## The plan for the fix

Use a wake-lock that is turned on while the performance screen is on screen
and turned off when it is closed.

- Add the `wakelock_plus` package. It is a small, offline platform-channel
  plugin (no HTTP, cloud, analytics, or AI). It only asks Android/iOS to keep
  the screen on — no runtime permission, no `INTERNET` permission. This fits
  the "fully offline" and "no runtime permissions" hard rules.
- Enable the wake-lock in `_SongPerformanceScreenState.initState` and disable
  it in `dispose`, so it is tied to the life of the performance screen only.
  Every other screen keeps the normal screen timeout.
- Handle app background/foreground: the OS clears the wake-lock when the app
  leaves the foreground. Add a `WidgetsBindingObserver` so we re-enable it on
  `resumed` and release it on `paused`, but only while this screen is still
  mounted.
- On the tablet the performance screen is an embedded pane that is always
  present next to the list, so the wake-lock stays on in the songbook too.
  This matches "the app is showing a song to perform" and is acceptable; it is
  released as soon as the whole two-pane shell is left. (If we later want it
  tighter, we can gate it, but that is not needed now.)

## Files to change

- `pubspec.yaml` — add `wakelock_plus` dependency.
- `lib/screens/song_performance_screen.dart` — enable the wake-lock while the
  screen is mounted (initState + lifecycle observer), release it in dispose.
- `pubspec.lock` — updated by `flutter pub get` (generated).

## Testing

- `flutter analyze` must stay clean.
- `flutter test` must stay green (existing
  `test/screens/song_performance_screen_test.dart` must still pass; the
  wake-lock call is a platform channel that is a no-op in the test host, so no
  new test asserts hardware behaviour).
- Manual check on a device: open a song, leave it untouched past the normal
  screen timeout, confirm the screen stays on; go back to the list and confirm
  the screen dims normally again.

## Change log

To be written to `change_log/` after implementation.
