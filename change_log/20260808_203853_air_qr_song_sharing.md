# AirQR Peer-to-Peer Offline Song Sharing Change Log

**Plan Reference:** [plans/20260808_203026_air_qr_song_sharing.md](plans/20260808_203026_air_qr_song_sharing.md)

## Summary of Changes
Implemented **3.1 AirQR Peer-to-Peer Offline Song Sharing** in `LyricChord`, porting the optical Fountain error correction stream encoder and decoder algorithms from `sreeraj_qr_reader`. Bandmates on stage can now instantly share single songs, selected songs, or entire setlists screen-to-camera with zero internet, Bluetooth, or Wi-Fi setup required.

### Added / Modified Files

1. **[pubspec.yaml](pubspec.yaml)**
   - Added `qr_flutter: ^4.1.0` (for high-contrast vector QR code rendering).
   - Added `mobile_scanner: ^6.0.4` (for live camera QR decoding).
   - Added `image_picker: ^1.1.2` (for scanning QR codes from gallery photos).

2. **[air_qr_frame.dart](lib/models/air_qr_frame.dart)**
   - Data model for AirQR systematic (`AIRQR|v1|...`) and Fountain parity (`AIRQR|LT1|...`) frames.

3. **[air_qr_progress.dart](lib/models/air_qr_progress.dart)**
   - Progress data model tracking captured block matrix, missing blocks, FPS, and status (`receiving`, `completed`, `error`).

4. **[air_qr_service.dart](lib/services/air_qr_service.dart)**
   - Logic engine handling payload chunking, systematic & LT Fountain frame encoding (`encodePayload`), CRC32 checksum generation, and stream reassembly (`processFrameString`, `_reducePendingParityFrames`).

5. **[air_qr_provider.dart](lib/providers/air_qr_provider.dart)**
   - Riverpod `airQrProvider` managing receiver stream state and frame processing.

6. **[air_qr_transmitter_screen.dart](lib/screens/air_qr_transmitter_screen.dart)**
   - Screen rendering animated high-density QR sequences with stream speed slider (5–25 FPS), pause/resume control, and frame statistics HUD.

7. **[air_qr_receiver_screen.dart](lib/screens/air_qr_receiver_screen.dart)**
   - Camera scanner screen using `MobileScanner` with live FPS readout, block matrix HUD, flash toggle, camera switch, gallery photo scan button, and automatic redirection to `ImportPreviewScreen` upon complete payload reassembly.

8. **[app_router.dart](lib/core/router/app_router.dart)**
   - Registered `/air-qr-transmit` and `/air-qr-receive` routes.

9. **[import_export_screen.dart](lib/screens/import_export_screen.dart)**
   - Added "AirQR Scan Import (Camera / Photo)" and "Export all songs via AirQR Stream" options.

10. **[song_performance_screen.dart](lib/screens/song_performance_screen.dart)**
    - Added "AirQR Stream (Animated QR)" option to the share dialog.

11. **[setlist_detail_screen.dart](lib/screens/setlist_detail_screen.dart)**
    - Added "Share Setlist via AirQR Stream" button in the app bar.

12. **[song_list_screen.dart](lib/screens/song_list_screen.dart)**
    - Added "Scan AirQR Song" quick action button in the main app bar and "Share selected via AirQR" in selection mode.

13. **[air_qr_service_test.dart](test/services/air_qr_service_test.dart)**
    - Created unit tests covering frame parsing, CRC32 checksums, stream encoding/reassembly, and Fountain FEC packet loss recovery.

14. **[docs/feature_analysis_and_innovations.md](docs/feature_analysis_and_innovations.md)**
    - Updated Section 2 Implementation Audit Matrix and Section 3.1 detailing AirQR implementation.

## Verification
- Static Analysis: `flutter analyze` completed with 0 warnings/errors.
- Unit Testing: `flutter test` passed all 346 tests cleanly, including `air_qr_service_test.dart`.
