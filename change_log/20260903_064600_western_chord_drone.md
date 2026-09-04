# Western Chords Drone (Major & Minor for All Scales)

**Plan:** [plans/20260903_064200_western_chord_drone.md](../plans/20260903_064200_western_chord_drone.md)

## What Changed

1. **Models & Enums**:
   - Added `DroneMode` enum (`classical`, `western`) in `lib/models/pitch_drone_settings.dart`.
   - Added `ChordQuality` enum (`major`, `minor`) in `lib/models/pitch_drone_settings.dart`.
   - Extended `PitchDroneSettings` with `droneMode` (defaults to `DroneMode.classical`) and `chordQuality` (defaults to `ChordQuality.major`).

2. **Preference Keys**:
   - Added `prefDroneMode` and `prefChordQuality` to `AppConstants` in `lib/core/constants/app_constants.dart`.

3. **Pure Dart Offline PCM Synthesis**:
   - Implemented `generateWesternChordDroneWav` in `PcmSynthService` (`lib/services/pcm_synth_service.dart`):
     - Synthesizes 16-bit stereo 44.1 kHz PCM WAV buffers.
     - Voices: sub-octave bass root (`rootFreq * 0.5`), root, third (major/minor), and fifth with stereo detune factor `1.004` on the right channel for spatial pad depth.
     - Loops seamlessly using `droneEnvelope` with subtle 1.5 Hz tremolo.
     - Buffer size ~350 KB, staying within Android SoundPool limits.
   - Implemented `generateWesternChordCueWav` in `PcmSynthService` for 2-second ADSR reference chord cue playback.

4. **Audio Playback Service**:
   - Added `startChordDrone` and `playChordCue` to `PitchDroneAudio` and `PitchDroneAudioService` in `lib/services/pitch_drone_audio_service.dart`.
   - Used individual file caching (`western_chord_drone_${key}_${quality}.wav`).

5. **State Management**:
   - Extended `PitchDroneNotifier` in `lib/providers/pitch_drone_provider.dart` to read and persist `drone_mode` and `pitch_drone_chord_quality`.
   - Added `setDroneMode` and `setChordQuality`.
   - Automatically restarts active drone when mode or chord quality is toggled.
   - Dispatches `playPitchCue` and `toggleDrone` appropriately for classical vs western chords.

6. **Uncluttered User Interface**:
   - Updated `PitchDroneControlsSheet` in `lib/widgets/pitch_drone_controls.dart`:
     - Added a clean 2-segment mode switch: `[Classical (Shruti)]` | `[Western (Chords)]`.
     - Automatically selects `Western` mode for Western songs and `Classical` for Indian raga songs.
     - Detects minor keys from song key (e.g. `Am` pre-selects root note `A` and `Minor` quality).
     - Variation row dynamically swaps between `Sa + Pa` / `Sa + Ma` (in Classical) and `Major` / `Minor` (in Western), maintaining identical vertical height.
     - Action buttons dynamically label `Pitch Cue` vs `Chord Cue` and `Shruti Drone` vs `Chord Drone`.
   - Updated `PitchDroneSettingsScreen` in `lib/screens/pitch_drone_settings_screen.dart` with default drone mode and chord quality settings.

7. **Automated Tests**:
   - Extended `FakePitchDroneAudio` in `test/helpers/fake_pitch_drone_audio.dart`.
   - Added tests in `test/services/pitch_drone_audio_service_test.dart` for Western chord WAV file generation and caching.
   - Added tests in `test/providers/pitch_drone_provider_test.dart` for `droneMode` and `chordQuality` state management, cue playback, and live switching.
   - Added widget tests in `test/widgets/pitch_drone_controls_test.dart` for mode switching, minor key auto-selection, and chord drone controls.

## Verification

- `flutter analyze`: 0 warnings, clean.
- `flutter test`: All 831 tests passing.
