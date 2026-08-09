# Plan: Procedural Pitch Pipe & Shruti Box Drone with 5-Tier Font Scale

**Status:** Awaiting Approval

## Issue / Goal
Implement Section 3.6 of the feature roadmap using technology ported directly from `chronotune-smart-clock` (`AudioEngine.kt`):
1. **Procedural Pitch Pipe Cuer:** A 2-second synthesized pure/harmonic tone cue for vocalists to find their starting note before singing.
2. **Shruti Box Generator:** Real-time synthesized continuous Tanpura/Shruti drone (Root + 5th / Root + 4th) in any key (C through B) for Indian classical or acoustic practice.
3. **5-Tier Dynamic Font Scale:** Dynamic text scaling (0.85x, 0.95x, 1.00x, 1.15x, 1.30x) for stage screen readability.
4. **Help Topic:** Create a detailed user help section in `Settings -> Help`.

## Ported Technology from `chronotune-smart-clock` (`AudioEngine.kt`)
- **Multi-Harmonic Additive Synthesis:** Porting `harmonicSample()` to sum fundamental frequency $f$, 2nd harmonic ($2f$), 3rd harmonic ($3f$), and 4th harmonic ($4f$) with decaying weights ($1.0, 0.5, 0.25, 0.125$) to create realistic Tanpura string / reed overtone warmth.
- **ADSR Envelope Shaping:** Porting `adsrEnvelope()` (Attack, Decay, Sustain, Release) to smooth tone starts and stops, eliminating digital click artifacts.
- **Stereo Chorus Detune:** Porting 1.004x right-channel stereo detune (`stereoDetune = 1.004`) for rich spatial acoustic depth.
- **Equal-Power Looping:** Seamlessly crossfading 4-second PCM 16-bit 44.1kHz stereo WAV buffer loops for continuous background drone playback.

## Security & Architecture Compliance
- **100% Offline:** Audio synthesis is performed 100% programmatically in Dart math code. No network packages, no network I/O, no `INTERNET` permission.
- **Layer Architecture:** `Service` handles audio synthesis math -> `Provider` holds state -> `Widget` renders UI -> `HelpContent` documents feature.

## Proposed Changes

### Dependencies
#### [MODIFY] [pubspec.yaml](../pubspec.yaml)
- Add `audioplayers: ^6.1.0` for offline playing of dynamically synthesized local PCM WAV byte streams.

### Models & Services
#### [NEW] [pcm_synth_service.dart](../lib/services/pcm_synth_service.dart)
- Pure Dart PCM 16-bit 44.1kHz audio generator porting `chronotune-smart-clock` algorithms.
- Generates 2.0s pitch pipe WAV bytes for notes C4 (261.63Hz) to B4 (493.88Hz) with ADSR envelope.
- Generates seamless looping WAV buffers for Shruti Box drone (Root + 5th / Root + 4th) with 4-part harmonic overtones and 1.004 stereo chorus detune.

#### [NEW] [pitch_drone_settings.dart](../lib/models/pitch_drone_settings.dart)
- Data model for pitch/drone configuration (key, drone interval, volume, font scale tier).

#### [NEW] [pitch_drone_provider.dart](../lib/providers/pitch_drone_provider.dart)
- Riverpod notifier holding active drone state & font scale, persisted in `shared_preferences`.

### UI & Widgets
#### [NEW] [pitch_drone_controls.dart](../lib/widgets/pitch_drone_controls.dart)
- Interactive Pitch Pipe button & Shruti Box drone toggle sheet/bar with key selector (C to B) and interval selector (Root+5th / Root+4th).

#### [MODIFY] [stage_hud.dart](../lib/widgets/stage_hud.dart)
- Add Pitch Pipe cue button, Shruti Box drone toggle button, and 5-Tier Font Scale controls to the stage overlay.

#### [MODIFY] [song_performance_screen.dart](../lib/screens/song_performance_screen.dart)
- Apply 5-Tier Dynamic Font Scale (0.85x to 1.30x) to lyrics/chords display.
- Stop active drone when navigating away or closing performance mode.

### Settings & Help
#### [NEW] [pitch_drone_settings_screen.dart](../lib/screens/pitch_drone_settings_screen.dart)
- Config screen accessible via `Settings -> General -> Pitch Pipe & Shruti Drone`.

#### [MODIFY] [general_settings_screen.dart](../lib/screens/general_settings_screen.dart)
- Add menu item pointing to Pitch Pipe & Shruti Drone settings.

#### [MODIFY] [help_content.dart](../lib/screens/help/help_content.dart)
- Add `HelpTopic` with `id: 'pitch-pipe-drone'`, title `'Pitch Pipe & Shruti Drone'`, with sections covering Pitch Pipe cues, Shruti Box drones, and 5-Tier Stage Font Scaling.

### Testing
#### [NEW] [pcm_synth_service_test.dart](../test/services/pcm_synth_service_test.dart)
- Unit tests verifying pitch note frequencies, RIFF WAV header output validity, ADSR math, and drone buffer generation.

## Verification Plan
1. Run `dart run build_runner build --delete-conflicting-outputs`
2. Run `flutter analyze` to ensure 0 warnings.
3. Run `flutter test` to verify pcm_synth_service tests.
