# Change Log — Stage Security & Quiet Performance Mode

**Plan Reference:** `plans/20260808_205600_stage_security_quiet_mode.md`

## Summary of Changes
Implemented **Stage Security (Stage Lock Mode)** and **Stage Quiet Performance Mode** in `LyricChord`:

1. **Stage Security (`StageSecurityService` & `local_auth`)**:
   - Added local biometric & device PIN/Pattern authentication using `local_auth` (^3.0.0), following patterns from [`SreerajP_Authenticator`](https://github.com/sreerajp80/sreerajp_authenticator).
   - Created `StageSecurityService` in `lib/services/stage_security_service.dart`.
   - Updated `StageModeState` and `StageModeNotifier` in `lib/providers/stage_mode_provider.dart` with `isLocked` state and `lockStage()` / `unlockStageWithAuth()` methods.
   - Updated `StageGestureLayer` in `lib/widgets/stage_gesture_layer.dart` to ignore stray HUD/speed taps when locked while keeping lyrics 100% visible, displaying a small, translucent floating `[🔒 Stage Locked]` badge at top-right to trigger biometric/PIN unlock.
   - Updated `SongPerformanceScreen` in `lib/screens/song_performance_screen.dart` to prompt auth unlock on back gesture when locked.

2. **Stage Quiet Mode (`StageQuietModeService` & `AudioManager`)**:
   - Added native `quiet_mode` MethodChannel in `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt` to mute/restore ringer and notification streams (`STREAM_RING`, `STREAM_NOTIFICATION`).
   - Created `StageQuietModeService` in `lib/services/stage_quiet_mode_service.dart`.
   - Integrated quiet mode lifecycle into `StageModeNotifier` when entering/exiting Stage Performance view.
   - Added Stage Lock and Stage Quiet Mode control buttons to `StageHud` in `lib/widgets/stage_hud.dart`.

3. **Documentation**:
   - Updated `docs/feature_analysis_and_innovations.md` (Section 2 Audit Matrix and Section 3.10) to mark Stage Lock & Stage Quiet Mode as `(✅ Implemented)` with GitHub URL reference to `https://github.com/sreerajp80/sreerajp_authenticator`.

4. **Testing**:
   - Added unit tests in `test/services/stage_security_service_test.dart` and `test/providers/stage_mode_provider_test.dart`. All 344 tests pass cleanly.

## Files Modified / Created
- `pubspec.yaml`
- `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`
- `lib/services/stage_security_service.dart` [NEW]
- `lib/services/stage_quiet_mode_service.dart` [NEW]
- `lib/providers/stage_mode_provider.dart`
- `lib/widgets/stage_hud.dart`
- `lib/widgets/stage_gesture_layer.dart`
- `lib/screens/song_performance_screen.dart`
- `docs/feature_analysis_and_innovations.md`
- `test/services/stage_security_service_test.dart` [NEW]
- `test/providers/stage_mode_provider_test.dart` [NEW]
