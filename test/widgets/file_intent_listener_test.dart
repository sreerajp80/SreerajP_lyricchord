import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/widgets/file_intent_listener.dart';

void main() {
  group('FileIntentListener.readPayload', () {
    FileIntentOutcome read(Map<Object?, Object?>? data) =>
        FileIntentListener.readPayload(data);

    test('null data means nothing to do', () {
      final outcome = read(null);
      expect(outcome.args, isNull);
      expect(outcome.problem, isNull);
    });

    test('UTF-8 bytes become an import preview', () {
      final outcome = read({
        'fileName': 'song.chordpro',
        'bytes': Uint8List.fromList(
          utf8.encode('{title: Opened Song}\n[G]Hello'),
        ),
      });
      expect(outcome.problem, isNull);
      expect(outcome.args?.fileName, 'song.chordpro');
      expect(outcome.args?.parsedSongs.single.title, 'Opened Song');
    });

    test('UTF-16 bytes are decoded too', () {
      const text = '{title: Wide}\n[C]Line';
      final bytes = <int>[0xFF, 0xFE];
      for (final unit in text.codeUnits) {
        bytes
          ..add(unit & 0xFF)
          ..add(unit >> 8);
      }
      final outcome = read({'bytes': Uint8List.fromList(bytes)});
      expect(outcome.args?.parsedSongs.single.title, 'Wide');
      expect(outcome.args?.fileName, 'imported.chordpro');
    });

    test('the older content string is still accepted', () {
      final outcome = read({'content': '{title: Old Path}\nWords'});
      expect(outcome.args?.parsedSongs.single.title, 'Old Path');
    });

    test('too_large from Android is reported with the file name', () {
      final outcome = read({'fileName': 'video.txt', 'error': 'too_large'});
      expect(outcome.problem, FileIntentProblem.tooLarge);
      expect(outcome.fileName, 'video.txt');
    });

    test('bytes over the limit are refused', () {
      final outcome = read({
        'bytes': Uint8List(AppConstants.maxImportFileBytes + 1),
      });
      expect(outcome.problem, FileIntentProblem.tooLarge);
    });

    test('any other error is unreadable', () {
      expect(
        read({'error': 'unreadable'}).problem,
        FileIntentProblem.unreadable,
      );
      expect(read({'fileName': 'x'}).problem, FileIntentProblem.unreadable);
      expect(read({'bytes': 42}).problem, FileIntentProblem.unreadable);
    });

    test('an empty file has no songs', () {
      final outcome = read({'bytes': Uint8List.fromList(utf8.encode('  \n'))});
      expect(outcome.problem, FileIntentProblem.noSongs);
    });

    test('a binary file is unreadable, not a song', () {
      final outcome = read({
        'fileName': 'photo.jpg',
        'bytes': Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]),
      });
      expect(outcome.problem, FileIntentProblem.unreadable);
      expect(outcome.fileName, 'photo.jpg');
    });
  });
}
