import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/pcm_synth_service.dart';

void main() {
  group('PcmSynthService Tests', () {
    const synth = PcmSynthService();

    test('getFrequency resolves note names correctly', () {
      expect(PcmSynthService.getFrequency('A'), equals(440.0));
      expect(PcmSynthService.getFrequency('C'), equals(261.63));
      expect(PcmSynthService.getFrequency('G#'), equals(415.30));
      expect(PcmSynthService.getFrequency('Cmaj7'), equals(261.63));
      expect(PcmSynthService.getFrequency('G/B'), equals(392.00));
    });

    test('harmonicSample output stays bounded within [-1.0, 1.0]', () {
      for (var i = 0; i < 1000; i++) {
        final sample = PcmSynthService.harmonicSample(i, 440.0, 44100);
        expect(sample, greaterThanOrEqualTo(-1.0));
        expect(sample, lessThanOrEqualTo(1.0));
      }
    });

    test('adsrEnvelope returns values between 0.0 and 1.0', () {
      const total = 1000;
      expect(PcmSynthService.adsrEnvelope(0, total), equals(0.0));
      expect(PcmSynthService.adsrEnvelope(500, total), greaterThan(0.5));
      expect(PcmSynthService.adsrEnvelope(1000, total), equals(0.0));
    });

    test(
      'generatePitchCueWav creates valid RIFF WAV header and data bytes',
      () {
        final wav = synth.generatePitchCueWav(
          noteKey: 'A',
          durationSeconds: 0.1,
        );

        // Header length (44 bytes) + data length
        expect(wav.length, greaterThan(44));

        // Verify 'RIFF' magic bytes
        expect(String.fromCharCodes(wav.sublist(0, 4)), equals('RIFF'));
        // Verify 'WAVE' format
        expect(String.fromCharCodes(wav.sublist(8, 12)), equals('WAVE'));
        // Verify 'fmt ' chunk
        expect(String.fromCharCodes(wav.sublist(12, 16)), equals('fmt '));
        // Verify 'data' chunk
        expect(String.fromCharCodes(wav.sublist(36, 40)), equals('data'));
      },
    );

    test('generateShrutiDroneWav creates stereo PCM drone WAV', () {
      final wavPa = synth.generateShrutiDroneWav(
        noteKey: 'C',
        interval: 'Pa',
        durationSeconds: 0.1,
      );
      final wavMa = synth.generateShrutiDroneWav(
        noteKey: 'C',
        interval: 'Ma',
        durationSeconds: 0.1,
      );

      expect(wavPa.length, greaterThan(44));
      expect(wavMa.length, greaterThan(44));

      final viewPa = ByteData.view(wavPa.buffer);
      // Sample rate at offset 24
      expect(viewPa.getUint32(24, Endian.little), equals(44100));
      // Channels at offset 22 (stereo = 2)
      expect(viewPa.getUint16(22, Endian.little), equals(2));
    });
  });

  group('a gliding tone', () {
    const synth = PcmSynthService();
    const rate = 44100;

    /// Rough frequency of a window of samples, by counting zero crossings.
    ///
    /// Enough to tell 220 Hz from 440 Hz without pulling in an FFT.
    double freqOf(Uint8List wav, int fromSample, int sampleCount) {
      final data = ByteData.sublistView(wav);
      const headerBytes = 44;
      var crossings = 0;
      var previous = 0;
      for (var i = 0; i < sampleCount; i++) {
        // Stereo 16-bit: four bytes per frame, left channel first.
        final at = headerBytes + (fromSample + i) * 4;
        if (at + 1 >= wav.length) break;
        final sample = data.getInt16(at, Endian.little);
        if (i > 0 &&
            ((previous < 0 && sample >= 0) || (previous >= 0 && sample < 0))) {
          crossings++;
        }
        previous = sample;
      }
      return crossings * rate / (2 * sampleCount);
    }

    test('starts near the low pitch and ends on the target', () {
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(frequency: 440, fromFrequency: 220, durationSeconds: 1),
        ],
        sampleRate: rate,
      );

      // The glide is short, so sample right at the start for the low pitch and
      // well past it for the target.
      final early = freqOf(wav, 200, 1200);
      final late = freqOf(wav, rate ~/ 2, 4000);

      expect(early, lessThan(380), reason: 'should still be gliding up');
      expect(late, closeTo(440, 40), reason: 'should have settled on target');
    });

    test('the glide is short, not a lazy sweep over the whole note', () {
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(frequency: 440, fromFrequency: 220, durationSeconds: 2),
        ],
        sampleRate: rate,
      );

      // Capped at slideMaxSeconds, so a two-second note is on pitch long before
      // halfway.
      final atQuarter = freqOf(wav, rate ~/ 2, 4000);
      expect(atQuarter, closeTo(440, 40));
    });

    test('a glide down works as well as a glide up', () {
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(frequency: 220, fromFrequency: 440, durationSeconds: 1),
        ],
        sampleRate: rate,
      );

      expect(freqOf(wav, 200, 1200), greaterThan(240));
      expect(freqOf(wav, rate ~/ 2, 4000), closeTo(220, 25));
    });

    test('the wave stays continuous through the glide — no clicks', () {
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(frequency: 880, fromFrequency: 220, durationSeconds: 1),
        ],
        sampleRate: rate,
      );
      final data = ByteData.sublistView(wav);

      // A phase jump shows up as one enormous step between neighbouring
      // samples. At 880 Hz and 44.1 kHz a real waveform moves a few percent of
      // full scale per sample, so anything near full scale is a click.
      var biggestStep = 0;
      var previous = data.getInt16(44, Endian.little);
      for (var i = 1; i < 20000; i++) {
        final sample = data.getInt16(44 + i * 4, Endian.little);
        final step = (sample - previous).abs();
        if (step > biggestStep) biggestStep = step;
        previous = sample;
      }
      expect(biggestStep, lessThan(12000));
    });

    test('a tone with no glide is byte-identical to before', () {
      // The drone, metronome click and pitch cue share this synthesiser. If a
      // steady tone changed at all, one of them would have changed too.
      final plain = synth.generateSequenceWav(
        tones: const [
          PcmTone(frequency: 440, durationSeconds: 0.25),
          PcmTone(frequency: 0, durationSeconds: 0.1),
          PcmTone(frequency: 330, durationSeconds: 0.25),
        ],
        sampleRate: rate,
      );

      // Rebuilt the same way, so any accidental dependence on order or state
      // inside the loop would show up here.
      final again = synth.generateSequenceWav(
        tones: const [
          PcmTone(frequency: 440, durationSeconds: 0.25),
          PcmTone(frequency: 0, durationSeconds: 0.1),
          PcmTone(frequency: 330, durationSeconds: 0.25),
        ],
        sampleRate: rate,
      );

      expect(plain, equals(again));
      // And a steady tone matches the time-based path exactly.
      final data = ByteData.sublistView(plain);
      for (final i in [0, 1, 500, 5000]) {
        final expected =
            (PcmSynthService.harmonicSample(i, 440, rate) *
                    32767 *
                    0.7 *
                    PcmSynthService.adsrEnvelope(i, (rate * 0.25).round()))
                .clamp(-32768, 32767)
                .toInt();
        expect(data.getInt16(44 + i * 4, Endian.little), expected);
      }
    });

    test('slideFrequency moves in semitones, not hertz', () {
      // Halfway from 220 to 880 is two octaves up in pitch terms, so the middle
      // is 440 — not the 550 a straight line in hertz would give.
      expect(PcmSynthService.slideFrequency(220, 880, 0.5), closeTo(440, 0.5));
      expect(PcmSynthService.slideFrequency(220, 880, 0), closeTo(220, 0.001));
      expect(PcmSynthService.slideFrequency(220, 880, 1), closeTo(880, 0.001));
    });

    test('a zero or missing start pitch is not a glide', () {
      expect(const PcmTone(frequency: 440, durationSeconds: 1).slides, isFalse);
      expect(
        const PcmTone(
          frequency: 440,
          fromFrequency: 0,
          durationSeconds: 1,
        ).slides,
        isFalse,
      );
    });
  });

  group('a shaken tone', () {
    const synth = PcmSynthService();
    const rate = 44100;

    /// Rough frequency of a window of samples, by counting zero crossings.
    double freqOf(Uint8List wav, int fromSample, int sampleCount) {
      final data = ByteData.sublistView(wav);
      const headerBytes = 44;
      var crossings = 0;
      var previous = 0;
      for (var i = 0; i < sampleCount; i++) {
        final at = headerBytes + (fromSample + i) * 4;
        if (at + 1 >= wav.length) break;
        final sample = data.getInt16(at, Endian.little);
        if (i > 0 &&
            ((previous < 0 && sample >= 0) || (previous >= 0 && sample < 0))) {
          crossings++;
        }
        previous = sample;
      }
      return crossings * rate / (2 * sampleCount);
    }

    double factorAt(double seconds, {double total = 1.0}) =>
        PcmSynthService.shakeFactor(
          seconds,
          total,
          rateHz: 5,
          depthSemitones: 1,
        );

    group('shakeFactor', () {
      test('the onset is the plain note', () {
        expect(factorAt(0), 1.0);
        expect(factorAt(0.01), 1.0);
      });

      test('it never dips below the written note', () {
        // The written note is the floor the swing leaves from, not the middle
        // it wobbles around — a kampita on Ga must still sound like Ga.
        for (var i = 0; i <= 400; i++) {
          expect(
            factorAt(i / 200),
            greaterThanOrEqualTo(1.0),
            reason: 'at ${i / 200}s',
          );
        }
      });

      test('it reaches the full depth and comes back', () {
        // One swing is 200 ms at 5 Hz, so peaks sit 100 ms into each swing.
        // Measured past the ramp, where the depth is fully open.
        const onset = 0.06;
        final peak = factorAt(onset + 0.5);
        final rest = factorAt(onset + 0.6);

        // A semitone is 2^(1/12) = 1.0595.
        expect(peak, closeTo(1.0595, 0.002));
        expect(rest, closeTo(1.0, 0.002));
      });

      test('the depth ramps in over the first swing', () {
        // Half a swing in, the ramp is only half open, so the first peak is
        // shallower than the ones after it.
        const onset = 0.06;
        final firstPeak = factorAt(onset + 0.1);
        final laterPeak = factorAt(onset + 0.5);
        expect(firstPeak, lessThan(laterPeak));
      });

      test('a rate or depth of zero is not a shake', () {
        expect(
          PcmSynthService.shakeFactor(0.5, 1, rateHz: 0, depthSemitones: 1),
          1.0,
        );
        expect(
          PcmSynthService.shakeFactor(0.5, 1, rateHz: 5, depthSemitones: 0),
          1.0,
        );
      });
    });

    test('a zero rate or depth does not make a tone shake', () {
      expect(const PcmTone(frequency: 440, durationSeconds: 1).shakes, isFalse);
      expect(
        const PcmTone(frequency: 440, durationSeconds: 1, shakeHz: 5).shakes,
        isFalse,
      );
      expect(
        const PcmTone(
          frequency: 440,
          durationSeconds: 1,
          shakeHz: 5,
          shakeDepthSemitones: 1,
        ).shakes,
        isTrue,
      );
    });

    test('the rendered pitch moves, and stays around the note', () {
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(
            frequency: 440,
            durationSeconds: 1,
            shakeHz: 5,
            shakeDepthSemitones: 1,
          ),
        ],
        sampleRate: rate,
      );

      // Sampled a quarter of a swing apart, the pitch should differ audibly
      // while staying inside the note-to-note+1-semitone band (466 Hz).
      final windows = [
        for (var i = 0; i < 8; i++) freqOf(wav, 8000 + i * 2200, 2000),
      ];

      final low = windows.reduce((a, b) => a < b ? a : b);
      final high = windows.reduce((a, b) => a > b ? a : b);

      expect(high - low, greaterThan(4), reason: 'the pitch should move');
      expect(low, greaterThan(425), reason: 'never far below the note');
      expect(high, lessThan(485), reason: 'never above the next key');
    });

    test('a shaken wave stays continuous — no clicks', () {
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(
            frequency: 880,
            durationSeconds: 1,
            shakeHz: 8,
            shakeDepthSemitones: 1,
          ),
        ],
        sampleRate: rate,
      );
      final data = ByteData.sublistView(wav);

      var biggestStep = 0;
      var previous = data.getInt16(44, Endian.little);
      for (var i = 1; i < 20000; i++) {
        final sample = data.getInt16(44 + i * 4, Endian.little);
        final step = (sample - previous).abs();
        if (step > biggestStep) biggestStep = step;
        previous = sample;
      }
      expect(biggestStep, lessThan(12000));
    });

    test('a tone can slide and shake at once', () {
      // `M2!G3~` has always been writable; until now nothing could render it.
      final wav = synth.generateSequenceWav(
        tones: const [
          PcmTone(
            frequency: 440,
            fromFrequency: 220,
            durationSeconds: 1,
            shakeHz: 5,
            shakeDepthSemitones: 1,
          ),
        ],
        sampleRate: rate,
      );

      // Still gliding at the very start, and shaking around the note later.
      expect(freqOf(wav, 200, 1200), lessThan(380));
      expect(freqOf(wav, rate ~/ 2, 4000), closeTo(450, 30));
    });

    test('a steady tone is untouched by the shake code', () {
      // The drone, click and pitch cue share this synthesiser, so a tone that
      // does not shake must come out exactly as it always has.
      final wav = synth.generateSequenceWav(
        tones: const [PcmTone(frequency: 440, durationSeconds: 0.25)],
        sampleRate: rate,
      );
      final data = ByteData.sublistView(wav);

      for (final i in [0, 1, 500, 5000]) {
        final expected =
            (PcmSynthService.harmonicSample(i, 440, rate) *
                    32767 *
                    0.7 *
                    PcmSynthService.adsrEnvelope(i, (rate * 0.25).round()))
                .clamp(-32768, 32767)
                .toInt();
        expect(data.getInt16(44 + i * 4, Endian.little), expected);
      }
    });
  });
}
