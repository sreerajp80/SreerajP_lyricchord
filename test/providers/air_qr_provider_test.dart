import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/providers/air_qr_provider.dart';
import 'package:lyricchord/services/air_qr_service.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  AirQrProgress read() => container.read(airQrProvider);
  AirQrNotifier notifier() => container.read(airQrProvider.notifier);

  /// The systematic (non-parity) frames of [payload], as QR strings.
  List<String> systematicFrames(String payload) => [
    for (final frame in AirQrService.encodePayload(payload, blockSize: 20))
      if (!frame.isParity) frame.toQrString(),
  ];

  const payload =
      '{title: Amazing Grace}\n[G]Amazing [G7]Grace, how [C]sweet the [G]sound';

  test('starts idle with nothing received', () {
    expect(read().status, AirQrStatus.idle);
    expect(read().receivedBlockCount, 0);
  });

  test('counts frames as they arrive, then finishes with the text', () {
    final frames = systematicFrames(payload);
    expect(frames.length, greaterThan(1));

    notifier().processScannedCode(frames.first);
    expect(read().status, AirQrStatus.receiving);
    expect(read().receivedBlockCount, 1);
    expect(read().totalBlocks, frames.length);

    for (final frame in frames.skip(1)) {
      notifier().processScannedCode(frame);
    }
    expect(read().status, AirQrStatus.completed);
    expect(read().reassembledContent, payload);
  });

  test('a repeated frame does not count twice', () {
    final frames = systematicFrames(payload);

    notifier().processScannedCode(frames.first);
    notifier().processScannedCode(frames.first);

    expect(read().receivedBlockCount, 1);
  });

  test('a foreign or broken QR code changes nothing', () {
    notifier().processScannedCode('https://example.com');
    notifier().processScannedCode('AIRQR|v1|garbage');

    expect(read().status, AirQrStatus.idle);
    expect(read().receivedBlockCount, 0);
  });

  test('frames after completion are ignored until reset', () {
    final frames = systematicFrames(payload);
    for (final frame in frames) {
      notifier().processScannedCode(frame);
    }
    expect(read().status, AirQrStatus.completed);

    final other = systematicFrames('{title: Other}\n[C]other song text here');
    notifier().processScannedCode(other.first);
    expect(read().reassembledContent, payload);

    notifier().resetStream();
    expect(read().status, AirQrStatus.idle);

    notifier().processScannedCode(other.first);
    expect(read().status, AirQrStatus.receiving);
  });
}
