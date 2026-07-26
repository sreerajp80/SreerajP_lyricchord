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
}
