import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/services/pdf_export_service.dart';

void main() {
  // buildPdf loads bundled font files through rootBundle, so the test binding
  // must be ready to serve assets.
  TestWidgetsFlutterBinding.ensureInitialized();

  const service = PdfExportService();

  /// A PDF file always starts with the `%PDF` magic bytes.
  void expectIsPdf(Uint8List bytes) {
    expect(bytes.isNotEmpty, isTrue);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  }

  test('builds a PDF for a normal song with chords', () async {
    const song = SongNote(
      title: 'Amazing Grace',
      artist: 'Traditional',
      lyrics: '[G]Amazing grace, how [C]sweet the [G]sound',
      key: 'G',
      bpm: 80,
      timestamp: 0,
    );

    expectIsPdf(await service.buildPdf(song));
  });

  test('builds a PDF for a song with no chords', () async {
    const song = SongNote(
      title: 'Spoken Word',
      lyrics: 'just some words\nwith no chords at all',
      key: 'C',
      bpm: 100,
      timestamp: 0,
    );

    expectIsPdf(await service.buildPdf(song));
  });

  test('builds a PDF with a non-zero transpose without throwing', () async {
    const song = SongNote(
      title: 'Transposed',
      lyrics: '[G]hi [C]there [G/B]bass',
      key: 'G',
      bpm: 120,
      timestamp: 0,
    );

    expectIsPdf(await service.buildPdf(song, semitones: 3));
  });

  test('builds a PDF for an empty song', () async {
    const song = SongNote(title: 'Empty', key: 'C', bpm: 120, timestamp: 0);

    expectIsPdf(await service.buildPdf(song));
  });

  test('builds a PDF with Malayalam lyrics (default font)', () async {
    const song = SongNote(
      title: 'മനോഹര ഗാനം',
      artist: 'പാരമ്പര്യം',
      lyrics: '[G]എന്റെ ഗാനം [C]മനോഹരം [G]ആണ്',
      key: 'G',
      bpm: 80,
      timestamp: 0,
    );

    // The default (system) font has no Malayalam letters; the export must still
    // succeed by using the bundled Malayalam fallback font.
    expectIsPdf(await service.buildPdf(song));
  });

  test('builds a PDF with a chosen bundled Malayalam font', () async {
    const song = SongNote(
      title: 'മഞ്ജരി',
      lyrics: 'ഒരു [Am]പുതിയ [F]പാട്ട്',
      key: 'Am',
      bpm: 90,
      timestamp: 0,
    );

    expectIsPdf(await service.buildPdf(song, font: LyricFont.manjari));
  });
}
