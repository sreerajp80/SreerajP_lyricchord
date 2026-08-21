import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/services/pitch_naming_service.dart';

void main() {
  const naming = PitchNamingService();

  group('label', () {
    test('Western naming is just the letter', () {
      expect(naming.label('G', PitchTradition.western), 'G');
      expect(naming.label('A#', PitchTradition.western), 'A#');
    });

    test('Carnatic naming counts kattai, keeping the letter as the anchor', () {
      expect(naming.label('C', PitchTradition.carnatic), '1 kattai (C)');
      expect(naming.label('G', PitchTradition.carnatic), '5 kattai (G)');
      expect(naming.label('B', PitchTradition.carnatic), '7 kattai (B)');
    });

    test('black keys are half numbers in Carnatic', () {
      expect(naming.label('C#', PitchTradition.carnatic), '1½ kattai (C#)');
      expect(naming.label('F#', PitchTradition.carnatic), '4½ kattai (F#)');
    });

    test('Hindustani naming counts safed and kaali separately', () {
      expect(naming.label('C', PitchTradition.hindustani), 'safed 1 (C)');
      expect(naming.label('G', PitchTradition.hindustani), 'safed 5 (G)');
      expect(naming.label('C#', PitchTradition.hindustani), 'kaali 1 (C#)');
      expect(naming.label('A#', PitchTradition.hindustani), 'kaali 5 (A#)');
    });

    test('shortLabel drops the Western letter', () {
      expect(naming.shortLabel('G', PitchTradition.carnatic), '5 kattai');
      expect(naming.shortLabel('G', PitchTradition.hindustani), 'safed 5');
      expect(naming.shortLabel('G', PitchTradition.western), 'G');
    });

    test('an unreadable note is returned unchanged, never thrown', () {
      expect(naming.label('H', PitchTradition.carnatic), 'H');
      expect(naming.label('', PitchTradition.hindustani), '');
    });
  });

  group('chipForSongKey', () {
    test('a plain major key maps to itself', () {
      expect(naming.chipForSongKey('G'), 'G');
      expect(naming.chipForSongKey('C#'), 'C#');
    });

    test('a minor key maps to its root — the drone note is the same', () {
      expect(naming.chipForSongKey('Am'), 'A');
      expect(naming.chipForSongKey('F#m'), 'F#');
    });

    test('flats map to the sharp that sounds the same', () {
      expect(naming.chipForSongKey('Bb'), 'A#');
      expect(naming.chipForSongKey('Eb'), 'D#');
      expect(naming.chipForSongKey('Db'), 'C#');
      expect(naming.chipForSongKey('Ab'), 'G#');
    });

    test('Cb and Fb wrap to their natural neighbours', () {
      expect(naming.chipForSongKey('Cb'), 'B');
      expect(naming.chipForSongKey('Fb'), 'E');
    });

    test('lower case and stray suffixes still resolve', () {
      expect(naming.chipForSongKey('g'), 'G');
      expect(naming.chipForSongKey('Cmaj7'), 'C');
      expect(naming.chipForSongKey('  D  '), 'D');
    });

    test('a slash chord uses the part before the slash', () {
      expect(naming.chipForSongKey('G/B'), 'G');
    });

    test('an unreadable key gives null so the caller can fall back', () {
      expect(naming.chipForSongKey(''), isNull);
      expect(naming.chipForSongKey('H'), isNull);
      expect(naming.chipForSongKey('???'), isNull);
    });
  });

  group('detect', () {
    test('no raga means a Western song', () {
      expect(naming.detect(), PitchTradition.western);
      expect(naming.detect(raga: ''), PitchTradition.western);
      expect(naming.detect(raga: '   '), PitchTradition.western);
    });

    test('a Carnatic tala names the song Carnatic', () {
      expect(
        naming.detect(raga: 'Hamsadhvani', tala: 'Adi'),
        PitchTradition.carnatic,
      );
      expect(
        naming.detect(raga: 'Kalyani', tala: 'Misra Chapu'),
        PitchTradition.carnatic,
      );
    });

    test('a Hindustani tala names the song Hindustani', () {
      expect(
        naming.detect(raga: 'Mishra Gara', tala: 'Keherwa'),
        PitchTradition.hindustani,
      );
      expect(
        naming.detect(raga: 'Yaman', tala: 'Teentaal'),
        PitchTradition.hindustani,
      );
    });

    test('tala matching ignores case and a trailing "talam"', () {
      expect(
        naming.detect(raga: 'Hamsadhvani', tala: 'ADI TALAM'),
        PitchTradition.carnatic,
      );
    });

    test('a raga with an unknown tala uses the fallback', () {
      expect(
        naming.detect(
          raga: 'Something',
          tala: 'Nonsense',
          fallback: PitchTradition.hindustani,
        ),
        PitchTradition.hindustani,
      );
    });

    test('a raga is never named Western, even if that is the fallback', () {
      // A Western letter has no place on an Indian sheet, so the fallback is
      // corrected rather than obeyed.
      expect(
        naming.detect(raga: 'Yaman', fallback: PitchTradition.western),
        PitchTradition.carnatic,
      );
    });
  });

  group('talaMatchesTradition', () {
    test('a Carnatic tala matches Carnatic and not Hindustani', () {
      expect(naming.talaMatchesTradition('Adi', PitchTradition.carnatic), true);
      expect(
        naming.talaMatchesTradition('Adi', PitchTradition.hindustani),
        false,
      );
    });

    test('a Hindustani tala matches Hindustani and not Carnatic', () {
      expect(
        naming.talaMatchesTradition('Keherwa', PitchTradition.hindustani),
        true,
      );
      expect(
        naming.talaMatchesTradition('Keherwa', PitchTradition.carnatic),
        false,
      );
    });

    test('an empty or unknown tala has no opinion', () {
      expect(naming.talaMatchesTradition('', PitchTradition.carnatic), isNull);
      expect(
        naming.talaMatchesTradition('   ', PitchTradition.carnatic),
        isNull,
      );
      expect(
        naming.talaMatchesTradition('Nonsense', PitchTradition.carnatic),
        isNull,
      );
    });

    test('a Western song has no tala to judge', () {
      expect(
        naming.talaMatchesTradition('Adi', PitchTradition.western),
        isNull,
      );
    });

    test('the same suffix rules as detect apply', () {
      expect(
        naming.talaMatchesTradition('ADI TALAM', PitchTradition.carnatic),
        true,
      );
    });
  });

  group('noteForTonic', () {
    const service = PitchNamingService();

    test('reads a kattai number back to a note', () {
      expect(service.noteForTonic('1 kattai'), 'C');
      expect(service.noteForTonic('5 kattai'), 'G');
      expect(service.noteForTonic('7 kattai'), 'B');
    });

    test('accepts a bare number without the word', () {
      expect(service.noteForTonic('1'), 'C');
      expect(service.noteForTonic('5'), 'G');
    });

    test('accepts the half steps written several ways', () {
      for (final written in const ['5½ kattai', '5.5 kattai', '5 1/2 kattai']) {
        expect(service.noteForTonic(written), 'G#', reason: written);
      }
    });

    test('accepts a Western key too', () {
      expect(service.noteForTonic('C'), 'C');
      expect(service.noteForTonic('F#'), 'F#');
      expect(service.noteForTonic('Bb'), 'A#');
    });

    test('returns null rather than guessing', () {
      expect(service.noteForTonic(''), isNull);
      expect(service.noteForTonic('   '), isNull);
      expect(service.noteForTonic('nonsense'), isNull);
      expect(service.noteForTonic('99 kattai'), isNull);
    });
  });
}
