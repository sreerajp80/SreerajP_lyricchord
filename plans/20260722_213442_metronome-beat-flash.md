# Plan — Build the metronome beat (flash + click) at the song BPM

**Status:** completed

## The issue / what is asked

The earlier change added the metronome *setting* and an on/off toggle, but the
metronome does nothing yet. Now build the real thing: a beat that runs at the
song's BPM on the performance screen, showing a **visual flash** and/or playing a
**click**, so a musician can keep time.

## Constraints that shape the design

- **Fully offline, no new packages.** So the click uses Flutter's built-in
  `SystemSound.play(SystemSoundType.click)` from `package:flutter/services.dart`
  (no audio package, no assets, no network). The flash is a normal Flutter
  animation. This means the click is the platform's short UI tick — light, not a
  loud studio click. That is the trade-off of the no-package rule; noted here so
  it is a known limitation, not a surprise.
- **Beat comes from the song's `bpm`** (already on `SongNote`, default 120). The
  performance screen already hands `bpm` to the controls.
- **Like-for-like, no redesign.** The metronome sits in the existing performance
  controls header, next to auto-scroll — it does not add a new screen or change
  the layout language.

## Design

### Settings (what the user can turn on)

Grow the saved metronome setting from a single bool into a small settings object
so flash and click can be chosen separately — matching "flash **and/or** click":

- `enabled` — master on/off (default **off**), as today.
- `flash` — show the visual flash on each beat (default **on**).
- `click` — play the click sound on each beat (default **on**).

`flash` and `click` only show on the Metronome settings screen while `enabled`
is on.

### Runtime behaviour

- On the performance screen, when the metronome is **enabled** in settings, a
  small round **metronome button** appears in the controls header (next to the
  auto-scroll row). When disabled in settings, nothing shows — same as now.
- Tapping the button **starts/stops** the beat. It is independent of auto-scroll
  play (you can run either, both, or neither).
- While running, on every beat:
  - if **click** is on → `SystemSound.play(SystemSoundType.click)`,
  - if **flash** is on → the button briefly flashes (fills with the accent
    colour then fades), a clear, contained indicator in the controls row — not a
    full-screen strobe (kept deliberately non-intrusive and seizure-safe).
- The beat runs indefinitely (a metronome has no end) until stopped, until the
  song is swiped away, or until the screen is left. Swiping to another song or
  leaving stops it (no click keeps playing off-screen).
- If a song's `bpm` is 0 or less, the start button is disabled (no valid beat).

### Timing

A `Ticker` drives the beat (same approach auto-scroll already uses). Each frame
we work out how many beats have passed since start from the real elapsed time, so
the beat does not drift the way a plain repeating timer would. The beat maths goes
in a small, testable service.

## Files to change

**New files**
- `lib/models/metronome_settings.dart` — immutable `MetronomeSettings`
  (`enabled`, `flash`, `click`) with `copyWith`, `==`, `hashCode`, and the
  defaults above.
- `lib/services/metronome_calculator.dart` — pure beat maths:
  `secondsPerBeat(bpm)` and `beatIndexAt(elapsed, bpm)` (both guard `bpm <= 0`).
- `lib/widgets/metronome_beat.dart` — the running metronome button: owns a
  `Ticker`, reads `metronomeSettingsProvider`, flashes and/or clicks on each
  beat, takes `bpm` and `active` (stops when its page is not the one on screen).

**Edited files**
- `lib/providers/metronome_provider.dart` — replace the bool notifier with
  `MetronomeSettingsNotifier extends Notifier<MetronomeSettings>` +
  `metronomeSettingsProvider`, loading/saving the three pref keys.
- `lib/core/constants/app_constants.dart` — add `prefMetronomeFlash` and
  `prefMetronomeClick` (keep `prefMetronomeEnabled`).
- `lib/screens/metronome_settings_screen.dart` — three switches: Enable, then
  Flash and Click (the last two disabled/greyed while Enable is off).
- `lib/widgets/performance_controls.dart` — take an `active` flag; when the
  metronome is enabled in settings, show `MetronomeBeat`.
- `lib/screens/song_performance_screen.dart` — pass `active: widget.active` into
  `PerformanceControls` so a swiped-away page's metronome stops.

**Tests**
- New `test/services/metronome_calculator_test.dart` — `secondsPerBeat` for
  normal and zero/negative bpm; `beatIndexAt` counts beats correctly and returns
  0 for bad bpm.
- Rewrite `test/providers/metronome_provider_test.dart` — defaults (off, flash
  on, click on), reads saved values, and each setter saves its flag.
- Rewrite `test/screens/metronome_settings_screen_test.dart` — three switches;
  Flash/Click are disabled while Enable is off and enabled once Enable is on;
  flipping Enable saves it.
- New `test/widgets/metronome_beat_test.dart` — the button shows when enabled and
  is hidden when disabled; tapping toggles the play/stop icon; a bpm of 0
  disables start. (Sound and exact timing are not asserted — a `Ticker` and the
  platform click channel are not deterministic in a widget test.)

## Out of scope (not doing now)

- No loud/custom click sample or accented downbeats — the no-package rule limits
  us to the built-in click. Could revisit if a bundled sound asset is later
  allowed.
- No time signature / beats-per-bar accenting; every beat is the same.

## After implementing

- `flutter analyze` clean, `flutter test` all pass, `dart format .`.
- Write a change log to `change_log/` referencing this plan.
