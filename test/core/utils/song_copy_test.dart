import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/core/utils/song_copy.dart';

void main() {
  group('copiedTitle', () {
    test('appends " (Copy)" to a normal title', () {
      expect(copiedTitle('Amazing Grace'), 'Amazing Grace (Copy)');
    });

    test('trims surrounding whitespace before adding the suffix', () {
      expect(copiedTitle('  Jingle Bells  '), 'Jingle Bells (Copy)');
    });

    test('falls back to "Untitled Song (Copy)" for a blank title', () {
      expect(copiedTitle(''), 'Untitled Song (Copy)');
      expect(copiedTitle('   '), 'Untitled Song (Copy)');
    });
  });
}
