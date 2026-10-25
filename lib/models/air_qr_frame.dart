import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:lyricchord/core/logging/app_logger.dart';

/// Represents a single frame captured in an optical AirQR stream.
@immutable
class AirQrFrame {
  final String streamId;
  final int totalBlocks;
  final int sequenceIndex;
  final bool isParity;
  final int degree;
  final List<int> indices;
  final int checksum;
  final List<int> payloadBytes;

  const AirQrFrame({
    required this.streamId,
    required this.totalBlocks,
    required this.sequenceIndex,
    required this.isParity,
    required this.degree,
    required this.indices,
    required this.checksum,
    required this.payloadBytes,
  });

  /// Parses a raw scanned string into an AirQrFrame, or returns null if invalid.
  /// The most blocks one stream may claim. A whole songbook at 180 bytes a
  /// block is far below this; anything above is a bad or foreign code.
  static const int maxTotalBlocks = 4096;

  /// Whether the numbers in this frame can belong to a real stream.
  ///
  /// QR codes are untrusted input: an index outside the stream, a huge block
  /// count or an empty payload would otherwise be counted as progress and
  /// leave the receiver stuck.
  bool get isValid {
    if (streamId.isEmpty) return false;
    if (totalBlocks < 1 || totalBlocks > maxTotalBlocks) return false;
    if (payloadBytes.isEmpty) return false;
    if (!isParity) {
      return sequenceIndex >= 0 && sequenceIndex < totalBlocks;
    }
    if (indices.isEmpty || degree != indices.length) return false;
    if (indices.toSet().length != indices.length) return false;
    return indices.every((i) => i >= 0 && i < totalBlocks);
  }

  static AirQrFrame? parse(String raw) {
    if (!raw.startsWith('AIRQR|')) return null;

    final parts = raw.split('|');
    if (parts.length < 7) return null;

    try {
      final version = parts[1];
      final streamId = parts[2];
      final totalBlocks = int.parse(parts[3]);
      final checksum = int.parse(parts[5]);
      final payloadBytes = base64.decode(parts[6]);

      AirQrFrame? frame;
      if (version == 'v1') {
        final seqIndex = int.parse(parts[4]);
        frame = AirQrFrame(
          streamId: streamId,
          totalBlocks: totalBlocks,
          sequenceIndex: seqIndex,
          isParity: false,
          degree: 1,
          indices: [seqIndex],
          checksum: checksum,
          payloadBytes: payloadBytes,
        );
      } else if (version == 'LT1') {
        final degreeAndIndices = parts[4].split(':');
        final degree = int.parse(degreeAndIndices[0]);
        final indices = degreeAndIndices[1]
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.parse)
            .toList();

        frame = AirQrFrame(
          streamId: streamId,
          totalBlocks: totalBlocks,
          sequenceIndex: -1,
          isParity: true,
          degree: degree,
          indices: indices,
          checksum: checksum,
          payloadBytes: payloadBytes,
        );
      }
      if (frame != null && frame.isValid) return frame;
    } catch (e) {
      // A bad frame is normal while the camera reads a QR code; log its kind
      // only, never its content.
      AppLogger.debug('AirQrFrame parse error: ${e.runtimeType}');
    }
    return null;
  }

  /// Encodes this frame into string format suitable for rendering as a QR code.
  String toQrString() {
    final payloadBase64 = base64.encode(payloadBytes);
    if (!isParity) {
      return 'AIRQR|v1|$streamId|$totalBlocks|$sequenceIndex|$checksum|$payloadBase64';
    } else {
      final indicesCsv = indices.join(',');
      return 'AIRQR|LT1|$streamId|$totalBlocks|$degree:$indicesCsv|$checksum|$payloadBase64';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirQrFrame &&
          runtimeType == other.runtimeType &&
          streamId == other.streamId &&
          sequenceIndex == other.sequenceIndex &&
          isParity == other.isParity &&
          checksum == other.checksum;

  @override
  int get hashCode => Object.hash(streamId, sequenceIndex, isParity, checksum);
}
