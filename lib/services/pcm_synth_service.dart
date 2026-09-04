import 'dart:math' as math;
import 'dart:typed_data';

/// One tone in a rendered run: a pitch and how long it sounds.
///
/// A frequency of zero is silence that still takes up its time.
class PcmTone {
  /// Pitch in Hz, or zero for silence. Where a glide ends up.
  final double frequency;

  /// Where a glide starts, in Hz, or `null` for a tone that holds one pitch.
  ///
  /// This is the slide (`!`, jaru) written in a melody line. The glide runs over
  /// the opening of the tone and then settles on [frequency] — see
  /// [PcmSynthService.slidePortion].
  final double? fromFrequency;

  /// How long this tone lasts.
  final double durationSeconds;

  /// How fast the pitch swings, in Hz, or `null` for a tone that holds still.
  ///
  /// This is the shake (`~`, kampita) written in a melody line. The caller sets
  /// the rate, because the rate is metrical and only the caller knows the tempo
  /// — see `MelodyPlayerService.shakeHzFor`.
  final double? shakeHz;

  /// How far the swing reaches above [frequency], in semitones.
  final double shakeDepthSemitones;

  const PcmTone({
    required this.frequency,
    required this.durationSeconds,
    this.fromFrequency,
    this.shakeHz,
    this.shakeDepthSemitones = 0,
  });

  /// True when this tone glides rather than holding one pitch.
  bool get slides =>
      fromFrequency != null && fromFrequency! > 0 && frequency > 0;

  /// True when this tone's pitch swings.
  bool get shakes =>
      (shakeHz ?? 0) > 0 && shakeDepthSemitones > 0 && frequency > 0;

  /// True when the pitch moves at all, and so must be rendered by stepping the
  /// wave's angle rather than from absolute time.
  bool get pitchMoves => slides || shakes;
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

  /// The same four harmonics as [harmonicSample], but read off an angle that
  /// the caller advances itself.
  ///
  /// A gliding tone cannot use [harmonicSample]. That one computes
  /// `sin(2 * pi * freq * t)` from absolute time, and if `freq` changes with `t`
  /// the pitch actually heard is `freq + t * dFreq/dt` — a linear glide would
  /// sweep at roughly twice the rate asked for, and every step would click.
  /// Stepping the angle by `2 * pi * freq / sampleRate` each sample keeps the
  /// wave continuous and the pitch honest.
  ///
  /// The harmonics are multiples of the same angle, so the timbre holds together
  /// through the glide.
  static double harmonicSampleAtPhase(double phase) {
    final f1 = math.sin(phase) * 1.0;
    final f2 = math.sin(2 * phase) * 0.5;
    final f3 = math.sin(3 * phase) * 0.25;
    final f4 = math.sin(4 * phase) * 0.125;
    return (f1 + f2 + f3 + f4) / 1.875;
  }

  /// How much of a gliding tone the glide takes, before it settles.
  static const double slidePortion = 0.30;

  /// The longest a glide may run, however long the note is.
  ///
  /// Without this a held note would glide lazily for half a second instead of
  /// scooping into pitch.
  static const double slideMaxSeconds = 0.12;

  /// The pitch part-way through a glide, [progress] running 0 to 1.
  ///
  /// Interpolates **in semitones**, not in hertz. Pitch is logarithmic, so a
  /// glide that is straight in hertz drags at the bottom and rushes at the top.
  static double slideFrequency(double from, double to, double progress) {
    final p = progress.clamp(0.0, 1.0);
    if (from <= 0 || to <= 0) return to;
    return from * math.pow(to / from, p);
  }

  /// How much of a shaken tone is sung plain before the swing starts.
  ///
  /// The written note has to be established first, or the ear hears a wobbly
  /// synthesizer instead of a note that is being shaken.
  static const double shakeOnsetPortion = 0.15;

  /// The longest that plain onset may run, however long the note is.
  static const double shakeOnsetMaxSeconds = 0.06;

