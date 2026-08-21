# Fix the whole Procedural Pitch Pipe & Shruti Box Drone feature

**Status:** completed

> Implemented on 2026-08-09. Change log:
> [change_log/20260809_123240_pitch-drone-full-fix.md](../change_log/20260809_123240_pitch-drone-full-fix.md)
>
> **One deviation:** the plan said `PcmSynthService` would not be changed. It
> had to be. Fix A (`setSource` + `resume`) was built and tested on the device
> and the drone was **still** silent — the real cause was the player *mode*, not
> the start sequence. Moving the drone to low-latency (SoundPool) fixed it, and
> SoundPool's ~1 MB sample cap meant shortening the drone buffer from 4 s to 2 s
> with a flat looping envelope.

This plan covers every problem found in the feature: it makes no sound, it hides
its failures, it plays the wrong note, it is hard to reach, and it names Indian
pitches in Western letters.

---

## Part 1 — What was checked on a real device

Tested live over `adb`: moto_g54_5G (`ZD222DXJ65`), running
`in.sreerajp.lyricchord.dev` (pid 22906).

### 1.1 Screen scale is correct — nothing to fix

Physical `1080x2400` at `400 dpi` = **432 x 960 dp**. `432 dp` is below the
`600 dp` breakpoint, so the phone layout is the right one. The smaller picture
in chat was only the chat shrinking the image.

### 1.2 The WAV file is generated correctly

`cache/shruti_drone.wav` is 705,644 bytes. Its header reads `RIFF`, PCM format
1, 2 channels, 44100 Hz, byte rate 176400, 16-bit, data chunk 705,600 bytes.
All correct. `PcmSynthService` is not at fault.

### 1.3 Proof the drone never plays

The metronome and the drone were pressed in the same app process, minutes
apart. `dumpsys audio` shows the difference.

**Metronome — works.** Creates a `SoundPool` player and logs a real start on
every beat:

```
new player piid:1834783 ... type:android.media.SoundPool
11:50:27:544 player piid:1834783 event:started
11:50:28:022 player piid:1834783 event:started
11:50:28:533 player piid:1834783 event:started     (~500 ms apart = 120 BPM)
```

**Drone — silent.** Creates a `MediaPlayer`, re-reads the file every ~4.1
seconds (the 4-second loop going round), but **never once logs
`event:started`**:

```
new player piid:1834775 ... type:android.media.MediaPlayer
11:46:55:583 player piid:1834775 format update:{channelMask=0x3, sampleRate=44100}
11:46:59:710 player piid:1834775 format update:{channelMask=0x3, sampleRate=44100}
11:47:03:870 player piid:1834775 format update:{channelMask=0x3, sampleRate=44100}
11:48:00:522 player piid:1834775 event:paused
```

The loop runs and the file is read, but playback never enters the started
state. That is why there is no sound. Media volume was not the cause:
`STREAM_MUSIC` was `Muted: false`, speaker `7` of `15`, and the in-app volume
was 100%.

The only difference is how the player is built:

| | Metronome (works) | Pitch / drone (silent) |
|---|---|---|
| Player mode | `PlayerMode.lowLatency` -> SoundPool | default -> MediaPlayer |
| Start call | `setSource(...)` then `resume()` | one `play(...)` |
| Errors | `try`/`catch` + `debugPrint` | none |

### 1.4 Not confirmed — the Stage HUD button

In Stage Mode the `graphic_eq` button is visible, but remote `adb input tap`
presses did not open the sheet, and taps elsewhere did nothing either while the
Back key still worked. That pattern normally means Android swallowed the
injected taps because Stage Mode is immersive full screen. **Needs a real
finger to confirm** before treating it as a bug.

---

## Part 2 — The problems

### P1. No sound

The player is created and the source loads, but playback never starts.
`lib/providers/pitch_drone_provider.dart:100-103` and `131-135`.

### P2. Failures are invisible

`playPitchCue`, `_startDrone` and `stopDrone` have no `try`/`catch`. Errors
vanish into an un-awaited future — no log, no message. A dead speaker looks
like a working app.

