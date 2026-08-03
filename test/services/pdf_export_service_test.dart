import 'package:flutter_test/flutter_test.dart';

import 'package:lyricchord/models/lyric_font.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/services/pdf_export_service.dart';

void main() {
  // buildHtml loads bundled font files through rootBundle, so the test binding
  // must be ready to serve assets.
  TestWidgetsFlutterBinding.ensureInitialized();

  const service = PdfExportService();

  /// The HTML must be a full, self-contained document with embedded fonts.
  void expectIsSelfContainedHtml(String html) {
    expect(html.startsWith('<!DOCTYPE html>'), isTrue);
    expect(html.contains('<body>'), isTrue);
    // Fonts are embedded as base64 data URIs — no external URL is loaded.
    expect(html.contains('@font-face'), isTrue);
    expect(html.contains('data:font/ttf;base64,'), isTrue);
    // No external resource is loaded (the SVG xmlns URI is not a load).
    expect(html.contains('src="http'), isFalse);
    expect(html.contains('src=http'), isFalse);
    expect(html.contains('url(http'), isFalse);
  }

  test('builds HTML for a normal song with chords', () async {
    const song = SongNote(
      title: 'Amazing Grace',
      artist: 'Traditional',
      lyrics: '[G]Amazing grace, how [C]sweet the [G]sound',
      key: 'G',
      bpm: 80,
      timestamp: 0,
    );

    final html = await service.buildHtml(song);
    expectIsSelfContainedHtml(html);
    expect(html.contains('Amazing Grace'), isTrue);
    expect(html.contains('Traditional'), isTrue);
    // Chords appear above the lyrics.
    expect(html.contains('class="chord">G<'), isTrue);
    // Guitar fret diagrams are no longer drawn in the PDF.
    expect(html.contains('<svg'), isFalse);
    expect(html.contains('class="diagrams"'), isFalse);
  });

  test('builds HTML for a song with no chords', () async {
    const song = SongNote(
      title: 'Spoken Word',
      lyrics: 'just some words\nwith no chords at all',
      key: 'C',
      bpm: 100,
      timestamp: 0,
    );

    final html = await service.buildHtml(song);
    expectIsSelfContainedHtml(html);
    // No chords means no diagrams block.
    expect(html.contains('class="diagrams"'), isFalse);
  });

  test('builds HTML with a non-zero transpose without throwing', () async {
    const song = SongNote(
      title: 'Transposed',
      lyrics: '[G]hi [C]there [G/B]bass',
      key: 'G',
      bpm: 120,
      timestamp: 0,
    );

    expectIsSelfContainedHtml(await service.buildHtml(song, semitones: 3));
  });

  test('builds HTML for an empty song', () async {
    const song = SongNote(title: 'Empty', key: 'C', bpm: 120, timestamp: 0);

    final html = await service.buildHtml(song);
    expectIsSelfContainedHtml(html);
    expect(html.contains('Empty'), isTrue);
  });

  test('escapes HTML-special characters in user text', () async {
    const song = SongNote(
      title: 'Rock & <Roll>',
      lyrics: 'a < b & c',
      key: 'C',
      bpm: 120,
      timestamp: 0,
    );

    final html = await service.buildHtml(song);
    expect(html.contains('Rock &amp; &lt;Roll&gt;'), isTrue);
    // The raw, unescaped title must never appear.
    expect(html.contains('<Roll>'), isFalse);
  });

  test('keeps Malayalam text in the HTML (default font)', () async {
    const song = SongNote(
      title: 'മനോഹര ഗാനം',
      artist: 'പാരമ്പര്യം',
      lyrics: '[G]എന്റെ ഗാനം [C]മനോഹരം [G]ആണ്',
      key: 'G',
      bpm: 80,
      timestamp: 0,
    );

    // The default (system) font has no Malayalam letters; the export still
    // embeds the bundled Malayalam fallback so the web view can shape it.
    final html = await service.buildHtml(song);
    expectIsSelfContainedHtml(html);
    expect(html.contains('മനോഹര ഗാനം'), isTrue);
    // Lyric lines are split into per-word spans for wrapping, so the words
    // appear individually rather than as one contiguous run.
    expect(html.contains('എന്റെ'), isTrue);
    expect(html.contains('മനോഹരം'), isTrue);
    expect(html.contains('LcMalayalamFallback'), isTrue);
  });

  test('embeds the chosen bundled Malayalam font', () async {
    const song = SongNote(
      title: 'മഞ്ജരി',
      lyrics: 'ഒരു [Am]പുതിയ [F]പാട്ട്',
      key: 'Am',
      bpm: 90,
      timestamp: 0,
    );

    final html = await service.buildHtml(song, font: LyricFont.manjari);
    expectIsSelfContainedHtml(html);
    expect(html.contains('മഞ്ജരി'), isTrue);
    // The chosen font family name is present in the font stack.
    expect(html.contains('Manjari'), isTrue);
  });

  test('builds HTML for multiple songs with page breaks', () async {
    const song1 = SongNote(
      title: 'Song One',
      artist: 'Artist One',
      lyrics: '[C]First song lyrics',
      key: 'C',
      bpm: 100,
      timestamp: 0,
    );
    const song2 = SongNote(
      title: 'Song Two',
      artist: 'Artist Two',
      lyrics: '[G]Second song lyrics',
      key: 'G',
      bpm: 120,
      timestamp: 0,
    );

    final html = await service.buildHtmlForMultiple([song1, song2]);
    expectIsSelfContainedHtml(html);
    expect(html.contains('Song One'), isTrue);
    expect(html.contains('Song Two'), isTrue);
    expect(html.contains('class="song-container"'), isTrue);
    expect(html.contains('page-break-after: always;'), isTrue);
  });

  test('uses the bigger reading sizes and the narrower margin', () async {
    const song = SongNote(
      title: 'Sizes',
      lyrics: '[C]big enough to read',
      key: 'C',
      bpm: 100,
      timestamp: 0,
    );

    final html = await service.buildHtml(song);
    // Lyrics drive the line size; chords are sized from it, so a chord always
    // shrinks together with its own word.
    expect(html.contains('font-size: 15.0pt;'), isTrue);
    expect(html.contains('font-size: 0.73em;'), isTrue);
    expect(html.contains('.piece .word { font-size: 1em;'), isTrue);
    // The page size and margins come only from the native print attributes,
    // because the page width is chosen from the song.
    expect(html.contains('@page { margin: 0; }'), isTrue);
    expect(html.contains('size: A4'), isFalse);
    // The old small sizes are gone.
    expect(html.contains('font-size: 11pt; white-space: pre;'), isFalse);
    expect(html.contains('font-size: 8pt;'), isFalse);
  });

  test(
    'lyric lines do not wrap, and the auto-fit script is included',
    () async {
      const song = SongNote(
        title: 'Long Line',
        lyrics:
            '[C]a very long lyric line that would normally not fit across the '
            'width of an A4 page at fifteen points',
        key: 'C',
        bpm: 100,
        timestamp: 0,
      );

      final html = await service.buildHtml(song);
      expectIsSelfContainedHtml(html);
      // Lines never break by themselves...
      expect(html.contains('flex-wrap: nowrap;'), isTrue);
      // ...only a line the script gave up on wraps.
      expect(html.contains('.line.wrapped { flex-wrap: wrap; }'), isTrue);
      // The script is inline (offline) and the native renderer calls both
      // functions by name: measure the widest line, then lay out at the page
      // width it picked.
      expect(html.contains('window.lcMeasure = function'), isTrue);
      expect(html.contains('window.lcApplyWidth = function'), isTrue);
      expect(html.contains('<script src'), isFalse);
      // It shrinks down to the 9 pt floor before giving up.
      expect(html.contains('MIN = 9.0'), isTrue);
    },
  );

  test('multi-song HTML also carries the auto-fit script', () async {
    const song1 = SongNote(
      title: 'One',
      lyrics: '[C]first',
      key: 'C',
      bpm: 100,
      timestamp: 0,
    );
    const song2 = SongNote(
      title: 'Two',
      lyrics: '[G]second',
      key: 'G',
      bpm: 100,
      timestamp: 0,
    );

    final html = await service.buildHtmlForMultiple([song1, song2]);
    expect(html.contains('window.lcMeasure = function'), isTrue);
    expect(html.contains('window.lcApplyWidth = function'), isTrue);
  });

  test('builds HTML for empty list of songs', () async {
    final html = await service.buildHtmlForMultiple([]);
    expect(html.contains('<!DOCTYPE html>'), isTrue);
  });
}
