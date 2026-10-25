import 'package:flutter_test/flutter_test.dart';
import 'package:lyricchord/core/utils/song_copy.dart';
import 'package:lyricchord/models/song_title_words.dart';

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

    test('uses the words it is given, in the user\'s language', () {
      final malayalam = SongTitleWords(
        untitled: 'പേരില്ലാത്ത പാട്ട്',
        copyOf: (title) => '$title (പകർപ്പ്)',
      );
      expect(copiedTitle('പാട്ട്', malayalam), 'പാട്ട് (പകർപ്പ്)');
      expect(copiedTitle(' ', malayalam), 'പേരില്ലാത്ത പാട്ട് (പകർപ്പ്)');
    });
  });
}
