# Fix Pitch Drone Restart, Mode Switching, and Premature Stopping

**Status:** Proposed

## Issue

The user reported three related issues when using the Pitch Pipe & Shruti Box drone:
1. **Restart Failure on Same Key:** When stopping the drone and starting it again for the same Root Pitch Key, no sound plays. The user has to select another key and come back to get audio.
2. **Mode Switching Silence:** When switching between Classical (Shruti) and Western (Chords) modes, starting the drone does not play the selected key/mode until switching to another key.
3. **Premature Stopping:** Sometimes the Shruti drone stops quickly (after ~2 seconds) instead of looping continuously.

## Root Cause

1. **Stale Source Cache & Incompatible Seek on Stopped Audio Stream:**
   - In `PitchDroneAudioService`, `_loadedDronePath` cached the WAV path to avoid re-setting the source.
   - When `stopDrone()` is called, `_loadedDronePath` was not cleared.
   - When starting the drone again on the same key, `_loadedDronePath == file.path`, so `startDrone()` and `startChordDrone()` skipped `setSource()` and called `await player.seek(Duration.zero)` followed by `await player.resume()`.
   - On Android (and specifically in `PlayerMode.lowLatency`), calling `stop()` terminates the audio stream and resets native player state. `seek(0)` and `resume()` on a stopped player cannot restart playback without setting the source. This resulted in complete silence until a different key was selected (which forced `_loadedDronePath != file.path` and triggered `setSource()`).
2. **Mode Switching Re-use of Dead Stream:**
   - Switching between Classical and Western modes while playing or stopped did not properly reset the underlying audio player state.
   - If drone was playing, `setDroneMode` restarted playback using `state.selectedKey` rather than the sheet's active key.
3. **SoundPool (lowLatency) Is Unsuited for Continuous Drone Looping:**
   - `PitchDroneAudioService` used `PlayerMode.lowLatency` (Android `SoundPool`).
   - Android's `SoundPool` is designed for short sound effects (clicks, button taps, game effects). It has strict buffer limits (~1 MB max uncompressed) and low-priority stream handling that Android's audio server can terminate at loop boundaries or under memory/focus pressure.
   - This causes looping drone playback to abruptly stop after a single loop (~2 seconds).
   - In contrast, `PlayerMode.mediaPlayer` (Android `MediaPlayer`) is specifically designed for continuous media streaming and seamless looping (`mediaPlayer.isLooping = true`).

## Fix

1. **Switch `PitchDroneAudioService` Drone Player to `PlayerMode.mediaPlayer`:**
   - Change `_dronePlayer` mode from `PlayerMode.lowLatency` to `PlayerMode.mediaPlayer`.
   - Android `MediaPlayer` loops cleanly without SoundPool buffer constraints, stream stealing, or unexpected 2-second dropouts.
2. **Always Initialize Audio Source on Drone Start & Clean Up on Stop:**
   - In `stopDrone()`, stop and release the player resources, and clear `_loadedDronePath = null`.
   - In `startDrone()` and `startChordDrone()`, always configure and set the source cleanly:
     - `await player.stop();`
     - `await player.setPlayerMode(PlayerMode.mediaPlayer);`
     - `await player.setReleaseMode(ReleaseMode.loop);`
     - `await player.setVolume(_volume);`
     - `await player.setSource(DeviceFileSource(file.path));`
     - `await player.resume();`
   - This guarantees that restarting on the same key, changing pitch keys, or switching modes always loads and plays immediately.
3. **Ensure Smooth Mode & Key Switching in `PitchDroneControlsSheet`:**
   - In `PitchDroneControlsSheet._selectMode()`, if the drone is currently playing, smoothly transition by stopping the drone and restarting it with the current `_activeKey` and the newly selected mode.
   - In `PitchDroneControlsSheet._selectChordQuality()`, if playing in Western mode, smoothly restart with the new chord quality on `_activeKey`.
   - In `PitchDroneNotifier.setDroneMode()`, ensure the mode is explicitly applied during live drone restarts.

## Files to Change

- `lib/services/pitch_drone_audio_service.dart`:
  - Switch `_dronePlayer` to `PlayerMode.mediaPlayer`.
  - In `startDrone()` and `startChordDrone()`, always set the source cleanly on playback start.
  - In `stopDrone()`, release player and clear `_loadedDronePath`.
- `lib/widgets/pitch_drone_controls.dart`:
  - Ensure `_selectMode` and variation changes restart with `_activeKey` when drone is active.
- `lib/providers/pitch_drone_provider.dart`:
  - Ensure `setDroneMode` and `setChordQuality` correctly restart live audio with active parameters.
- `test/services/pitch_drone_audio_service_test.dart`:
  - Update or add tests verifying player mode, source loading, and stop/start lifecycle.
- `test/widgets/pitch_drone_controls_test.dart`:
  - Add test verifying stopping and restarting the drone on the same key.

## Verification

1. `flutter analyze`: ensure 0 warnings.
2. `flutter test`: ensure all tests pass.
3. Manual verification checklist:
   - Start drone on key C -> tap Stop Drone -> tap Start Drone on C: sound plays immediately.
   - Switch between Classical and Western tabs: audio plays properly on selected key.
   - Continuous playback: drone continues looping without cutting off after 2 seconds.
