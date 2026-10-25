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

  group('AirQR rejects impossible frames', () {
    String v1(String total, String seq, {String payload = 'SGVsbG8='}) =>
        'AIRQR|v1|123456|$total|$seq|1|$payload';

    test('block count must be between 1 and the maximum', () {
      expect(AirQrFrame.parse(v1('0', '0')), isNull);
      expect(AirQrFrame.parse(v1('-3', '0')), isNull);
      expect(
        AirQrFrame.parse(v1('${AirQrFrame.maxTotalBlocks + 1}', '0')),
        isNull,
      );
      expect(AirQrFrame.parse(v1('3', '2')), isNotNull);
    });

    test('a sequence index outside the stream is refused', () {
      expect(AirQrFrame.parse(v1('3', '3')), isNull);
      expect(AirQrFrame.parse(v1('3', '-1')), isNull);
    });

    test('an empty payload is refused', () {
      expect(AirQrFrame.parse(v1('3', '0', payload: '')), isNull);
    });

    test('parity indices must be in range, unique and match the degree', () {
      expect(AirQrFrame.parse('AIRQR|LT1|1|4|2:0,9|1|SGVsbG8='), isNull);
      expect(AirQrFrame.parse('AIRQR|LT1|1|4|2:1,1|1|SGVsbG8='), isNull);
      expect(AirQrFrame.parse('AIRQR|LT1|1|4|3:0,1|1|SGVsbG8='), isNull);
      expect(AirQrFrame.parse('AIRQR|LT1|1|4|2:0,1|1|SGVsbG8='), isNotNull);
    });

    test('junk frames never count as progress', () {
      final frames = AirQrService.encodePayload('Hello AirQR', blockSize: 8);
      final decoder = AirQrService();
      var progress = decoder.processFrameString(
        frames.first.toQrString(),
        const AirQrProgress(),
      );
      final received = progress.receivedBlockCount;

      // Same stream, but claims a different block count.
      final wrongCount = frames.first.toQrString().replaceFirst(
        '|${frames.first.totalBlocks}|',
        '|${frames.first.totalBlocks + 5}|',
      );
      progress = decoder.processFrameString(wrongCount, progress);
      expect(progress.receivedBlockCount, received);
      expect(progress.status, isNot(AirQrStatus.completed));
    });

    test('a damaged parity frame is ignored', () {
      const payload = 'Parity frames must pass their checksum too.';
      final frames = AirQrService.encodePayload(
        payload,
        blockSize: 16,
        extraParityRatioPercent: 100,
      );
      final systematic = frames.where((f) => !f.isParity).toList();
      final parity = frames.firstWhere((f) => f.degree == 2);

      final decoder = AirQrService();
      var progress = const AirQrProgress();
      // Feed every block except one the parity frame covers.
      final missing = parity.indices.first;
      for (final f in systematic.where((f) => f.sequenceIndex != missing)) {
        progress = decoder.processFrameString(f.toQrString(), progress);
      }
      final damaged = AirQrFrame(
        streamId: parity.streamId,
        totalBlocks: parity.totalBlocks,
        sequenceIndex: -1,
        isParity: true,
        degree: parity.degree,
        indices: parity.indices,
        checksum: parity.checksum ^ 1,
        payloadBytes: parity.payloadBytes,
      );
      progress = decoder.processFrameString(damaged.toQrString(), progress);
      expect(progress.status, AirQrStatus.receiving);
      expect(progress.capturedIndices, isNot(contains(missing)));
    });
  });
}
