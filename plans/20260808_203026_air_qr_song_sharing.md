# AirQR Peer-to-Peer Offline Song Sharing Plan

**Status:** Approved

## Issue / Goal
Implement 3.1 AirQR Peer-to-Peer Offline Song Sharing in `LyricChord` by integrating animated multi-frame high-density QR chunking & decoding algorithms adapted from `sreeraj_qr_reader`.
This enables 100% offline, zero-network instant song and setlist sharing between bandmates on stage via screen-to-camera optical stream transfer.

---

## Files to Add / Modify

### 1. Dependencies
- **[pubspec.yaml](pubspec.yaml)**
  - Add `qr_flutter: ^4.1.0` (for rendering high-density QR code frames on transmitter screen).
  - Add `mobile_scanner: ^6.0.4` (for live camera QR decoding on receiver screen).
  - Add `image_picker: ^1.1.2` (for scanning QR from gallery photo).

### 2. Core Models & Services
- **[air_qr_frame.dart](lib/models/air_qr_frame.dart)**
  - Model representing single systematic (`v1`) and Fountain parity (`LT1`) AirQR frames, with base64 payload decoding/encoding and string parsing.
- **[air_qr_progress.dart](lib/models/air_qr_progress.dart)**
  - Data model tracking stream decoding progress (blocks received, total blocks, FPS, status, reassembled content).
- **[air_qr_service.dart](lib/services/air_qr_service.dart)**
  - `AirQrService`: High-performance systematic stream & LT Fountain error-correction encoder (`encodePayload`) and decoder (`processFrameString`, `_reducePendingParityFrames`). Uses standard CRC32 checksums for frame verification.
- **[air_qr_provider.dart](lib/providers/air_qr_provider.dart)**
  - Riverpod provider (`airQrProvider`) for managing receiver stream state, frame accumulation, and reassembled song payload processing.

### 3. UI Screens & Features
- **[air_qr_transmitter_screen.dart](lib/screens/air_qr_transmitter_screen.dart)**
  - Screen displaying animated high-density QR sequence for selected song(s) or setlist. Includes stream speed slider (5-25 FPS), pause/resume button, and frame index stats.
- **[air_qr_receiver_screen.dart](lib/screens/air_qr_receiver_screen.dart)**
  - Live camera HUD scanner screen. Displays realtime FPS, block matrix HUD, flash toggle, camera switch, gallery image scan button, and automatically navigates to `ImportPreviewScreen` upon complete payload reassembly.

### 4. Integration Points
- **[app_router.dart](lib/core/router/app_router.dart)**
  - Add `/air-qr-transmit` and `/air-qr-receive` routes.
- **[import_export_screen.dart](lib/screens/import_export_screen.dart)**
  - Add "AirQR Optical Scan Import" and "AirQR Optical Share Export" tiles.
- **[song_performance_screen.dart](lib/screens/song_performance_screen.dart)**
  - Add "Share Song via AirQR" menu action.
- **[setlist_detail_screen.dart](lib/screens/setlist_detail_screen.dart)**
  - Add "Share Setlist via AirQR" menu action in setlist app bar.
- **[home_shell.dart](lib/screens/home_shell.dart)**
  - Add "Scan AirQR Song" action button on home app bar / drawer.

### 5. Unit Tests
- **[air_qr_service_test.dart](test/services/air_qr_service_test.dart)**
  - Unit tests covering:
    - Base64 & string frame parsing/formatting.
    - CRC32 checksum calculation.
    - Systematic & Fountain frame stream encoding and reassembly.
    - Handling out-of-order frames and packet loss recovery.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero static analysis errors or warnings.
- Run `flutter test` to execute all unit tests including the new `air_qr_service_test.dart`.

### Manual Verification
- Verify that song / setlist text converted to ChordPro streams smoothly on screen via animated QR codes.
- Verify camera scanner HUD receives frames and displays reassembled preview cleanly.
