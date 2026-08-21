# Metronome: real click sound, accented beats, own tempo

**Status:** completed

Date: 2026-08-09
Author: Claude Code (requested by Sreeraj P)

---

## 1. What the issue is

The metronome looks like it works (the button flashes) but you cannot hear
anything, and even if you could, it would not feel like a real metronome.

Five separate problems were found by reading the code.

### Problem A — the click is the phone's keyboard-tap sound (main issue)

[lib/widgets/metronome_beat.dart:106](../lib/widgets/metronome_beat.dart#L106)

```dart
if (settings.click) SystemSound.play(SystemSoundType.click);
```

`SystemSoundType.click` is the Android UI key-press sound. It is not a
metronome click. What goes wrong:

- Most phones have "Touch sounds" switched **off** in Android settings. Then
  this plays **nothing at all**. This is why you only see the flash.
- It plays on the phone's *system* volume, not the *media* volume. So it is
  muted in silent / vibrate mode, and the volume rocker does not help while
  music is playing.
- The app cannot set its loudness, its pitch, or its length.
- On iOS this sound is ignored on many versions — completely silent.

So the "Click" switch in Settings is a switch that mostly does nothing.

**The project already solves this correctly elsewhere.** The Pitch Pipe and
Shruti Box build a WAV sound in pure Dart with
[lib/services/pcm_synth_service.dart](../lib/services/pcm_synth_service.dart)
and play it through the `audioplayers` package on the media channel, with a
volume slider — see
[lib/providers/pitch_drone_provider.dart:92-104](../lib/providers/pitch_drone_provider.dart#L92-L104).
The metronome must use the same route. `audioplayers` is already a dependency,
so **no new package is needed** and the fully-offline rule is untouched.

### Problem B — no "ONE-two-three-four"

Every beat sounds and looks identical. There is no bar and no time signature
anywhere in the code. A musician normally follows a metronome by hearing beat 1
of each bar louder / higher. Without that you cannot tell where the bar starts,
so it does not feel musical.

### Problem C — the metronome has no tempo of its own

`bpm` comes only from the song
([lib/widgets/performance_controls.dart:75](../lib/widgets/performance_controls.dart#L75)).
If the song has no tempo saved, the button is dead and shows "No tempo set".
There is no tap-tempo and no +/- to nudge the speed.

### Problem D — a beat can only fire on a screen frame

The click is fired inside the screen-refresh callback
([lib/widgets/metronome_beat.dart:93-107](../lib/widgets/metronome_beat.dart#L93-L107)).
So every beat is up to about 16 ms late at 60 Hz, and later still when the
screen is busy drawing the chord sheet. The eye does not notice this in the
flash, but the ear hears it as slightly unsteady.

### Problem E — small things

- The flash lasts 18% of a beat
  ([lib/widgets/metronome_beat.dart:35](../lib/widgets/metronome_beat.dart#L35)).
  At a fast tempo that is only 2-3 frames — easy to miss.
- The Metronome settings screen has no **Test** button, so you cannot check
  whether the sound works without opening a song that has a tempo saved.
- There is no metronome volume control at all.

### What is already correct (do not change)

[lib/services/metronome_calculator.dart](../lib/services/metronome_calculator.dart)
is right: `60 / bpm`, and the beat number is worked out from **real elapsed
time**, not by adding up small delays. So it does not drift. Keep this class and
build on it.

---

## 2. The plan for the fix

Five steps, in order of value. Each step is useful on its own, so any step can
be dropped without breaking the others.

### Step 1 — a real click sound (fixes Problem A)

- Add `generateClickWav()` to `PcmSynthService`. A metronome click is a very
  short, sharp blip: about 30 ms, a fast attack and a fast fall to silence
  (the existing `adsrEnvelope` is shaped for long notes, so this needs its own
  short envelope). Two variants from the same method:
  - **normal beat** — around 1000 Hz
  - **accent beat** (beat 1) — around 1500 Hz and slightly louder
- Add `lib/services/metronome_audio_service.dart`. It:
  - builds both WAV files once and writes them to the temp folder (same
    approach as the drone, via `path_provider`),
  - keeps two `AudioPlayer` objects ready so there is no load delay on the
    first beat,
  - exposes `playNormal()`, `playAccent()`, `setVolume(double)`, `dispose()`,
  - swallows any audio error quietly — a failed click must never crash a
    performance (hard rule 4).
- `MetronomeBeat` calls this service instead of `SystemSound.play`.
- Add a metronome volume value to `MetronomeSettings` (default 0.8) with a
  slider in the settings screen. Kept separate from the Pitch Drone volume so
  the two do not fight.

### Step 2 — accent and time signature (fixes Problem B)

- Add `beatsPerBar` to `MetronomeSettings` (default 4), with a choice of
  2, 3, 4 and 6 in the settings screen.
- Add `beatInBar(int beatIndex, int beatsPerBar)` to `MetronomeCalculator`,
  returning 0 for the accent beat. Pure maths, easy to unit test.
- `MetronomeBeat` plays the accent click on beat 0 of each bar, and shows the
  beat number (`1 2 3 4`) in the button so you can see the position, not just a
  blink.

### Step 3 — the metronome's own tempo (fixes Problem C)

- Add a small tempo panel, opened by long-pressing the metronome button:
  - shows the current bpm,
  - `-1` / `+1` buttons and a slider (range 30-300),
  - a **Tap tempo** button: tap 4 times, the average gap sets the bpm,
  - a "Use song tempo" button to go back to the song's value.
- The override lives in a new `metronomeRuntimeProvider` (session only, not
  saved to `shared_preferences`) so a per-song tweak does not leak into the
  next song.
- Tap-tempo maths goes in `MetronomeCalculator` (`bpmFromTaps(List<Duration>)`)
  so it is unit-testable.
- When the song has no tempo, the button is no longer dead: it falls back to
  the last used bpm, or 100.

### Step 4 — steady sound (fixes Problem D)

- Keep the `Ticker` for the flash (frames are the right place for drawing).
- For the sound, schedule ahead: on each beat, work out the exact wall-clock
  time of the *next* beat and arm a `Timer` for it, instead of waiting for a
  frame to notice the beat has passed. The target time is still computed from
  the fixed start time + `beatIndex * 60/bpm`, so errors never add up.
- Guard the app going to background: on `AppLifecycleState.paused`, stop the
  beat rather than leave a timer running.

### Step 5 — testability and polish (fixes Problem E)

- Add a **Test** button (a small play icon) on the Metronome settings screen
  that plays 4 beats at 100 bpm, so sound can be checked without opening a
  song.
- Give the flash a minimum length of 60 ms so it stays visible at fast tempos,
  while never being longer than 18% of the beat at slow tempos.
- Add a short help note about the accent, tap tempo and volume in
  [lib/screens/help/help_content.dart](../lib/screens/help/help_content.dart).

---

## 3. Files to be changed

### New files

| File | Why |
|------|-----|
| `lib/services/metronome_audio_service.dart` | Owns the two click players; the only place that touches `audioplayers` for the metronome. |
| `lib/providers/metronome_runtime_provider.dart` | Session-only bpm override and running state (not saved). |
| `lib/widgets/metronome_tempo_sheet.dart` | The tempo panel: +/-, slider, tap tempo. |
| `test/services/metronome_audio_service_test.dart` | Checks the WAV bytes are a valid RIFF header and the right length; no real playback in tests. |
| `test/providers/metronome_runtime_provider_test.dart` | Override, reset-to-song-tempo, fallback bpm. |
| `test/widgets/metronome_tempo_sheet_test.dart` | +/- limits, tap tempo produces a sensible bpm. |

### Changed files

| File | Change |
|------|--------|
| `lib/services/pcm_synth_service.dart` | Add `generateClickWav()` and a short percussive envelope. Do not touch the existing pitch/drone methods. |
| `lib/services/metronome_calculator.dart` | Add `beatInBar()`, `bpmFromTaps()`, and `nextBeatTime()` for the scheduled sound. Keep `secondsPerBeat` / `beatIndexAt` as they are. |
| `lib/models/metronome_settings.dart` | Add `volume` (0.8), `beatsPerBar` (4), `accent` (true). Update `copyWith`, `==`, `hashCode`, `toString`. |
| `lib/providers/metronome_provider.dart` | Load/save the three new values. |
| `lib/core/constants/app_constants.dart` | Add `prefMetronomeVolume`, `prefMetronomeBeatsPerBar`, `prefMetronomeAccent`. |
| `lib/widgets/metronome_beat.dart` | Replace `SystemSound.play` with the audio service; accent on beat 1; show the beat number; long-press opens the tempo panel; scheduled sound; stop on app background; minimum flash length. |
| `lib/screens/metronome_settings_screen.dart` | Add volume slider, beats-per-bar choice, accent switch, Test button. |
| `lib/screens/help/help_content.dart` | Short note on the new controls. |
| `lib/widgets/performance_controls.dart` | Pass the runtime bpm (song tempo or override) to `MetronomeBeat`. |
| `docs/features.md` | Update the metronome description. |
| `docs/architecture.md` | List the new service and provider. |
| `pubspec.yaml` | No change — `audioplayers` is already there. Noted so it is clear no new package is added. |

### Tests to update

| File | Change |
|------|--------|
| `test/services/metronome_calculator_test.dart` | Cases for `beatInBar`, `bpmFromTaps`, `nextBeatTime`. |
| `test/widgets/metronome_beat_test.dart` | Audio service faked out; check accent fires on beat 1 and normal on the rest, and that the beat number shows. |
| `test/screens/metronome_settings_screen_test.dart` | New switches, slider and Test button. |
| `test/providers/metronome_provider_test.dart` | Saving and loading the three new values. |
| `test/screens/song_performance_screen_test.dart` | Only if the metronome button finder breaks. |

---

## 4. Rules this plan respects

- **Fully offline** — no new package; `audioplayers` plays only a local temp
  file, never a URL.
- **Never crash on bad input** — every audio call is wrapped so a failure is
  silent, not fatal.
- **Layer boundaries** — the widget does not build WAV bytes; the synth service
  does not know about widgets or navigation. Sound goes
  `MetronomeBeat -> MetronomeAudioService -> PcmSynthService`.
- **No new permissions** — playing a local file needs none.
- **Immutable models** — `MetronomeSettings` keeps using `copyWith`.

## 5. Risks

- **Audio latency on cheap Android phones.** `audioplayers` re-triggering a
  short file can be slow on some devices. If the click is audibly late,
  fallback is to loop one longer WAV that already contains a whole bar of
  clicks at the chosen tempo — steady by construction, but tempo changes then
  need the file rebuilt. Decide only if testing shows a problem.
- **Two players at once.** The Shruti Box drone may already be playing. Both go
  to the media channel, which is fine, but volumes need checking together on a
  real device.
- **Tests cannot hear sound.** Widget tests will assert the service was
  *asked* to play, not that audio came out. Real sound must be checked by hand
  on a device.

## 6. Verification

1. `flutter analyze` — must be clean.
2. `flutter test` — all tests pass.
3. `dart format .`
4. By hand on a real Android phone:
   - Settings -> General -> Metronome -> **Test**: 4 clicks heard, beat 1
     clearly different.
   - With "Touch sounds" turned **off** in Android settings, the click is still
     heard (this is the proof Problem A is fixed).
   - Volume slider changes loudness.
   - A song with a tempo: beat matches, numbers count 1-2-3-4.
   - A song with **no** tempo: button still works using the fallback bpm.
   - Long press -> tap tempo 4 times -> bpm follows the taps.
   - Swipe to another song -> the beat stops.
   - Send the app to background -> no click keeps playing.
5. Confirm the release APK still has no INTERNET permission.

---

## 7. Change log

To be written to `change_log/` after implementation, then this plan's
**Status:** flips to `completed`.
