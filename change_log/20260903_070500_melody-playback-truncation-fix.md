# Melody playback truncation fix

Date: 2026-09-03
Implements: [plans/20260903_070111_melody-playback-truncation-fix.md](../plans/20260903_070111_melody-playback-truncation-fix.md)

---

## What changed

Melody lines longer than 5 seconds were cutting off midway through on Android. This happened because the audio player used `PlayerMode.lowLatency` (Android `SoundPool`), which has an internal 1 MB limit for uncompressed audio.

`MelodyAudioService` now uses `PlayerMode.mediaPlayer` (Android `MediaPlayer`). This streams the rendered audio without the 1 MB memory restriction, allowing full playback of long melody lines and half-speed practice modes.

## Changed files

| File | Change |
|---|---|
| `lib/services/melody_audio_service.dart` | Switched player mode to `PlayerMode.mediaPlayer` and updated the class documentation. |

## Verification

* `flutter analyze` completed with 0 issues.
* `flutter test` passed for all melody widget and service tests.
