# Change log — Build the metronome beat (flash + click)

Implements plan `plans/20260722_213442_metronome-beat-flash.md`.

## What changed

The metronome now actually works. When enabled in settings, a round metronome
button appears in the performance controls header. Tapping it starts or stops a
beat at the song's BPM, independent of auto-scroll. On each beat it plays the
built-in click (if Click is on) and flashes the button (if Flash is on).

### Settings grew from one switch to three
- **New model** `lib/models/metronome_settings.dart` — immutable
  `MetronomeSettings` (`enabled`, `flash`, `click`). Defaults: off, flash on,
  click on.
- **Provider rewritten** `lib/providers/metronome_provider.dart` —
  `MetronomeSettingsNotifier` + `metronomeSettingsProvider`, loading and saving
  three `shared_preferences` keys.
- **New constants** `prefMetronomeFlash`, `prefMetronomeClick` (kept
  `prefMetronomeEnabled`).
- **Metronome settings screen** now shows three switches: Enable, Flash, Click.
  Flash and Click are greyed out until Enable is on.

### The beat itself
- **New service** `lib/services/metronome_calculator.dart` — pure beat maths:
  `secondsPerBeat(bpm)` and `beatIndexAt(elapsed, bpm)`, both guarding a
  non-positive bpm.
- **New widget** `lib/widgets/metronome_beat.dart` — owns a `Ticker`, works the
  beat out from real elapsed time (so it does not drift), plays
  `SystemSound.play(SystemSoundType.click)` on each beat, and flashes the button.
  Stops itself when its page is swiped away or the tempo is invalid.
- **`lib/widgets/performance_controls.dart`** — takes an `active` flag and shows
  `MetronomeBeat` (right-aligned next to the auto-scroll row) when the metronome
  is enabled.
- **`lib/screens/song_performance_screen.dart`** — passes `active: widget.active`
  into `PerformanceControls`.

## Offline / no new packages

The click uses Flutter's built-in `SystemSound` (no audio package, no assets, no
network). This means it is the platform's short UI tick, not a loud studio click
— the trade-off of the fully-offline, no-package rule.

## Tests

- New `test/services/metronome_calculator_test.dart` — beat maths and bad-tempo
  guards.
- Rewrote `test/providers/metronome_provider_test.dart` — defaults, reads saved
  values, each setter saves its flag.
- Rewrote `test/screens/metronome_settings_screen_test.dart` — three switches;
  Flash/Click disabled until Enable is on; saving works.
- New `test/widgets/metronome_beat_test.dart` — button shows the timer icon when
  stopped, toggles to stop when tapped, and a zero tempo cannot start.
- Updated `test/screens/song_performance_screen_test.dart` — the
  `PerformanceControls` test passes the new `active` flag and overrides
  `sharedPreferences` (the controls now read metronome settings).

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 241 tests pass.
- `dart format .` — applied.
