import 'dart:math' as math;
import 'dart:typed_data';

/// Procedural PCM 16-bit stereo/mono audio synthesizer.
///
/// Ported directly from `chronotune-smart-clock` (`AudioEngine.kt`).
/// Generates raw WAV audio bytes in pure Dart without external sound assets.
class PcmSynthService {
  const PcmSynthService();

  /// Standard note frequencies (Octave 4) in Hz.
  static const Map<String, double> noteFrequencies = {
    'C': 261.63,
    'C#': 277.18,
    'Db': 277.18,
    'D': 293.66,
    'D#': 311.13,
    'Eb': 311.13,
    'E': 329.63,
    'F': 349.23,
    'F#': 369.99,
    'Gb': 369.99,
    'G': 392.00,
    'G#': 415.30,
    'Ab': 415.30,
    'A': 440.00,
    'A#': 466.16,
    'Bb': 466.16,
    'B': 493.88,
  };

  /// Right channel stereo detune factor (0.4% detune) for wide acoustic depth.
  static const double stereoDetune = 1.004;

  /// Returns fundamental frequency for a note key name.
  static double getFrequency(String key) {
    // Take the root note before slash in slash chords like 'G/B' -> 'G'
    final rootPart = key.split('/')[0].trim();
    final match = RegExp(r'^[A-G][#b]?').firstMatch(rootPart);
    if (match == null) return noteFrequencies['C']!;
    final rootNote = match.group(0)!;
    final upper =
        rootNote[0].toUpperCase() +
        (rootNote.length > 1 ? rootNote.substring(1) : '');
    return noteFrequencies[upper] ?? noteFrequencies['C']!;
  }

  /// Calculates a multi-harmonic additive sample in [-1.0, 1.0].
  /// Sums fundamental (1.0), 2nd (0.5), 3rd (0.25), and 4th (0.125) harmonics.
  static double harmonicSample(int sampleIndex, double freq, int sampleRate) {
    final t = sampleIndex / sampleRate;
    final f1 = math.sin(2 * math.pi * freq * t) * 1.0;
    final f2 = math.sin(2 * math.pi * (2 * freq) * t) * 0.5;
    final f3 = math.sin(2 * math.pi * (3 * freq) * t) * 0.25;
    final f4 = math.sin(2 * math.pi * (4 * freq) * t) * 0.125;
    return (f1 + f2 + f3 + f4) / 1.875;
  }

  /// ADSR (Attack, Decay, Sustain, Release) envelope multiplier [0.0, 1.0].
  static double adsrEnvelope(int sampleIndex, int totalSamples) {
    if (totalSamples <= 0) return 0.0;
    final progress = (sampleIndex / totalSamples).clamp(0.0, 1.0);

    const attackPortion = 0.05;
    const decayPortion = 0.10;
    const releasePortion = 0.05;
    const sustainLevel = 0.85;

    double env;
    if (progress < attackPortion) {
      env = progress / attackPortion;
    } else if (progress < attackPortion + decayPortion) {
      final decayProgress = (progress - attackPortion) / decayPortion;
      env = 1.0 - (1.0 - sustainLevel) * decayProgress;
    } else if (progress < 1.0 - releasePortion) {
      env = sustainLevel;
    } else {
      final releaseProgress =
          (progress - (1.0 - releasePortion)) / releasePortion;
      env = sustainLevel * (1.0 - releaseProgress);
    }
    return env.clamp(0.0, 1.0);
  }

