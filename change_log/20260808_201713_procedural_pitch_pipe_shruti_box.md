# Change Log: Procedural Pitch Pipe, Shruti Box Drone, and Help Page

**Plan Reference:** [20260808_201544_procedural_pitch_pipe_shruti_box.md](../plans/20260808_201544_procedural_pitch_pipe_shruti_box.md)
**Date:** August 8, 2026

## Summary of Changes
Implemented Section 3.6 of the feature roadmap into **LyricChord**:
1. **Procedural Audio Synthesizer Service (`pcm_synth_service.dart`)**: Pure Dart 16-bit 44.1kHz PCM WAV audio generator porting multi-harmonic additive synthesis (`harmonicSample`), ADSR envelope shaping (`adsrEnvelope`), and 1.004 stereo chorus detuning from [`chronotune-smart-clock`](https://github.com/sreerajp80/chronotune-smart-clock) (`AudioEngine.kt`).
2. **Pitch Pipe & Shruti Box State & Provider (`pitch_drone_settings.dart` & `pitch_drone_provider.dart`)**: Managed root pitch selection (C through B), drone tuning intervals (Root+5th Pa vs Root+4th Ma), volume, and 5-tier stage text font scaling, persisted in `shared_preferences`.
3. **Stage Controls & Performance Integration (`pitch_drone_controls.dart`, `stage_hud.dart`, `song_performance_screen.dart`)**:
   - Added compact Pitch Pipe & Drone action button to the Stage HUD overlay bar.
   - Created interactive `PitchDroneControlsSheet` modal bottom sheet for trigger pitch cues, starting/stopping Shruti drones, and scaling stage font text (0.85x to 1.30x).
   - Applied dynamic font scaling to song sheets on stage.
4. **Settings Screen (`pitch_drone_settings_screen.dart` & `general_settings_screen.dart`)**: Added config page accessible via `Settings -> General -> Pitch Pipe & Shruti Drone`.
5. **Help Page Topic (`help_content.dart`)**: Added new Help topic titled **"Pitch Pipe & Shruti Drone"** (`id: 'pitch-pipe-drone'`) accessible under `Settings -> Help`.
6. **Unit Tests (`pcm_synth_service_test.dart`)**: Added comprehensive tests for note frequency mapping, RIFF WAV header output, ADSR envelope math, and stereo drone WAV generation.

## Verification
- `flutter analyze`: 0 warnings, 0 errors.
- `flutter test`: 341/341 tests passed.
