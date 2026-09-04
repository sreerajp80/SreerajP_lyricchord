import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/services/pitch_drone_audio_service.dart';

/// These tests run with no audio plugin, so every real playback call fails.
///
/// That is exactly the situation worth pinning down. The old code let such a
/// failure vanish into an un-awaited future and still told the UI it was
/// playing, which is how a completely silent feature looked like it worked.
/// Here the service must swallow the error, say `false`, and never throw.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pitch_drone_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempDir.path,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a failing device reports false instead of throwing', () async {
    final service = PitchDroneAudioService();
    addTearDown(service.dispose);

    await expectLater(
      service.startDrone(noteKey: 'G', interval: 'Pa'),
      completion(isFalse),
    );
    await expectLater(service.playCue('G'), completion(isFalse));
  });

  test(
    'stopping and setting volume never throw, even with no player',
    () async {
      final service = PitchDroneAudioService();
      addTearDown(service.dispose);

      await expectLater(service.stopDrone(), completes);
      await expectLater(service.setVolume(0.5), completes);
    },
  );

  test('each key and interval gets its own file', () async {
    // audioplayers caches a source by its path. Reusing one name is why a
    // changed key could keep sounding the old note.
    final service = PitchDroneAudioService();
    addTearDown(service.dispose);

    await service.startDrone(noteKey: 'G', interval: 'Pa');
    await service.startDrone(noteKey: 'C#', interval: 'Pa');
    await service.startDrone(noteKey: 'G', interval: 'Ma');
    await service.playCue('A');

    final names =
        tempDir.listSync().map((e) => e.uri.pathSegments.last).toList()..sort();

    expect(names, [
      'pitch_cue_A.wav',
      'shruti_drone_v2_Csharp_Pa.wav',
      'shruti_drone_v2_G_Ma.wav',
      'shruti_drone_v2_G_Pa.wav',
    ]);
  });

  test('the written drone file is a valid stereo 44.1 kHz WAV', () async {
    final service = PitchDroneAudioService();
    addTearDown(service.dispose);

    await service.startDrone(noteKey: 'G', interval: 'Pa');

    final file = File('${tempDir.path}/shruti_drone_v2_G_Pa.wav');
    expect(file.existsSync(), isTrue);

    final bytes = file.readAsBytesSync();
    final header = ByteData.sublistView(bytes);

    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
    expect(header.getUint16(20, Endian.little), 1, reason: 'PCM');
    expect(header.getUint16(22, Endian.little), 2, reason: 'stereo');
    expect(header.getUint32(24, Endian.little), 44100);
    expect(header.getUint16(34, Endian.little), 16, reason: '16-bit');
    // RIFF size must be the rest of the file after the first 8 bytes.
    expect(header.getUint32(4, Endian.little), bytes.length - 8);
  });

  test('a file already on disk is not rebuilt', () async {
    final service = PitchDroneAudioService();
    addTearDown(service.dispose);

    await service.startDrone(noteKey: 'G', interval: 'Pa');
    final file = File('${tempDir.path}/shruti_drone_v2_G_Pa.wav');
    final firstWrite = file.lastModifiedSync();

    await service.startDrone(noteKey: 'G', interval: 'Pa');

    expect(file.lastModifiedSync(), firstWrite);
  });

  test(
    'Western chord drone and cue generate valid distinct WAV files',
    () async {
      final service = PitchDroneAudioService();
      addTearDown(service.dispose);

      await service.startChordDrone(noteKey: 'C', isMinor: false);
      await service.startChordDrone(noteKey: 'A', isMinor: true);
      await service.playChordCue(noteKey: 'E', isMinor: false);

      final names =
          tempDir.listSync().map((e) => e.uri.pathSegments.last).toList()
            ..sort();

      expect(names, [
        'western_chord_cue_E_major.wav',
        'western_chord_drone_v2_A_minor.wav',
        'western_chord_drone_v2_C_major.wav',
      ]);

      final file = File('${tempDir.path}/western_chord_drone_v2_C_major.wav');
      expect(file.existsSync(), isTrue);

      final bytes = file.readAsBytesSync();
      final header = ByteData.sublistView(bytes);

      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
      expect(header.getUint16(20, Endian.little), 1, reason: 'PCM');
      expect(header.getUint16(22, Endian.little), 2, reason: 'stereo');
      expect(header.getUint32(24, Endian.little), 44100);
      expect(header.getUint16(34, Endian.little), 16, reason: '16-bit');
      expect(header.getUint32(4, Endian.little), bytes.length - 8);
    },
  );
}
