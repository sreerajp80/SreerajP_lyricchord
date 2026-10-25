import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/pcm_synth_service.dart';

/// Tests the click *sound data*, not playback.
///
/// A unit test has no speaker, so playback itself is checked by hand on a device
/// (see the plan's verification list). What can be checked here is that the bytes
/// handed to the player are a real, well-formed WAV of the right length and that
/// the click actually fades to silence — the two things that would make the
/// player fail or the beat sound like a beep.
void main() {
  const synth = PcmSynthService();

  String tag(Uint8List bytes, int start) =>
      ascii.decode(bytes.sublist(start, start + 4));

  int readUint32(Uint8List bytes, int offset) =>
      ByteData.view(bytes.buffer).getUint32(offset, Endian.little);

  int readUint16(Uint8List bytes, int offset) =>
      ByteData.view(bytes.buffer).getUint16(offset, Endian.little);

  group('generateClickWav header', () {
    test('is a valid RIFF/WAVE file', () {
      final wav = synth.generateClickWav();
      expect(tag(wav, 0), 'RIFF');
      expect(tag(wav, 8), 'WAVE');
      expect(tag(wav, 12), 'fmt ');
      expect(tag(wav, 36), 'data');
    });

    test('is mono 16-bit PCM at 44.1 kHz', () {
      final wav = synth.generateClickWav();
      expect(readUint16(wav, 20), 1, reason: 'PCM format');
      expect(readUint16(wav, 22), 1, reason: 'mono — a beat sits centre');
      expect(readUint32(wav, 24), 44100);
      expect(readUint16(wav, 34), 16);
    });

    test('the declared data size matches the bytes actually written', () {
      final wav = synth.generateClickWav();
      // 30 ms at 44100 Hz, mono, 2 bytes per sample.
      const expectedSamples = 1323;
      expect(readUint32(wav, 40), expectedSamples * 2);
      expect(wav.length, 44 + expectedSamples * 2);
    });
  });

  group('generateClickWav sound', () {
    /// Reads the 16-bit samples after the 44-byte header.
    List<int> samplesOf(Uint8List wav) {
      final view = ByteData.view(wav.buffer);
      return [
        for (var offset = 44; offset < wav.length; offset += 2)
          view.getInt16(offset, Endian.little),
      ];
    }

    test('is short enough to finish before the fastest beat', () {
      // 300 BPM leaves 200 ms between beats; the click must be well inside that
      // or beats would run into each other.
      final wav = synth.generateClickWav();
      final samples = samplesOf(wav);
      final milliseconds = samples.length / 44100 * 1000;
      expect(milliseconds, lessThan(200));
    });

    test('starts quiet, peaks early, and dies away to near silence', () {
      final samples = samplesOf(synth.generateClickWav()).map((s) => s.abs());
      final list = samples.toList();

      // A click, not a beep: the loudest part is in the first half...
      final firstHalfPeak = list.take(list.length ~/ 2).reduce(math.max);
      final secondHalfPeak = list.skip(list.length ~/ 2).reduce(math.max);
      expect(firstHalfPeak, greaterThan(secondHalfPeak));

      // ...and the tail is effectively gone.
      expect(list.last, lessThan(firstHalfPeak * 0.05));
      // The very first sample rises from silence, so there is no hard edge.
      expect(list.first, lessThan(firstHalfPeak * 0.2));
    });

    test('the accent click is louder than a normal click', () {
      int peakOf(Uint8List wav) =>
          samplesOf(wav).map((s) => s.abs()).reduce(math.max);

      final normal = synth.generateClickWav(amplitude: 0.7);
      final accent = synth.generateClickWav(frequency: 1500, amplitude: 0.95);
      expect(peakOf(accent), greaterThan(peakOf(normal)));
    });

    test('never clips past the 16-bit limit', () {
      final samples = samplesOf(synth.generateClickWav(amplitude: 1.0));
      for (final sample in samples) {
        expect(sample, inInclusiveRange(-32768, 32767));
      }
    });
  });

  group('clickEnvelope', () {
    test('rises from silence and falls to near nothing', () {
      expect(PcmSynthService.clickEnvelope(0, 1000), 0.0);
      expect(PcmSynthService.clickEnvelope(1000, 1000), lessThan(0.05));
    });

    test('stays within 0 and 1', () {
      for (var i = 0; i <= 1000; i += 50) {
        expect(
          PcmSynthService.clickEnvelope(i, 1000),
          inInclusiveRange(0.0, 1.0),
        );
      }
    });

    test('a zero-length click is silent, not a crash', () {
      expect(PcmSynthService.clickEnvelope(0, 0), 0.0);
    });
  });
}
