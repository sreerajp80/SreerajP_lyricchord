# Fix Melody Playback Truncation on Android

**Status:** completed

Date: 2026-09-03
Slug: `melody-playback-truncation-fix`

---

## 1. What the issue is

When playing a melody line (such as the 15-beat line for "Kākkē Kākkē"), sound cuts off midway through (around 5 to 6 seconds in), while the visual cursor keeps moving to the end.

### Cause

In `lib/services/melody_audio_service.dart`:
* The audio player is set to `PlayerMode.lowLatency`.
* On Android, `audioplayers` implements `PlayerMode.lowLatency` using Android's `SoundPool`.
* `SoundPool` stores audio in an uncompressed memory buffer with a hard limit of **1 MB**.
* At 44.1 kHz 16-bit stereo, 1 MB holds only about 5.6 to 5.9 seconds of audio.
* A melody line longer than 5 seconds (such as a 15-second line at 60 BPM, or any line at half speed) generates a WAV file larger than 1 MB.
* As a result, Android's `SoundPool` truncates playback after ~5.6 seconds or fails to play the remainder of the sound.

---

## 2. The fix

1. Switch `PlayerMode.lowLatency` in `lib/services/melody_audio_service.dart` to `PlayerMode.mediaPlayer`.
2. `PlayerMode.mediaPlayer` uses Android's standard `MediaPlayer`, which streams the file and does not have the 1 MB `SoundPool` memory limit. This allows melody lines of any duration to play completely.
3. Update the class doc comment to explain why `PlayerMode.mediaPlayer` is used instead of low-latency mode.

---

## 3. Files to change

| File | Change |
|---|---|
| `lib/services/melody_audio_service.dart` | Change `player.setPlayerMode(PlayerMode.lowLatency)` to `player.setPlayerMode(PlayerMode.mediaPlayer)`; update documentation. |

---

## 4. Verification plan

### Automated tests
* Run `flutter test` to ensure all existing widget, screen, and service tests pass cleanly without regression.
* Run `flutter analyze` to ensure zero warnings or errors.

### Manual checks
* Verify that long melody lines (e.g. 15–16 beats at 60 BPM and half speed) render and play through `MelodyAudioService` without truncation.
