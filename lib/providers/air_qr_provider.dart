import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/services/air_qr_service.dart';

class AirQrNotifier extends Notifier<AirQrProgress> {
  late final AirQrService _service;

  @override
  AirQrProgress build() {
    _service = AirQrService();
    return const AirQrProgress();
  }

  void processScannedCode(String raw) {
    // A finished or failed stream waits for resetStream(); more frames would
    // only repeat the same result.
    if (state.status == AirQrStatus.completed ||
        state.status == AirQrStatus.error) {
      return;
    }
    final updated = _service.processFrameString(raw, state);
    state = updated;
  }

  void resetStream() {
    _service.reset();
    state = const AirQrProgress();
  }
}

final airQrProvider = NotifierProvider<AirQrNotifier, AirQrProgress>(
  AirQrNotifier.new,
);