  /// The pitch multiplier for a shake, [seconds] into the tone.
  ///
  /// Returns `1.0` (the written note) through the onset, then swings **up to**
  /// [depthSemitones] above the note and back, over and over. It never goes
  /// below `1.0`: a kampita written on a note should still sound like that
  /// note, so the written pitch is the floor the swing leaves from, not the
  /// middle it wobbles around.
  ///
  /// `(1 - cos) / 2` is what gives that shape — it runs 0 → 1 → 0 and leaves
  /// from rest, so there is no jump at the moment the swing begins. The depth
  /// also ramps in over the first swing, so the shake grows rather than
  /// switching on.
  static double shakeFactor(
    double seconds,
    double totalSeconds, {
    required double rateHz,
    required double depthSemitones,
  }) {
    if (rateHz <= 0 || depthSemitones <= 0 || totalSeconds <= 0) return 1.0;

    final onset = math.min(
      totalSeconds * shakeOnsetPortion,
      shakeOnsetMaxSeconds,
    );
    final t = seconds - onset;
    if (t <= 0) return 1.0;

    // One full swing takes 1 / rateHz, and the depth ramps in across it.
    final swing = 1.0 / rateHz;
    final ramp = swing <= 0 ? 1.0 : (t / swing).clamp(0.0, 1.0);

    final shape = (1 - math.cos(2 * math.pi * rateHz * t)) / 2;
    return math.pow(2, depthSemitones * ramp * shape / 12).toDouble();
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

  /// Nudges [freq] onto the nearest pitch that completes a whole number of
  /// cycles inside a [durationSeconds] buffer.
  ///
  /// A looped buffer restarts its wave at phase 0 every pass. That only joins up
  /// silently if the tone fits whole cycles in the buffer — otherwise the last
  /// sample and the first sit at different points of the wave, and the step
  /// between them is heard as a click on every loop. C over 2 s is 523.26
  /// cycles; it is that leftover 0.26 that clicks.
  ///
  /// A buffer `D` seconds long repeats `1 / D` times a second, so every whole
  /// multiple of `1 / D` Hz is safe. Rounding to that grid moves the pitch by at
  /// most `1 / (2 * D)` Hz — under 2 cents at 4 seconds, which no ear hears and
  /// which is far less than the 0.4% stereo detune the drone already uses on
  /// purpose.
  ///
  /// The 2nd, 3rd and 4th harmonics in [harmonicSample] are whole multiples of
  /// the fundamental, so snapping the fundamental lands them on the grid too.
  static double snapToLoopGrid(double freq, double durationSeconds) {
    if (freq <= 0 || durationSeconds <= 0) return freq;
    final cycles = (freq * durationSeconds).round();
    if (cycles <= 0) return freq;
    return cycles / durationSeconds;
  }

  /// Synthesizes a continuous Shruti Box drone WAV buffer (Sa + Pa/Ma).
  ///
  /// [interval]: 'Pa' (the fifth) or 'Ma' (the fourth).
  ///
  /// **Not a tanpura.** A tanpura has four strings plucked in a cycle and takes
  /// its shimmer from *jawari*, the string grazing a curved bridge. This is a
  /// steady reed-style drone — a shruti box.
  ///
  /// **This buffer is made to loop.** Everything it plays is snapped onto the
  /// loop grid by [snapToLoopGrid], so the end of the buffer joins its own start
  /// with no step in the wave, and there is deliberately **no fade** at either
  /// edge. A fade would be right for a sound that plays once; on a loop it digs
  /// a hole of silence into the hum on every pass, which is exactly what a drone
  /// must not do. Nothing pops at the start either: every partial is a `sin()`
  /// beginning at phase 0, so the buffer already opens at zero.
  ///
  /// The default length is four seconds. It is a whole six cycles of the 1.5 Hz
  /// tremolo, so the wobble also lines up across the seam, and the longer the
  /// buffer the finer the loop grid (0.25 Hz here) and the fewer the seams. Size
  /// is not a worry: the drone plays through `PlayerMode.mediaPlayer`, which
  /// streams from the file (see `PitchDroneAudioService`).
  Uint8List generateShrutiDroneWav({
    required String noteKey,
    String interval = 'Pa',
    double durationSeconds = 4.0,
    int sampleRate = 44100,
  }) {
    final rawRoot = getFrequency(noteKey);
    final rawSecond = (interval.toLowerCase() == 'ma')
        ? rawRoot *
              (4.0 / 3.0) // Fourth (Ma)
        : rawRoot * (1.5); // Fifth (Pa)

    // Each voice is snapped on its own — the detuned right channel included, or
    // that channel alone would click at the seam.
    final rootFreq = snapToLoopGrid(rawRoot, durationSeconds);
    final rootFreqRight = snapToLoopGrid(
      rawRoot * stereoDetune,
      durationSeconds,
    );
    final secondFreq = snapToLoopGrid(rawSecond, durationSeconds);
    final secondFreqRight = snapToLoopGrid(
      rawSecond * stereoDetune,
      durationSeconds,
    );

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
      // No envelope: see the note on looping above. Gentle 1.5 Hz amplitude
      // modulation simulating string vibration, whole cycles in the buffer.
      final tremolo =
          0.85 + 0.15 * math.sin(2 * math.pi * 1.5 * (i / sampleRate));
      final amp = 32767 * 0.45 * tremolo;

      final rootHarmonicLeft = harmonicSample(i, rootFreq, sampleRate);
      final rootHarmonicRight = harmonicSample(i, rootFreqRight, sampleRate);
      final secHarmonicLeft = harmonicSample(i, secondFreq, sampleRate);
      final secHarmonicRight = harmonicSample(i, secondFreqRight, sampleRate);

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

  /// Synthesizes a continuous Western backing chord drone WAV buffer (Root + 3rd + 5th + Bass).
  ///
  /// [noteKey]: Root note pitch (e.g. 'C', 'F#', 'Bb').
  /// [isMinor]: `false` for Major triad, `true` for Minor triad.
  ///
  /// Combines a gentle bass root (octave below), root, major or minor third,
  /// and fifth with stereo detuning.
  ///
  /// Like [generateShrutiDroneWav] this buffer is made to loop: every voice is
  /// snapped onto the loop grid and there is no fade at either edge. See that
  /// method for why.
  Uint8List generateWesternChordDroneWav({
    required String noteKey,
    bool isMinor = false,
    double durationSeconds = 4.0,
    int sampleRate = 44100,
  }) {
    final rawRoot = getFrequency(noteKey);
    final rawBass = rawRoot * 0.5;
    final rawThird = rawRoot * math.pow(2.0, (isMinor ? 3.0 : 4.0) / 12.0);
    final rawFifth = rawRoot * math.pow(2.0, 7.0 / 12.0);

    // Every voice, and every detuned right-channel copy, on the loop grid.
    final rootFreq = snapToLoopGrid(rawRoot, durationSeconds);
    final rootFreqRight = snapToLoopGrid(
      rawRoot * stereoDetune,
      durationSeconds,
    );
    final bassFreq = snapToLoopGrid(rawBass, durationSeconds);
    final bassFreqRight = snapToLoopGrid(
      rawBass * stereoDetune,
      durationSeconds,
    );
    final thirdFreq = snapToLoopGrid(rawThird, durationSeconds);
    final thirdFreqRight = snapToLoopGrid(
      rawThird * stereoDetune,
      durationSeconds,
    );
    final fifthFreq = snapToLoopGrid(rawFifth, durationSeconds);
    final fifthFreqRight = snapToLoopGrid(
      rawFifth * stereoDetune,
      durationSeconds,
    );

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
      // No envelope: this buffer loops. See generateShrutiDroneWav.
      final tremolo =
          0.88 + 0.12 * math.sin(2 * math.pi * 1.5 * (i / sampleRate));
      final amp = 32767 * 0.45 * tremolo;

      final bassLeft = harmonicSample(i, bassFreq, sampleRate);
      final bassRight = harmonicSample(i, bassFreqRight, sampleRate);

      final rootLeft = harmonicSample(i, rootFreq, sampleRate);
      final rootRight = harmonicSample(i, rootFreqRight, sampleRate);

      final thirdLeft = harmonicSample(i, thirdFreq, sampleRate);
      final thirdRight = harmonicSample(i, thirdFreqRight, sampleRate);

      final fifthLeft = harmonicSample(i, fifthFreq, sampleRate);
      final fifthRight = harmonicSample(i, fifthFreqRight, sampleRate);

      final mixedLeft =
          (bassLeft * 0.28 +
              rootLeft * 0.32 +
              thirdLeft * 0.22 +
              fifthLeft * 0.22) /
          1.04;
      final mixedRight =
          (bassRight * 0.28 +
              rootRight * 0.32 +
              thirdRight * 0.22 +
              fifthRight * 0.22) /
          1.04;

      final leftSample = (mixedLeft * amp).clamp(-32768, 32767).toInt();
      final rightSample = (mixedRight * amp).clamp(-32768, 32767).toInt();

      bytes.setInt16(offset, leftSample, Endian.little);
      offset += 2;
      bytes.setInt16(offset, rightSample, Endian.little);
      offset += 2;
    }

    return bytes.buffer.asUint8List();
  }

  /// Synthesizes a 2-second reference Western chord cue with ADSR envelope.
  Uint8List generateWesternChordCueWav({
    required String noteKey,
    bool isMinor = false,
    double durationSeconds = 2.0,
    int sampleRate = 44100,
  }) {
    final rootFreq = getFrequency(noteKey);
    final bassFreq = rootFreq * 0.5;
    final thirdFreq = rootFreq * math.pow(2.0, (isMinor ? 3.0 : 4.0) / 12.0);
    final fifthFreq = rootFreq * math.pow(2.0, 7.0 / 12.0);

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
      final amp = 32767 * 0.65 * env;

      final bassLeft = harmonicSample(i, bassFreq, sampleRate);
      final bassRight = harmonicSample(i, bassFreq * stereoDetune, sampleRate);

      final rootLeft = harmonicSample(i, rootFreq, sampleRate);
      final rootRight = harmonicSample(i, rootFreq * stereoDetune, sampleRate);

      final thirdLeft = harmonicSample(i, thirdFreq, sampleRate);
      final thirdRight = harmonicSample(
        i,
        thirdFreq * stereoDetune,
        sampleRate,
      );

      final fifthLeft = harmonicSample(i, fifthFreq, sampleRate);
      final fifthRight = harmonicSample(
        i,
        fifthFreq * stereoDetune,
        sampleRate,
      );

      final mixedLeft =
          (bassLeft * 0.28 +
              rootLeft * 0.32 +
              thirdLeft * 0.22 +
              fifthLeft * 0.22) /
          1.04;
      final mixedRight =
          (bassRight * 0.28 +
              rootRight * 0.32 +
              thirdRight * 0.22 +
              fifthRight * 0.22) /
          1.04;

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

      // A tone whose pitch moves — a glide, a shake, or both — steps its own
      // angle; a steady one keeps the original time-based path so its samples
      // come out exactly as they always have.
      final moves = tone.pitchMoves;
      final glides = tone.slides;
      final shakes = tone.shakes;
      final glideSamples = glides
          ? math.min(
              (count * slidePortion).round(),
              (sampleRate * slideMaxSeconds).round(),
            )
          : 0;
      var phaseLeft = 0.0;
      var phaseRight = 0.0;

      for (var i = 0; i < count; i++) {
        var left = 0;
        var right = 0;

        if (tone.frequency > 0) {
          final env = adsrEnvelope(i, count);
          final amp = 32767 * amplitude * env;

          if (moves) {
            // Where the glide has reached, or the settled pitch once it is over.
            final glided = !glides || i >= glideSamples || glideSamples <= 0
                ? tone.frequency
                : slideFrequency(
                    tone.fromFrequency!,
                    tone.frequency,
                    i / glideSamples,
                  );

            // The shake rides on top, so a note can slide into pitch and then
            // be shaken — which `M2!G3~` has always been allowed to say.
            final freq = shakes
                ? glided *
                      shakeFactor(
                        i / sampleRate,
                        tone.durationSeconds,
                        rateHz: tone.shakeHz!,
                        depthSemitones: tone.shakeDepthSemitones,
                      )
                : glided;

            left = (harmonicSampleAtPhase(phaseLeft) * amp)
                .clamp(-32768, 32767)
                .toInt();
            right = (harmonicSampleAtPhase(phaseRight) * amp)
                .clamp(-32768, 32767)
                .toInt();
            phaseLeft += 2 * math.pi * freq / sampleRate;
            phaseRight += 2 * math.pi * freq * stereoDetune / sampleRate;
          } else {
            left = (harmonicSample(i, tone.frequency, sampleRate) * amp)
                .clamp(-32768, 32767)
                .toInt();
            right =
                (harmonicSample(i, tone.frequency * stereoDetune, sampleRate) *
                        amp)
                    .clamp(-32768, 32767)
                    .toInt();
          }
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
