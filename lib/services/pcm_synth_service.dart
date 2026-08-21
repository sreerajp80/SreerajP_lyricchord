import 'dart:math' as math;
import 'dart:typed_data';

/// One tone in a rendered run: a pitch and how long it sounds.
///
/// A frequency of zero is silence that still takes up its time.
class PcmTone {
  /// Pitch in Hz, or zero for silence.
  final double frequency;

  /// How long this tone lasts.
  final double durationSeconds;

  const PcmTone({required this.frequency, required this.durationSeconds});
}

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

  /// Percussive envelope for a metronome click: instant attack, fast fall to
  /// silence.
  ///
  /// [adsrEnvelope] is shaped for a long sung note (it sustains at 0.85), which
  /// would make a click sound like a short beep. A click needs the opposite: a
  /// ~1 ms rise so it starts sharply without a pop, then an exponential decay so
  /// it is gone before the next beat. Returns 0.0–1.0.
  static double clickEnvelope(int sampleIndex, int totalSamples) {
    if (totalSamples <= 0) return 0.0;
    final progress = (sampleIndex / totalSamples).clamp(0.0, 1.0);

    // A very short rise avoids the click starting on a hard edge (which is
    // heard as a crackle on some speakers).
    const attackPortion = 0.03;
    if (progress < attackPortion) return progress / attackPortion;

    // Exponential fall. The factor 9 leaves the tail near silence at the end.
    final decayProgress = (progress - attackPortion) / (1.0 - attackPortion);
    return math.exp(-9.0 * decayProgress).clamp(0.0, 1.0);
  }

  /// Synthesizes one short metronome click as WAV bytes.
  ///
  /// A click is not a note: it is a ~30 ms blip that must be over well before
  /// the next beat, even at a fast tempo (300 bpm leaves 200 ms). Mono, because
  /// a beat should sit in the middle and not wander between ears.
  ///
  /// [frequency] sets the pitch — use a higher value for the accented beat 1 so
  /// the ear can tell the bar start apart. [amplitude] is the peak level
  /// (0.0–1.0) before the player's own volume is applied.
  Uint8List generateClickWav({
    double frequency = 1000.0,
    double durationSeconds = 0.03,
    double amplitude = 0.8,
    int sampleRate = 44100,
  }) {
    final totalSamples = (sampleRate * durationSeconds).toInt();
    const channels = 1;
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
    final peak = 32767 * amplitude.clamp(0.0, 1.0);
    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      // Fundamental plus a quiet octave above: gives the click a bit of "tick"
      // edge so it cuts through a guitar or a room without being loud.
      final wave =
          (math.sin(2 * math.pi * frequency * t) +
              0.35 * math.sin(2 * math.pi * frequency * 2 * t)) /
          1.35;
      final sample = (wave * peak * clickEnvelope(i, totalSamples))
          .clamp(-32768, 32767)
          .toInt();
      bytes.setInt16(offset, sample, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Envelope for a looping drone: flat, with only a hair of fade at each end.
  ///
  /// [adsrEnvelope] is shaped for a note that begins and ends — it sinks to
  /// silence over the last 5% of its length. On a buffer that loops, that turns
  /// into a swell and dip on every pass, which a drone must not have: a drone is
  /// meant to sit still so the ear can lean on it.
  ///
  /// So this holds 1.0 the whole way and fades only over about 5 ms at each
  /// edge — long enough to stop the loop seam clicking, short enough that no
  /// one hears it. Returns 0.0–1.0.
  static double droneEnvelope(
    int sampleIndex,
    int totalSamples,
    int sampleRate,
  ) {
    if (totalSamples <= 0) return 0.0;

    final fade = math.min((sampleRate * 0.005).round(), totalSamples ~/ 2);
    if (fade <= 0) return 1.0;

    if (sampleIndex < fade) return sampleIndex / fade;
    final fromEnd = totalSamples - 1 - sampleIndex;
    if (fromEnd < fade) return (fromEnd / fade).clamp(0.0, 1.0);
    return 1.0;
  }

  /// Synthesizes a continuous Shruti Box drone WAV buffer (Sa + Pa/Ma).
  ///
  /// [interval]: 'Pa' (the fifth) or 'Ma' (the fourth).
  ///
  /// **Not a tanpura.** A tanpura has four strings plucked in a cycle and takes
  /// its shimmer from *jawari*, the string grazing a curved bridge. This is a
  /// steady reed-style drone — a shruti box.
  ///
  /// The default length is two seconds, which matters for two reasons. It is
  /// exactly three cycles of the 1.5 Hz tremolo, so the wobble lines up across
  /// the loop seam. And at 2 s the buffer is ~350 KB, which fits inside the
  /// roughly 1 MB a `SoundPool` sample is allowed — the drone has to play
  /// through SoundPool because the plain media player never starts on some
  /// devices (see `PitchDroneAudioService`).
  Uint8List generateShrutiDroneWav({
    required String noteKey,
    String interval = 'Pa',
    double durationSeconds = 2.0,
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
      final env = droneEnvelope(i, totalSamples, sampleRate);
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

  /// Renders a run of tones back to back as one WAV.
  ///
  /// Used by the melody player. One file for the whole line, rather than one
  /// file per note, because note timing has to be exact — starting a separate
  /// sound for each note leaves an audible, uneven gap between them.
  ///
  /// A tone with a frequency of zero renders as silence but still takes its
  /// time, so an unreadable beat leaves a gap in the right place instead of
  /// pulling every later note earlier.
  Uint8List generateSequenceWav({
    required List<PcmTone> tones,
    int sampleRate = 44100,
    double amplitude = 0.7,
  }) {
    const channels = 2;
    const bitsPerSample = 16;

    final counts = tones
        .map((t) => math.max(0, (sampleRate * t.durationSeconds).round()))
        .toList(growable: false);
    var totalSamples = 0;
    for (final count in counts) {
      totalSamples += count;
    }
    // An empty run still has to be a valid WAV, or the player reports a broken
    // file rather than simply staying quiet.
    if (totalSamples <= 0) totalSamples = 1;

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
    for (var t = 0; t < tones.length; t++) {
      final tone = tones[t];
      final count = counts[t];
      if (count <= 0) continue;

      for (var i = 0; i < count; i++) {
        var left = 0;
        var right = 0;

        if (tone.frequency > 0) {
          final env = adsrEnvelope(i, count);
          final amp = 32767 * amplitude * env;
          left = (harmonicSample(i, tone.frequency, sampleRate) * amp)
              .clamp(-32768, 32767)
              .toInt();
          right =
              (harmonicSample(i, tone.frequency * stereoDetune, sampleRate) *
                      amp)
                  .clamp(-32768, 32767)
                  .toInt();
        }

        bytes.setInt16(offset, left, Endian.little);
        offset += 2;
        bytes.setInt16(offset, right, Endian.little);
        offset += 2;
      }
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
