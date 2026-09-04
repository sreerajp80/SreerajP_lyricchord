# Western Chords Drone (Major and Minor for All Scales)

**Status:** completed

## The Issue

The app provides a procedural audio drone ("Pitch Pipe & Shruti Box") designed primarily around Indian classical music traditions:
- Pitch Pipe (2-second vocal pitch cue).
- Shruti Box Drone (continuous reed-style drone sounding root pitch Sa plus a fifth Pa or fourth Ma).

Musicians performing Western songs currently lack an equivalent backing chord drone/pad:
- Practicing or performing Western songs often requires a sustained reference chord (backing drone/pad) for the song's key.
- The UI in the performance screen and Stage HUD is already packed with controls (tempo, scroll, metronome, transposition, quiet mode, full screen).
- Adding another separate button or floating overlay would cause UI clutter.
- Therefore, Western chords must be cleanly integrated into the existing drone controls sheet (`PitchDroneControlsSheet`) and settings, providing a mode switch between **Classical (Shruti)** and **Western (Chords)**.

## The Requirements

1. **Dual Mode Switching**:
   - A mode switch between **Classical** and **Western** within `PitchDroneControlsSheet`.
   - Default mode aligns with the song being viewed: Indian songs (with raga/tala) open in Classical mode; Western songs open in Western mode.
   - When a Western song has a minor key (e.g. `Am`, `F#m`), it automatically pre-selects `Minor` quality and the root pitch `A` / `F#`.
   - Users can seamlessly switch between Classical and Western with a single tap.

2. **Full Western Scale Coverage (Major & Minor)**:
   - All 12 chromatic scale root pitches (C, C#, D, D#, E, F, F#, G, G#, A, A#, B).
   - Major and Minor chord qualities for every scale root.

3. **Compact, Uncluttered UI**:
   - The variation row dynamically displays:
     - In Classical mode: `[Sa + Pa (5th)]` | `[Sa + Ma (4th)]`
     - In Western mode: `[Major]` | `[Minor]`
   - Action buttons:
     - Left: `Pitch Cue (2s)` (Classical single tone) / `Chord Cue (2s)` (Western chord cue)
     - Right: `Shruti Drone` (Classical) / `Chord Drone` (Western) -> switches to `Stop Drone` in red when sounding.
   - Preserves exact vertical height and layout harmony so no extra vertical space is used.

4. **Procedural PCM Synthesis**:
   - Pure Dart PCM 16-bit stereo WAV synthesis (no external audio assets, keeping the app 100% offline).
   - Acoustic synthesis for Western chords:
     - Bass root frequency (`rootFreq * 0.5`) for deep foundational support.
     - Root frequency (`rootFreq`).
     - Third frequency (`rootFreq * 2^(4/12)` for Major, `rootFreq * 2^(3/12)` for Minor).
     - Fifth frequency (`rootFreq * 2^(7/12)`).
     - Multi-harmonic additive synthesis with stereo detuning (1.004 detune factor on the right channel) for spatial stereo depth.
     - Subtle 1.5 Hz tremolo modulation and click-free looping envelope (`droneEnvelope`).
     - Fits within ~350 KB buffer for SoundPool low-latency looping compatibility.

5. **Audio Service & Settings Integration**:
   - `PitchDroneAudio` interface and `PitchDroneAudioService` implement chord drone playback and caching.
   - `PitchDroneSettings` and `PitchDroneNotifier` manage state and persistence (`drone_mode`, `drone_chord_quality`).
   - Settings screen (`PitchDroneSettingsScreen`) updated to configure defaults.

## Files to Change

1. `lib/models/pitch_drone_settings.dart`:
   - Add `DroneMode` enum (`classical`, `western`).
   - Add `ChordQuality` enum (`major`, `minor`).
   - Add `droneMode` and `chordQuality` fields to `PitchDroneSettings`.
2. `lib/core/constants/app_constants.dart`:
   - Add preference keys `prefDroneMode` and `prefChordQuality`.
3. `lib/services/pcm_synth_service.dart`:
   - Add `generateWesternChordDroneWav` (continuous looping buffer).
   - Add `generateWesternChordCueWav` (2-second ADSR cue).
4. `lib/services/pitch_drone_audio_service.dart`:
   - Extend `PitchDroneAudio` interface with `startChordDrone` and `playChordCue`.
   - Implement methods in `PitchDroneAudioService` using file caching.
5. `lib/providers/pitch_drone_provider.dart`:
   - Add methods `setDroneMode`, `setChordQuality`.
   - Update `toggleDrone` and `playPitchCue` to dispatch to chord or shruti drone based on current mode.
6. `lib/widgets/pitch_drone_controls.dart`:
   - Add Classical vs Western SegmentedButton toggle.
   - Swap the variation selector dynamically between `Sa + Pa` / `Sa + Ma` and `Major` / `Minor`.
   - Pre-select key and quality from `songKey`.
   - Dynamically label cue and drone action buttons.
7. `lib/screens/pitch_drone_settings_screen.dart`:
   - Add default drone mode and chord quality configuration.
8. `test/helpers/fake_pitch_drone_audio.dart`:
   - Update fake with chord drone recording.
9. Tests:
   - `test/services/pcm_synth_service_test.dart` (or new test): verify WAV generation.
   - `test/services/pitch_drone_audio_service_test.dart`: verify chord audio calls.
   - `test/providers/pitch_drone_provider_test.dart`: verify mode/quality switching.
   - `test/widgets/pitch_drone_controls_test.dart`: verify UI toggle and chord actions.

## Verification Plan

1. `flutter test`: Run all test suites to guarantee zero regression and verify new tests pass.
2. `flutter analyze`: Ensure clean static analysis with zero warnings.
