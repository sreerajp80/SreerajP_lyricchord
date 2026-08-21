# Change log — Metronome: real click sound, accented beats, own tempo

Date: 2026-08-09
Implements: [plans/20260809_095639_metronome-real-sound-and-beats.md](../plans/20260809_095639_metronome-real-sound-and-beats.md)
Status: completed — all five planned steps done.

---

## Why

The metronome flashed but made no sound on a normal phone, and even with sound it
did not feel like a metronome. Five faults were found and all five are fixed.

## What changed

### 1. The click is now a real sound (the main fix)

The old code called `SystemSound.play(SystemSoundType.click)` — the phone's
keyboard-tap sound. It is silent whenever "Touch sounds" is off in Android
settings (the common case), plays on the system volume instead of the media
volume, is mute in silent mode, and cannot be made louder or higher.

It now uses the same route the Shruti Box drone already used:

- `PcmSynthService.generateClickWav()` builds a ~30 ms percussive click in pure
  Dart, with a new `clickEnvelope()` (instant attack, exponential fall). The
  existing `adsrEnvelope()` sustains at 0.85 and would have sounded like a beep.
- New `MetronomeAudioService` (`lib/services/metronome_audio_service.dart`)
  writes the two clicks to the temp folder and keeps two `AudioPlayer`s
  pre-loaded in `PlayerMode.lowLatency`, so a beat only has to say "play".
- A new metronome **volume** (default 0.8) is saved and applied to the live
  players. Kept separate from the Pitch Drone volume so the two do not fight.
- **No new package.** `audioplayers` was already a dependency, and it only plays
  a local temp file — the fully-offline rule is untouched.

### 2. Accent and time signature

- New `beatsPerBar` (2, 3, 4 or 6; default 4) and `accent` (default on) settings.
- `MetronomeCalculator.beatInBar()` / `displayBeat()` decide the accent and the
  counted number.
- Beat 1 of each bar plays a higher (1500 Hz vs 1000 Hz), louder click.
- While running, the button shows the counted beat number (1 2 3 4) instead of an
  icon, so the position is readable even with the sound off.

### 3. The metronome has its own tempo

- New `MetronomeRuntime` + `metronomeRuntimeProvider`
  (`lib/providers/metronome_runtime_provider.dart`). The override is session-only
  on purpose, so a tweak made for one song does not follow the user to the next.
  Only the *last tempo used* is saved.
- New `MetronomeTempoSheet` (`lib/widgets/metronome_tempo_sheet.dart`), opened by
  a **long press** on the metronome button: −/+ by 1, a 30–300 BPM slider, a
  4-tap averaging **tap tempo**, and "Use song tempo" to go back.
- Tap-tempo maths is `MetronomeCalculator.bpmFromTaps()` — averages the gaps,
  skips double-registered taps, clamps to 30–300.
- A song with **no** saved BPM is no longer a dead button: it falls back to the
  last tempo used, or 100.

### 4. The beat is steady

- The `Ticker` is gone. Each beat now arms its own `Timer` aimed at
  `start + beatIndex × 60/bpm` (`offsetOfBeat` / `timeUntilBeat`). The target is
  always measured from the start, so a timer that fires 3 ms late makes the
  *next* wait 3 ms shorter instead of pushing every later beat back.
- Previously the click was decided inside the screen-refresh callback, so it was
  up to ~16 ms late and worse while the chord sheet was drawing.
- The widget now observes the app lifecycle and **stops** when the app leaves the
  foreground, instead of pausing and then jumping as the `Ticker` version did.

### 5. Testability and polish

- A **Test the sound** row in Metronome settings plays one bar at 100 BPM, so
  audio can be checked without opening a song that has a tempo.
- `MetronomeCalculator.flashDuration()` keeps the flash at 18% of the beat but
  never below 60 ms (at 300 BPM the old 18% was ~36 ms — 2 frames, easy to miss),
  and never longer than the beat itself.
- Help text updated for the accent, tap tempo, volume and the Test button.

## Files changed

**New**