### P3. The state lies

`state = state.copyWith(dronePlaying: true)` is set whether or not sound
started, so the button reads *Stop Drone* while nothing plays.

### P4. The same file path every time

Both players always reuse `pitch_cue.wav` / `shruti_drone.wav`. `audioplayers`
caches a source by path, so changing the key can keep playing the old note.

### P5. The song's key is thrown away

Reported by the user: a song in **G** opens the sheet showing **C**.

The key travels all the way in and is then ignored:

1. `song.key` = `G`
2. `song_performance_screen.dart:742` transposes it: `currentKey`
3. `song_performance_screen.dart:858` -> HUD
4. `stage_hud.dart:157` -> `songKey: currentKey`
5. `pitch_drone_controls.dart:10,13` accepts `final String? songKey`
6. **`build()` never reads it.** Line 37 uses `settings.selectedKey` instead.

A search for `songKey` across `lib/` returns only those three lines. It is
never used.

This is worse than a wrong label: `activeKey` is also what gets played
(`pitch_drone_controls.dart:133` and `:159`). A singer performing in G is
handed a C reference tone. Once P1 is fixed, this would quietly give bad pitch.

### P6. The key chips cannot show flats or minor keys

`availableKeys` (`pitch_drone_controls.dart:15-28`) lists sharps only. But
`ChordTransposer` deliberately spells Db, Eb, Ab, Bb with flats
(`chord_transposer.dart:28-32`), and songs can be minor (`Am`). The audio side
already copes — `getFrequency` reads `Bb` and strips the `m` — only the chips
are short.

### P7. Hard to reach

The feature exists only in the Stage Mode HUD and in Settings. The normal song
screen toolbar (M, T, play, full screen, -/+, metronome) has no pitch button.

### P8. Indian pitches are named in Western letters

In Indian classical music **Sa is movable** — it sits wherever the singer's
voice is comfortable, so an absolute anchor is genuinely needed. But Indian
musicians name that anchor in their own way, not as "C":

| Pitch | Carnatic | Hindustani |
|---|---|---|
| C | 1 kattai | safed 1 |
| C# | 1½ kattai | kaali 1 |
| D | 2 kattai | safed 2 |
| D# | 2½ kattai | kaali 2 |
| E | 3 kattai | safed 3 |
| F | 4 kattai | safed 4 |
| F# | 4½ kattai | kaali 3 |
| G | 5 kattai | safed 5 |
| G# | 5½ kattai | kaali 4 |
| A | 6 kattai | safed 6 |
| A# | 6½ kattai | kaali 5 |
| B | 7 kattai | safed 7 |

(Kattai numbering follows the common white-key convention: whole numbers for
white keys, halves for black keys. Some teachers use a 1–12 chromatic count
instead, so this is written in one place and easy to change.)

**Already correct, and worth keeping:** the interval maths is Indian, not
Western. `pcm_synth_service.dart:215-218` uses `1.5` for Pa and `4/3` for Ma —
pure just-intonation ratios (3:2 and 4:3), how a tanpura is really tuned.
Equal temperament would be 1.4983 and 1.3348. The Pa/Ma choice is also genuine
practice: the Ma drone is for ragas that leave out Pa (Malkauns, Marwa).

### P9. "Tanpura" is the wrong word

The docs call this a Tanpura drone. A tanpura has four strings tuned
Pa–Sa–Sa–Sa′ across two octaves, plucked in a cycle, and its character comes
from *jawari* — the string grazing a curved bridge. This code sums four fixed
harmonics with a 1.5 Hz tremolo, sounded continuously. That is a **shruti
box**. The word "Tanpura" should go.

---

## Part 3 — The fix

### A. Move audio into a service and make it actually play

New `lib/services/pitch_drone_audio_service.dart`, shaped like
`metronome_audio_service.dart`:

- `abstract class PitchDroneAudio` — `playCue`, `startDrone`, `stopDrone`,
  `setVolume`, `dispose`. An interface so tests can use a fake.