  /// Synthesizes a 2-second pure/harmonic vocal pitch pipe cue note as WAV bytes.
  Uint8List generatePitchCueWav({
    required String noteKey,
    double durationSeconds = 2.0,
    int sampleRate = 44100,
  }) {
    final freq = getFrequency(noteKey);
    final totalSamples = (sampleRate * durationSeconds).toInt();
    const channels = 2;
    const bitsPerSample = 16;
    final dataSize = totalSamples * channels * (bitsPerSample ~/ 8);

    final header = _buildWavHeader(
      dataLength: dataSize,
      sampleRate: sampleRate,
      channels: channels,
      bitsPerSample: bitsPerSample,
    );

    final bytes = ByteData(header.length + dataSize);
    // Write header
    for (var i = 0; i < header.length; i++) {
      bytes.setUint8(i, header[i]);
    }

    var offset = header.length;
    for (var i = 0; i < totalSamples; i++) {
      final env = adsrEnvelope(i, totalSamples);
      final amp = 32767 * 0.7 * env;

      final leftSample = (harmonicSample(i, freq, sampleRate) * amp)
          .clamp(-32768, 32767)
          .toInt();
      final rightSample =
          (harmonicSample(i, freq * stereoDetune, sampleRate) * amp)
              .clamp(-32768, 32767)
              .toInt();

      bytes.setInt16(offset, leftSample, Endian.little);
      offset += 2;
      bytes.setInt16(offset, rightSample, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Synthesizes a continuous Tanpura / Shruti Box drone WAV buffer (Root + Pa/Ma).
  ///
  /// [interval]: 'Pa' (5th) or 'Ma' (4th).
  Uint8List generateShrutiDroneWav({
    required String noteKey,
    String interval = 'Pa',
    double durationSeconds = 4.0,
    int sampleRate = 44100,
  }) {
    final rootFreq = getFrequency(noteKey);
    final secondFreq = (interval.toLowerCase() == 'ma')
        ? rootFreq *
              (4.0 / 3.0) // Fourth (Ma)
        : rootFreq * (1.5); // Fifth (Pa)

    final totalSamples = (sampleRate * durationSeconds).toInt();
    const channels = 2;
    const bitsPerSample = 16;
    final dataSize = totalSamples * channels * (bitsPerSample ~/ 8);

    final header = _buildWavHeader(
      dataLength: dataSize,
      sampleRate: sampleRate,
      channels: channels,
      bitsPerSample: bitsPerSample,
    );

    final bytes = ByteData(header.length + dataSize);
    for (var i = 0; i < header.length; i++) {
      bytes.setUint8(i, header[i]);
    }

    var offset = header.length;
    for (var i = 0; i < totalSamples; i++) {
      final env = adsrEnvelope(i, totalSamples);
      // Gentle subtle 1.5Hz amplitude modulation simulating string vibration
      final tremolo =
          0.85 + 0.15 * math.sin(2 * math.pi * 1.5 * (i / sampleRate));
      final amp = 32767 * 0.45 * env * tremolo;

      final rootHarmonicLeft = harmonicSample(i, rootFreq, sampleRate);
      final rootHarmonicRight = harmonicSample(
        i,
        rootFreq * stereoDetune,
        sampleRate,
      );
      final secHarmonicLeft = harmonicSample(i, secondFreq, sampleRate);
      final secHarmonicRight = harmonicSample(
        i,
        secondFreq * stereoDetune,
        sampleRate,
      );

      final mixedLeft = (rootHarmonicLeft + secHarmonicLeft) * 0.5;
      final mixedRight = (rootHarmonicRight + secHarmonicRight) * 0.5;

      final leftSample = (mixedLeft * amp).clamp(-32768, 32767).toInt();
      final rightSample = (mixedRight * amp).clamp(-32768, 32767).toInt();

      bytes.setInt16(offset, leftSample, Endian.little);
      offset += 2;
      bytes.setInt16(offset, rightSample, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Builds a standard 44-byte RIFF WAV header.
  Uint8List _buildWavHeader({
    required int dataLength,
    required int sampleRate,
    required int channels,
    required int bitsPerSample,
  }) {
    final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final blockAlign = channels * (bitsPerSample ~/ 8);
    final totalLength = dataLength + 36;

    final header = Uint8List(44);
    final b = ByteData.view(header.buffer);

    // RIFF chunk descriptor
    b.setUint8(0, 0x52); // 'R'
    b.setUint8(1, 0x49); // 'I'
    b.setUint8(2, 0x46); // 'F'
    b.setUint8(3, 0x46); // 'F'
    b.setUint32(4, totalLength, Endian.little);
    b.setUint8(8, 0x57); // 'W'
    b.setUint8(9, 0x41); // 'A'
    b.setUint8(10, 0x56); // 'V'
    b.setUint8(11, 0x45); // 'E'

    // 'fmt ' sub-chunk
    b.setUint8(12, 0x66); // 'f'
    b.setUint8(13, 0x6d); // 'm'
    b.setUint8(14, 0x74); // 't'
    b.setUint8(15, 0x20); // ' '
    b.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    b.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    b.setUint16(22, channels, Endian.little);
    b.setUint32(24, sampleRate, Endian.little);
    b.setUint32(28, byteRate, Endian.little);
    b.setUint16(32, blockAlign, Endian.little);
    b.setUint16(34, bitsPerSample, Endian.little);

    // 'data' sub-chunk
    b.setUint8(36, 0x64); // 'd'
    b.setUint8(37, 0x61); // 'a'
    b.setUint8(38, 0x74); // 't'
    b.setUint8(39, 0x61); // 'a'
    b.setUint32(40, dataLength, Endian.little);

    return header;
  }
}