| File | Purpose |
|------|---------|
| `lib/services/metronome_audio_service.dart` | `MetronomeAudio` interface + `MetronomeAudioService`; the only place the metronome touches `audioplayers`. |
| `lib/providers/metronome_runtime_provider.dart` | Session-only tempo override + remembered last tempo. |
| `lib/widgets/metronome_tempo_sheet.dart` | The tempo panel. |
| `test/helpers/fake_metronome_audio.dart` | Records clicks instead of playing them. |
| `test/services/metronome_audio_service_test.dart` | Click WAV header, length, envelope, clipping. |
| `test/providers/metronome_runtime_provider_test.dart` | Override, nudge, tap tempo, fallback. |
| `test/widgets/metronome_tempo_sheet_test.dart` | −/+ limits, tap tempo, reset. |

**Changed**

| File | Change |
|------|--------|
| `lib/services/pcm_synth_service.dart` | Added `clickEnvelope()` and `generateClickWav()`. Pitch/drone methods untouched. |
| `lib/services/metronome_calculator.dart` | Added `minBpm`/`maxBpm`, `beatInBar`, `displayBeat`, `offsetOfBeat`, `timeUntilBeat`, `bpmFromTaps`, `flashDuration`. `secondsPerBeat` and `beatIndexAt` kept as they were. |
| `lib/models/metronome_settings.dart` | Added `volume`, `beatsPerBar`, `accent`. |
| `lib/providers/metronome_provider.dart` | Loads/saves the three new values; ignores an unlisted saved `beatsPerBar`; `setVolume` pushes to the live players. |
| `lib/core/constants/app_constants.dart` | Added 4 pref keys (volume, beats-per-bar, accent, last bpm). |
| `lib/widgets/metronome_beat.dart` | Rewritten: audio service instead of `SystemSound`, accent, beat counter, long-press tempo sheet, timer scheduling, lifecycle stop, minimum flash. |
| `lib/screens/metronome_settings_screen.dart` | Now stateful; volume slider, beats-per-bar segments, accent switch, Test row. |
| `lib/screens/help/help_content.dart` | New "Beats in a bar" section; expanded Flash/Click and Set-the-tempo sections. |
| `docs/features.md` | §2.6 rewritten. |
| `docs/architecture.md` | Services layer now names the metronome/synth services. |
| `test/services/metronome_calculator_test.dart` | Cases for all new maths (29 tests). |
| `test/widgets/metronome_beat_test.dart` | Fake audio; accent patterns, bar counting, drift over 20 beats, no-tempo song, swipe-away. |
| `test/screens/metronome_settings_screen_test.dart` | New controls and the Test button. |
| `test/providers/metronome_provider_test.dart` | The three new values, clamping, rejection of an unlisted value. |

**Not changed**

- `pubspec.yaml` — `audioplayers` was already present; no new package was added.
- `lib/widgets/performance_controls.dart` — the plan expected a change here to
  pass the runtime tempo. It turned out cleaner for `MetronomeBeat` to resolve
  the tempo itself from `metronomeRuntimeProvider` (it already receives the
  song's BPM), so the parent needed no change.

## One design note worth recording

`MetronomeBeat` and `MetronomeTempoSheet` each take an optional
`nowOverride` (`@visibleForTesting`). A widget test's timers run on a **fake**
clock while a real `Stopwatch` stays frozen, so without this seam the widget
believed no time had passed and kept pushing the next beat further away — the
tests caught exactly that. Production uses the real `Stopwatch`.

## Verification done

- `flutter analyze` — **no issues**.
- `flutter test` — **498 tests, all passing** (was 442 before; 56 added).
- `dart format .` — clean.

## Still to be checked by hand on a device

Sound cannot be verified in a unit test. On a real Android phone, please check:

1. Settings → General → Metronome → **Test the sound**: 4 clicks, beat 1 clearly
   different.
2. Turn **off** "Touch sounds" in Android settings — the click must still be
   heard. This is the proof the main fault is fixed.
3. The volume slider changes loudness.
4. A song with a tempo: beat matches, the button counts 1-2-3-4.
5. A song with **no** tempo: the button still works.
6. Long press → tap tempo four times → the BPM follows your taps.
7. Swipe to another song → the beat stops. Send the app to background → no click
   keeps playing.
8. If the click sounds late on a slower phone, the fallback noted in the plan's
   Risks section (loop one bar-long WAV) is the next step.
9. Confirm the release APK still has no INTERNET permission.