- `PitchDroneAudioService implements PitchDroneAudio`:
  - Build the WAV with `PcmSynthService` (**unchanged** — proven correct).
  - Write to a **unique** file name per key and interval, e.g.
    `shruti_drone_C_Pa.wav`. Fixes **P4**.
  - Play with the sequence the metronome proves works on this device:
    `setReleaseMode`, `setVolume`, `setSource(...)`, then `resume()`.
    Fixes **P1**.
  - Wrap every call in `try`/`catch`; return `false` on failure and
    `debugPrint` the reason under `kDebugMode` only. Never log song content.
    Fixes **P2**.
- Expose `pitchDroneAudioProvider`.

### B. Make the provider honest

`lib/providers/pitch_drone_provider.dart`:

- Call the service instead of holding `AudioPlayer` objects itself.
- Set `dronePlaying: true` **only** when the service reports real playback.
  Fixes **P3**.
- Add `lastError` so the UI can say what went wrong.

### C. Tell the user when it fails

`pitch_drone_settings_screen.dart` and `pitch_drone_controls.dart`: on failure
show a `SnackBar` such as "Could not play the drone." — hard rule 4, never
crash, always surface as a `SnackBar`.

### D. Use the song's key, and name it the song's way

New `lib/services/pitch_naming_service.dart`:

- `PitchTradition { western, carnatic, hindustani }`.
- `String label(String note, PitchTradition t)` — `G` becomes `G`,
  `5 kattai (G)`, or `safed 5 (G)`.
- `String? chipForSongKey(String songKey)` — normalises a song key to a chip:
  strips the minor suffix (`Am` -> `A`), maps flats to the same pitch
  (`Bb` -> `A#`, `Eb` -> `D#`). Returns `null` when nothing matches.
  Fixes **P6**.
- `PitchTradition detect({String? raga, String? tala})` — decides a song's
  tradition:
  - no raga -> `western`
  - raga + a tala in the Carnatic list -> `carnatic`
  - raga + a tala in the Hindustani list -> `hindustani`
  - raga but no usable tala -> the Settings default (below)
  The two tala lists already exist and are already grouped by tradition in
  `swara_notation_service.dart:257-290`; reuse them, do not duplicate.
- Also honour an explicit `{tradition: carnatic}` ChordPro header when the
  writer sets one — it overrides detection.

`lib/widgets/pitch_drone_controls.dart`:

- Actually use `songKey`. Fixes **P5**.
- Choose the opening key by tradition, as agreed:
  - **Western song** -> start on the song's key (`G`).
  - **Carnatic or Hindustani song** -> start on the saved Sa (kattai), because
    the notation is relative to Sa and the song key is not the pitch sung.
  - Fall back to the saved default when nothing matches.
- Label the chips in that song's tradition. Fixes **P8**.
- Show the source above the chips: "Song key: G" or "Your Sa: 5 kattai (G)".
- Rename the interval buttons to **"Sa + Pa (5th)"** and **"Sa + Ma (4th)"**.
- If the user taps another chip, their choice wins for that sheet.
- Opening a song must **not** overwrite the saved default in
  `shared_preferences`.

### E. A Settings section for Sa / kattai

`lib/screens/pitch_drone_settings_screen.dart`:

- New **"Your Sa (Shruti)"** row — a 12-item picker labelled in the chosen
  system, e.g. `5 kattai (G)`. This is the singer's own pitch and is used for
  Indian songs.
- New **"Pitch naming"** row — Western / Carnatic / Hindustani. This is the
  fallback used when a song's tradition cannot be detected, and it sets how the
  Settings screen itself is labelled.
- Keep the existing Default Key row for Western use, relabelled so the two are
  not confused.
- New keys in `AppConstants`: `prefSaKattai`, `prefPitchNaming`.

### F. Make the feature reachable

`lib/widgets/performance_controls.dart`: add a pitch/drone button to the normal
song screen toolbar, beside the metronome, opening the existing sheet with the
song's key, raga and tala. Fixes **P7**. Keep the Stage HUD button as it is.

### G. Correct the documentation

- `docs/feature_analysis_and_innovations.md` lines 41, 83, 130-136, 184,
  227-232, 262, 286: drop "Tanpura", say "Shruti Box". Fixes **P9**.
