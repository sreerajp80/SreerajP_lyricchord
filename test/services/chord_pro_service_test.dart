import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/services/chord_pro_service.dart';

void main() {
  const service = ChordProService();

  group('parse', () {
    test('reads the full directives and the lyrics', () {
      const text = '''
{title: Amazing Grace}
{artist: Traditional}
{key: G}
{tempo: 80}

[G]Amazing grace, how sweet the sound''';

      final song = service.parse(text);

      expect(song.title, 'Amazing Grace');
      expect(song.artist, 'Traditional');
      expect(song.key, 'G');
      expect(song.bpm, 80);
      expect(song.lyrics, '[G]Amazing grace, how sweet the sound');
      // Import never assigns an id or a timestamp; the caller does.
      expect(song.id, 0);
      expect(song.timestamp, 0);
    });

    test('reads the short directive aliases', () {
      const text = '{t: Song}\n{a: Band}\n{k: Am}\n{bpm: 100}\nline';

      final song = service.parse(text);

      expect(song.title, 'Song');
      expect(song.artist, 'Band');
      expect(song.key, 'Am');
      expect(song.bpm, 100);
      expect(song.lyrics, 'line');
    });

    test('turns a comment into a plain lyric line', () {
      const text = '{title: X}\n{comment: Verse 1}\n[C]hello';

      final song = service.parse(text);

      expect(song.lyrics, 'Verse 1\n[C]hello');
    });

    test('drops chorus/verse markers and unknown directives', () {
      const text =
          '{title: X}\n{start_of_chorus}\n[C]sing\n{end_of_chorus}\n'
          '{x_custom: whatever}\n[G]on';

      final song = service.parse(text);

      expect(song.lyrics, '[C]sing\n[G]on');
    });

    test('keeps the default bpm when the tempo is not a number', () {
      final song = service.parse('{title: X}\n{tempo: fast}\nline');

      expect(song.bpm, 120);
    });

    test('falls back to safe defaults for an empty file', () {
      final song = service.parse('');

      expect(song.title, 'Untitled Song');
      expect(song.artist, '');
      expect(song.key, 'C');
      expect(song.bpm, 120);
      expect(song.lyrics, '');
    });

    test('leaves the chords in lyric lines untouched', () {
      final song = service.parse('{t: X}\n[C]word [G/B]bass [Am]end');

      expect(song.lyrics, '[C]word [G/B]bass [Am]end');
    });

    test('trims leading and trailing blank lyric lines', () {
      const text = '{t: X}\n\n\n[C]middle\n\n';

      final song = service.parse(text);

      expect(song.lyrics, '[C]middle');
    });
  });

  group('format', () {
    test('writes the four directives and the lyrics', () {
      const song = SongNote(
        title: 'Amazing Grace',
        artist: 'Traditional',
        lyrics: '[G]Amazing grace',
        key: 'G',
        bpm: 80,
        timestamp: 0,
      );

      final text = service.format(song);

      expect(
        text,
        '{title: Amazing Grace}\n'
        '{artist: Traditional}\n'
        '{key: G}\n'
        '{tempo: 80}\n'
        '\n'
        '[G]Amazing grace',
      );
    });

    test('omits the artist directive when the artist is empty', () {
      const song = SongNote(
        title: 'X',
        lyrics: '[C]hi',
        key: 'C',
        bpm: 120,
        timestamp: 0,
      );

      final text = service.format(song);

      expect(text.contains('{artist:'), isFalse);
    });

    test('applies the transpose to the key and the chords', () {
      const song = SongNote(
        title: 'X',
        lyrics: '[G]hi [C]there',
        key: 'G',
        bpm: 120,
        timestamp: 0,
      );

      // G up two semitones is A.
      final text = service.format(song, semitones: 2);

      expect(text.contains('{key: A}'), isTrue);
      expect(text.contains('[A]hi [D]there'), isTrue);
    });
  });

  group('round-trip (export then import)', () {
    void expectRoundTrip(SongNote song) {
      final back = service.parse(service.format(song));
      expect(back.title, song.title);
      expect(back.artist, song.artist);
      expect(back.key, song.key);
      expect(back.bpm, song.bpm);
      expect(back.lyrics, song.lyrics);
    }

    test('a simple song survives the round-trip', () {
      expectRoundTrip(
        const SongNote(
          title: 'Amazing Grace',
          artist: 'Traditional',
          lyrics: '[G]Amazing grace, how sweet the sound',
          key: 'G',
          bpm: 80,
          timestamp: 0,
        ),
      );
    });

    test('slash chords and blank-line spacing survive the round-trip', () {
      expectRoundTrip(
        const SongNote(
          title: 'Test Song',
          artist: '',
          lyrics: '[C]line one [G/B]here\n\n[Am]line two',
          key: 'C',
          bpm: 96,
          timestamp: 0,
        ),
      );
    });
  });

  group('multi-song parseMultiple and formatMultiple', () {
    test('parses multiple songs separated by {new_song}', () {
      const text = '''
{title: Song One}
{key: C}
[C]Line 1

{new_song}

{title: Song Two}
{key: G}
[G]Line 2
''';

      final songs = service.parseMultiple(text);

      expect(songs.length, 2);
      expect(songs[0].title, 'Song One');
      expect(songs[0].key, 'C');
      expect(songs[0].lyrics, '[C]Line 1');

      expect(songs[1].title, 'Song Two');
      expect(songs[1].key, 'G');
      expect(songs[1].lyrics, '[G]Line 2');
    });

    test(
      'parses multiple songs separated by title headers without explicit new_song',
      () {
        const text = '''
{title: Song A}
[D]Line A

{t: Song B}
[E]Line B
''';

        final songs = service.parseMultiple(text);

        expect(songs.length, 2);
        expect(songs[0].title, 'Song A');
        expect(songs[0].lyrics, '[D]Line A');
        expect(songs[1].title, 'Song B');
        expect(songs[1].lyrics, '[E]Line B');
      },
    );

    test(
      'formatMultiple formats multiple songs into bundle text and survives round-trip',
      () {
        const songs = [
          SongNote(
            title: 'Song 1',
            artist: 'Artist 1',
            lyrics: '[C]First',
            key: 'C',
            bpm: 120,
            timestamp: 0,
          ),
          SongNote(
            title: 'Song 2',
            artist: 'Artist 2',
            lyrics: '[G]Second',
            key: 'G',
            bpm: 100,
            timestamp: 0,
          ),
        ];

        final text = service.formatMultiple(songs);
        expect(text.contains('{new_song}'), isTrue);

        final parsedBack = service.parseMultiple(text);
        expect(parsedBack.length, 2);
        expect(parsedBack[0].title, songs[0].title);
        expect(parsedBack[0].artist, songs[0].artist);
        expect(parsedBack[0].lyrics, songs[0].lyrics);
        expect(parsedBack[1].title, songs[1].title);
        expect(parsedBack[1].artist, songs[1].artist);
        expect(parsedBack[1].lyrics, songs[1].lyrics);
      },
    );
  });
}
