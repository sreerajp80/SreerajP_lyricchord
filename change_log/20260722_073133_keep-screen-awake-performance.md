# Change log: keep the screen awake in the performance view

Implements plan
`plans/20260722_073133_keep-screen-awake-performance.md`.

## What changed

The screen now stays on the whole time a song is open in the performance view,
so the phone no longer dims or locks mid-song. When the user leaves that view,
the phone goes back to its normal screen timeout.

## Details

- **`pubspec.yaml` / `pubspec.lock`** — added the `wakelock_plus` package
  (resolved to 1.3.3). It is an offline platform-channel plugin: it only asks
  Android/iOS to keep the screen on. No network I/O, no runtime permission, no
  `INTERNET` permission — it stays within the app's fully-offline hard rules.

- **`lib/screens/song_performance_screen.dart`**
  - `_SongPerformanceScreenState` now mixes in `WidgetsBindingObserver`.
  - `initState` registers the observer and calls `WakelockPlus.enable()`.
  - `dispose` removes the observer and calls `WakelockPlus.disable()`, so the
    wake-lock lives exactly as long as the performance screen.
  - `didChangeAppLifecycleState` re-enables the wake-lock on `resumed`, because
    the OS clears it when the app leaves the foreground.

## Tests

- `flutter analyze` — clean, no issues.
- `flutter test` — all 201 tests pass. The wake-lock calls are platform
  channels that are no-ops in the test host, so no existing test needed a
  change and no new hardware-behaviour test was added.

## Notes

- On a tablet the performance view is an embedded pane shown next to the song
  list, so the screen stays awake in the songbook too while a song is loaded.
  This is the accepted behaviour for this change.
