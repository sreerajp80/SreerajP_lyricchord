import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/models/air_qr_frame.dart';
import 'package:lyricchord/models/air_qr_progress.dart';
import 'package:lyricchord/services/air_qr_service.dart';

void main() {
  group('AirQrFrame Model Tests', () {
    test('Systematic v1 frame string parsing and formatting round-trip', () {
      const frame = AirQrFrame(
        streamId: '123456',
        totalBlocks: 3,
        sequenceIndex: 1,
        isParity: false,
        degree: 1,
        indices: [1],
        checksum: 987654321,
        payloadBytes: [72, 101, 108, 108, 111],
      );

      final qrString = frame.toQrString();
      expect(qrString, startsWith('AIRQR|v1|123456|3|1|987654321|'));

      final parsed = AirQrFrame.parse(qrString);
      expect(parsed, isNotNull);
      expect(parsed!.streamId, '123456');
      expect(parsed.totalBlocks, 3);
      expect(parsed.sequenceIndex, 1);
      expect(parsed.isParity, false);
      expect(parsed.checksum, 987654321);
      expect(parsed.payloadBytes, [72, 101, 108, 108, 111]);
    });

    test(
      'Fountain LT1 parity frame string parsing and formatting round-trip',
      () {
        const frame = AirQrFrame(
          streamId: '654321',
          totalBlocks: 4,
          sequenceIndex: -1,
          isParity: true,
          degree: 2,
          indices: [0, 2],
          checksum: 123456789,
          payloadBytes: [1, 2, 3, 4],
        );

        final qrString = frame.toQrString();
        expect(qrString, startsWith('AIRQR|LT1|654321|4|2:0,2|123456789|'));

        final parsed = AirQrFrame.parse(qrString);
        expect(parsed, isNotNull);
        expect(parsed!.streamId, '654321');
        expect(parsed.totalBlocks, 4);
        expect(parsed.isParity, true);
        expect(parsed.degree, 2);
        expect(parsed.indices, [0, 2]);
        expect(parsed.payloadBytes, [1, 2, 3, 4]);
      },
    );
  });

  group('AirQrService Encoding & Decoding Tests', () {
    test('CRC32 checksum produces expected deterministic values', () {
      final crc1 = AirQrService.computeCrc32([
        72,
        101,
        108,
        108,
        111,
      ]); // "Hello"
      final crc2 = AirQrService.computeCrc32([72, 101, 108, 108, 111]);
      final crcDiff = AirQrService.computeCrc32([
        87,
        111,
        114,
        108,
        100,
      ]); // "World"

      expect(crc1, equals(crc2));
      expect(crc1, isNot(equals(crcDiff)));
    });

    test('Encodes and reassembles small payload via systematic frames', () {
      const payload =
          '{title: Hotel California}\n{artist: Eagles}\n{key: Bm}\n{tempo: 75}\n\n[Bm]On a dark desert highway';
      final frames = AirQrService.encodePayload(payload, blockSize: 32);
      expect(frames.isNotEmpty, isTrue);

      final decoder = AirQrService();
      AirQrProgress progress = const AirQrProgress();

      for (final frame in frames) {
        progress = decoder.processFrameString(frame.toQrString(), progress);
        if (progress.status == AirQrStatus.completed) break;
      }

      expect(progress.status, AirQrStatus.completed);
      expect(progress.reassembledContent, equals(payload));
    });

    test('Fountain FEC recovers dropped systematic frames', () {
      const payload =
          'Multi-frame optical transfer payload with intentional packet loss recovery simulation.';
      final frames = AirQrService.encodePayload(
        payload,
        blockSize: 16,
        extraParityRatioPercent: 100,
      );

      final systematicFrames = frames.where((f) => !f.isParity).toList();
      final parityFrames = frames.where((f) => f.isParity).toList();

      expect(systematicFrames.length, greaterThan(1));
      expect(parityFrames.isNotEmpty, isTrue);

      final decoder = AirQrService();
      AirQrProgress progress = const AirQrProgress();

      // Pass all systematic frames except the first one (simulate 1 frame dropped)
      for (int i = 1; i < systematicFrames.length; i++) {
        progress = decoder.processFrameString(
          systematicFrames[i].toQrString(),
          progress,
        );
      }

      expect(progress.status, AirQrStatus.receiving);

      // Now supply parity frames until stream resolves
      for (final pFrame in parityFrames) {
        progress = decoder.processFrameString(pFrame.toQrString(), progress);
        if (progress.status == AirQrStatus.completed) break;
      }

      expect(progress.status, AirQrStatus.completed);
      expect(progress.reassembledContent, equals(payload));
    });
  });
}
