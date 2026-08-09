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
}