- `docs/features.md`: describe the new song-screen button, the Sa/kattai
  setting, and state plainly that the drone **holds one steady pair of notes
  and does not follow the melody**.
- `lib/screens/help/help_content.dart`: same clarification in the Help page, so
  nobody expects it to hum the tune.

### H. Tests

- `test/services/pitch_drone_audio_service_test.dart` — WAV header correct; a
  failing player is caught and reported, not thrown.
- `test/services/pitch_naming_service_test.dart` — `G` -> `5 kattai (G)` /
  `safed 5 (G)`; `Am` -> `A`; `Bb` -> `A#`; unknown key -> `null`; tradition
  detection for Adi (Carnatic), Keherwa (Hindustani), no raga (Western),
  raga with unknown tala (falls back to the setting).
- `test/providers/pitch_drone_provider_test.dart` — with a failing fake,
  `dronePlaying` stays `false` and `lastError` is set.
- `test/widgets/pitch_drone_controls_test.dart` — a Western song in G opens on
  G; a Carnatic song opens on the saved Sa; chips are labelled by tradition;
  tapping another chip wins; the saved default is not overwritten.
- `test/widgets/performance_controls_test.dart` — the new button exists and
  opens the sheet.
- `test/helpers/fake_pitch_drone_audio.dart` — the fake.

---

## Files to change

| File | Change |
|------|--------|
| `lib/services/pitch_drone_audio_service.dart` | **new** — playback that works, with error handling |
| `lib/services/pitch_naming_service.dart` | **new** — kattai / safed-kaali names, key normalising, tradition detection |
| `lib/providers/pitch_drone_provider.dart` | use the service; report playing only when true |
| `lib/models/pitch_drone_settings.dart` | add `lastError`, `saKattai`, `pitchNaming` |
| `lib/core/constants/app_constants.dart` | add `prefSaKattai`, `prefPitchNaming` |
| `lib/widgets/pitch_drone_controls.dart` | use `songKey`; tradition-aware labels; Sa+Pa / Sa+Ma; `SnackBar` |
| `lib/screens/pitch_drone_settings_screen.dart` | Sa (kattai) picker; pitch-naming picker; `SnackBar` |
| `lib/widgets/performance_controls.dart` | add the pitch/drone button to the song screen |
| `lib/widgets/stage_hud.dart` | pass `raga` and `tala` through to the sheet |
| `lib/screens/help/help_content.dart` | explain it does not follow the melody |
| `docs/feature_analysis_and_innovations.md` | drop "Tanpura" |
| `docs/features.md` | new button, Sa setting, honest description |
| `test/helpers/fake_pitch_drone_audio.dart` | **new** |
| `test/services/pitch_drone_audio_service_test.dart` | **new** |
| `test/services/pitch_naming_service_test.dart` | **new** |
| `test/providers/pitch_drone_provider_test.dart` | **new / update** |
| `test/widgets/pitch_drone_controls_test.dart` | **new** |
| `test/widgets/performance_controls_test.dart` | update |

`lib/services/pcm_synth_service.dart` is **not** changed — the device proved its
output is a valid WAV, and its Pa/Ma ratios are already correct for Indian
music.

---

## Risk

Low. No new package, no permission, no network — the offline rules are
untouched. The synth maths is unchanged. Layer rules are kept: naming and audio
go in `services/`, state in `providers/`, no SQL or audio work in widgets.

The one thing that could still fail is the `setSource` + `resume` sequence on
some other device. The new logging would then say exactly why, which the
current code cannot do.

## Verify when done

- `flutter analyze` clean, `flutter test` green, `dart format .` run.
- On the device: press *Test Drone*, then check with
  `adb shell "dumpsys audio | grep 'pid:.*<app pid>'"` that the player reaches
  **`event:started`**, not `idle`.
- Open a song in G on the song screen: the sheet must show **G**, not C.
- Open a Carnatic song (Adi tala): chips must read `5 kattai (G)` style, and the
  sheet must open on the saved Sa.
