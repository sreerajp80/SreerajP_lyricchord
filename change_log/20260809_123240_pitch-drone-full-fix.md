# Pitch Pipe & Shruti Box — made it work, and made it speak Indian

**Plan:** [plans/20260809_114812_pitch-drone-no-sound.md](../plans/20260809_114812_pitch-drone-no-sound.md)
**Date:** 2026-08-09 12:32 (local)

The feature made no sound at all, hid its own failures, played the wrong note,
was hard to reach, and named Indian pitches in Western letters. All of that is
fixed and verified on a real device.

---

## The bug, and what actually caused it

The drone never played. On the device the app created a `MediaPlayer`, loaded
the WAV, looped over it — and never once reached the started state.
`dumpsys audio` showed the format being re-read every ~4.1 seconds but no
`event:started`, so nothing was ever heard.

The plan's first guess was the **start sequence** (`setSource` + `resume`
instead of a single `play`). That was rebuilt, installed, and tested — and the
drone was *still* silent. The guess was wrong.

The real cause was the **player mode**. Proof came from running both sounds in
the same process, minutes apart:

| Sound | Player | Result |
|---|---|---|
| Metronome click | `SoundPool` (low latency) | `event:started` on every beat |
| Pitch cue (after fix) | `SoundPool` (low latency) | plays — user confirmed |
| Drone (media player) | `MediaPlayer` | `state:idle`, never started |

Moving the drone onto the same low-latency path made it play immediately:

```
new player piid:1834823 ... type:android.media.SoundPool
12:31:14:323 player piid:1834823 event:started
```

**Deviation from the approved plan.** The plan said `PcmSynthService` would not
be changed. It had to be. `SoundPool` caps a sample at roughly 1 MB, and the
4-second stereo drone was 705 KB — close enough to be risky, and a fade-to-
silence envelope on a looping buffer makes the drone swell and dip on every
pass. So the drone buffer is now 2 seconds (352 KB) with a flat envelope. This
was reported to the user at the time.

---

## What changed

### Sound now works, and failure is visible

* **New `lib/services/pitch_drone_audio_service.dart`.** All playback moved out
  of the provider, behind a `PitchDroneAudio` interface so tests can use a fake.
  Both sounds use `PlayerMode.lowLatency`, `setSource(...)`, then `resume()`.
* **Every call is wrapped.** A failure returns `false` and, in debug builds
  only, prints why. Song content is never logged.
* **Unique file names per key and interval** (`shruti_drone_G_Pa.wav`).
  `audioplayers` caches a source by path, so the old single filename could keep
  sounding the previous note after a key change.
* **A file already on disk is not rebuilt** — the synth is deterministic, so
  the same key always gives the same bytes.

### The state no longer lies

`dronePlaying` is set **only** when the service reports that sound really
started. Before, it was set the moment play was requested, so the button read
"Stop Drone" over silence. A new `lastError` field drives a `SnackBar`.

### The song's key is used

The reported bug: a song in **G** opened the sheet showing **C**. The key was
passed all the way into the sheet as `songKey` and then never read — a search
for `songKey` returned only the constructor, the field, and the caller.

Worse than a wrong label: that value is also what gets played, so a singer in G
was handed a C reference tone.

Now the sheet opens on the right pitch, and which pitch that is depends on the
tradition:

* **Western song** → the song's own transposed key.
* **Carnatic / Hindustani song** → the singer's saved **Sa**, because the
  notation is written relative to Sa and the written key is not the pitch sung.

Any spelling resolves: `Am` → A, `Bb` → A#, `Eb` → D#, `G/B` → G, lower case,
`Cmaj7`. An unreadable key falls back to the saved default instead of showing
nothing.

Choosing a different chip lasts for that sheet only and never overwrites the
saved default.

### Indian pitch naming

* **New `lib/models/pitch_tradition.dart`** — `PitchTradition` enum. Lives in
  `models/` so the settings model does not have to depend upward on a service.
* **New `lib/services/pitch_naming_service.dart`** — names a pitch the way its
  tradition names it (`G`, `5 kattai (G)`, `safed 5 (G)`), normalises song keys
  to a chip, and works out a song's tradition.
* **Tradition is detected from the tala.** `swara_notation_service.dart` already
  held both tala lists; its single `_talaBeats` map was split into
  `_carnaticTalaBeats` and `_hindustaniTalaBeats` (merged back for `talaBeats`,
  so nothing changed for existing callers) and a `talaTradition()` method added.
  No list was duplicated. A raga with no readable tala falls back to the user's
  setting — and a raga is never named Western, since a Western letter has no
  place on an Indian sheet.
