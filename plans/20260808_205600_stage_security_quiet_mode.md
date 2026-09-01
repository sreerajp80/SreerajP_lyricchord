# Plan — Stage Security & Quiet Performance Mode

**Status:** completed

## Problem / Feature Context
In live performance settings, gigging musicians need protection against accidental touches (e.g. changing lyrics, transposing key, or exiting the stage view by mistake) and distractions from incoming calls or notification chimes.

This change implements:
1. **Stage Lock Mode**: Prevents accidental screen touches or exiting performance view via biometric/PIN authentication, leveraging patterns from [`SreerajP_Authenticator`](https://github.com/sreerajp80/sreerajp_authenticator).
2. **Stage Quiet Mode**: Automatically silences ringer and notification streams via native `AudioManager` MethodChannel while performance mode is active.

## Proposed Changes

- `pubspec.yaml`: Add `local_auth: ^3.0.0`.
- `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`: Add `in.sreerajp.lyricchord/quiet_mode` MethodChannel for ringer/notification mute/unmute.
- `lib/services/stage_security_service.dart`: Authentication service leveraging `local_auth`.
- `lib/services/stage_quiet_mode_service.dart`: Quiet mode service controlling native ringer/notification stream muting.
- `lib/providers/stage_mode_provider.dart`: Add `isLocked` and `isQuietModeActive` state and notifier actions.
- `lib/widgets/stage_hud.dart`: Add lock toggle and quiet mode indicators/buttons.
- `lib/widgets/stage_gesture_layer.dart`: Touch interception when locked, triggering biometric/PIN auth to unlock.
- `lib/screens/song_performance_screen.dart`: Wire stage lock overlay and quiet mode lifecycle.
- `docs/feature_analysis_and_innovations.md`: Update Section 2 Audit Matrix and Section 3.10 to `(✅ Implemented)` with GitHub URL `https://github.com/sreerajp80/sreerajp_authenticator`.

## Verification
- Run `flutter analyze` and `flutter test`.
- Verify Stage Lock toggle and unlock authentication.
- Verify Stage Quiet Mode ringer mute/restore.
