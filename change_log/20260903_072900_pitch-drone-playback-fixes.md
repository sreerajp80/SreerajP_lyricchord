# Pitch Drone Playback Fixes (Restart, Mode Switching, Premature Stopping)

**Plan:** [plans/20260903_072500_pitch-drone-playback-fixes.md](../plans/20260903_072500_pitch-drone-playback-fixes.md)

## What Changed

1. **Continuous Looping Drone with `PlayerMode.mediaPlayer`:**
   - Switched `_dronePlayer` in `PitchDroneAudioService` (`lib/services/pitch_drone_audio_service.dart`) from `PlayerMode.lowLatency` (Android `SoundPool`) to `PlayerMode.mediaPlayer` (Android `MediaPlayer`).
   - Android `MediaPlayer` is built for looping audio streams (`ReleaseMode.loop`), eliminating the 1 MB memory cap, stream stealing, and premature 2-second dropouts experienced with `SoundPool`.

2. **Clean Audio Source Lifecycle (Fixed Restart Silence on Same Key):**
   - Removed caching logic that bypassed `player.setSource(...)` when restarting the drone on the same root pitch key.
   - In `stopDrone()`, properly stopped and released player resources (`await _dronePlayer?.release()`).
   - In `startDrone()` and `startChordDrone()`, always configure and set the audio source cleanly before resuming playback.
   - Now, stopping the drone and starting it again on the same key sounds immediately without having to switch back and forth between keys.

3. **Smooth Mode and Variation Switching in Controls Sheet:**
   - Updated `_selectMode` in `PitchDroneControlsSheet` (`lib/widgets/pitch_drone_controls.dart`) to cleanly stop and restart audio on `_activeKey` with the newly chosen mode when switching between Classical (Shruti) and Western (Chords).
   - Updated `_selectChordQuality` and interval selection (`_selectDroneInterval`) to cleanly restart active audio on `_activeKey`.
   - Updated `PitchDroneNotifier` in `lib/providers/pitch_drone_provider.dart` to explicitly pass active mode and chord quality during live drone updates.

4. **Automated Tests:**
   - Added widget tests in `test/widgets/pitch_drone_controls_test.dart`:
     - Verified stopping the drone and restarting it on the same key sounds immediately.
     - Verified live switching between Western chord drone and Classical Shruti drone transitions seamlessly.

## Verification

- `flutter analyze`: 0 warnings, clean.
- `flutter test`: All 833 tests passing.
- `dart format .`: Clean.