* **No Western letter on an Indian sheet.** The first build showed
  `safed 1 (C)`, keeping the letter as a visible anchor. On the user's decision
  this was changed to pure Indian naming — `safed 1`, `5 kattai` — using
  `shortLabel()`. `label()` (with the bracketed letter) is kept and tested, so
  the choice can be reversed in one line. A side benefit: the shorter chips fit
  more pitches on screen at once.
* **Intervals renamed** to "Sa + Pa (5th)" and "Sa + Ma (4th)".

### A Settings section for Sa

`Settings → General → Pitch Pipe & Shruti Box` gained:

* **Pitch naming** — Western / Carnatic / Hindustani.
* **Your Sa (Shruti)** — the singer's own pitch, labelled `1 kattai (C)` style.
  Kept apart from the Western default key on purpose: Sa belongs to the voice
  and hardly changes, while the drone key follows whichever song is open.

### Reachable from the ordinary song screen

A pitch button now sits next to the metronome in `performance_controls.dart`.
Before, the only ways in were Stage Mode — which many people never open — and
a Settings page.

### Honest documentation

* "Tanpura" is gone everywhere. A tanpura has four strings plucked in a cycle
  and takes its shimmer from *jawari*; this synthesizes a steady reed drone, so
  it is a **shruti box**.
* Help, Settings and the docs now state plainly that the drone **holds one
  steady pair of notes and does not follow the tune** — "continuous drone" was
  being read as "hums the song".
* One false claim removed from Help: it said the drone "automatically stops
  when you leave performance view". Nothing did that, and nothing does now.
* `docs/features.md` gained section 2.7; later sections renumbered.

---

## Files changed

**New**

| File | Purpose |
|------|---------|
| `lib/services/pitch_drone_audio_service.dart` | playback that works, with error handling |
| `lib/services/pitch_naming_service.dart` | kattai / safed-kaali naming, key normalising, tradition detection |
| `lib/models/pitch_tradition.dart` | the tradition enum |
| `test/helpers/fake_pitch_drone_audio.dart` | fake audio for tests |
| `test/services/pitch_drone_audio_service_test.dart` | 5 tests |
| `test/services/pitch_naming_service_test.dart` | 19 tests |
| `test/providers/pitch_drone_provider_test.dart` | 12 tests |
| `test/widgets/pitch_drone_controls_test.dart` | 13 tests |

**Changed**

| File | Change |
|------|--------|
| `lib/services/pcm_synth_service.dart` | new `droneEnvelope`; drone buffer 4 s → 2 s; doc corrected |
| `lib/services/swara_notation_service.dart` | tala map split by tradition; `talaTradition()`; `TalaTradition` enum |
| `lib/providers/pitch_drone_provider.dart` | uses the service; reports playing only when true; tracks the sounding pitch |
| `lib/models/pitch_drone_settings.dart` | `saKey`, `pitchNaming`, `lastError` |
| `lib/core/constants/app_constants.dart` | `prefSaKey`, `prefPitchNaming` |
| `lib/widgets/pitch_drone_controls.dart` | uses `songKey`; tradition-aware; Sa + Pa/Ma; `SnackBar` |
| `lib/screens/pitch_drone_settings_screen.dart` | Sa picker, naming picker, `SnackBar` |
| `lib/widgets/performance_controls.dart` | pitch button on the song screen |
| `lib/widgets/stage_hud.dart` | passes raga and tala to the sheet |
| `lib/screens/general_settings_screen.dart` | renamed entry |
| `lib/screens/help/help_content.dart` | rewritten topic |
| `docs/features.md`, `docs/feature_analysis_and_innovations.md` | corrected |
| `test/screens/settings_screen_test.dart` | follows the renamed Help topic |
| `test/widgets/performance_controls_test.dart` | 3 tests for the new button |

---

## Verification

* `dart format .` run, `flutter analyze` — **no issues found**.
* `flutter test` — **550 tests pass**.
* On a moto_g54_5G over `adb`, dev debug build:
  * Pitch cue plays; user confirmed hearing it.
  * Drone plays: `type:android.media.SoundPool`, `event:started` at 12:31:14;
    user confirmed hearing it.
  * The new pitch button appears on the ordinary song screen.
  * Opening *Raghupati Raghava Raja Ram* (Raga Mishra Gara, Tala Keherwa) shows
    **Hindustani** naming — "Your Sa: safed 1", chips `safed 1`, `kaali 1`,
    `safed 2`, `kaali 2` — and opens on Sa, not the written key. No Western
    letter anywhere on the sheet.

## Left open

* **Toolbar wrapping.** With the new button, the song screen toolbar wraps onto
  two rows on a 432 dp-wide phone. It works and nothing is cut off, but it is
  worth a look if the layout should stay one row.
* **Kattai numbering** uses the common white-key convention (whole numbers
  white, halves black). Some teachers count 1–12 chromatically; that sits in one
  list in `pitch_naming_service.dart` if it needs changing.
