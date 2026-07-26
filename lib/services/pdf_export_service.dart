/// Builds a printable A4 song sheet as HTML: header, guitar diagrams, and the
/// chorded lyrics. The HTML is converted to a PDF by the platform's native web
/// view (see the export screen), which shapes complex scripts — Malayalam
/// chillu, conjuncts, and reordered vowel signs — correctly and keeps the text
/// real and selectable in the PDF.
///
/// Output only — no UI, no navigation, no network. It embeds the fonts as
/// base64 `@font-face` data URIs, so the HTML is fully self-contained and no
/// URL is ever loaded (CLAUDE.md hard rule 1 — fully offline). It reuses the
/// same pure services the screens use ([ChordTransposer], [ChordSheetParser],
/// [ChordShapeService]) so the sheet matches what the app shows.
///
/// Nothing here throws for odd song content: an unknown chord simply has no
/// guitar diagram, a song with no chords still produces a clean sheet, and all
/// user text is HTML-escaped so broken input can never break the markup
/// (CLAUDE.md hard rule 4).
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:lyricchord/models/lyric_font.dart';
import 'package:lyricchord/models/song_note.dart';
import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/chord_transposer.dart';

/// Turns a [SongNote] into a self-contained HTML song sheet.
class PdfExportService {
  const PdfExportService();

  static const ChordTransposer _transposer = ChordTransposer();
  static const ChordSheetParser _parser = ChordSheetParser();

  /// The purple used for chord names, matching the app's palette.
  static const String _accent = '#6750A4';
  static const String _grey700 = '#616161';

  /// CSS family name used for the always-attached Malayalam fallback font.
  static const String _malayalamFamily = 'LcMalayalamFallback';

  /// Builds the HTML sheet for [song], applying [semitones] of transpose.
  ///
  /// [font] is the lyric font the user picked. That font is used for all text;
  /// a Malayalam fallback font is always embedded too, so Malayalam prints
  /// correctly even when [font] has no Malayalam letters of its own (for
  /// example the plain [LyricFont.system] default).
  ///
  /// The platform web view converts the returned HTML to PDF — see the export
  /// screen. Kept out of this service so the service stays free of platform and
  /// UI code.
  Future<String> buildHtml(
    SongNote song, {
    int semitones = 0,
    LyricFont font = LyricFont.fallback,
  }) async {
    final lyrics = _transposer.transposeLyrics(
      song.lyrics,
      semitones,
      song.key,
    );
    final key = _transposer.transposeKey(song.key, semitones);
    final lines = _parser.parse(lyrics);

    final css = await _buildCss(font);

    final body = StringBuffer()
      ..write(_header(song, key))
      ..write('<hr class="rule">')
      ..write(_lyricsBlock(lines));

    return '<!DOCTYPE html>'
        '<html><head><meta charset="utf-8">'
        '<style>$css</style></head>'
        '<body>$body</body></html>';
  }

  // --- Fonts / CSS ----------------------------------------------------------

  /// Builds the page CSS, including the embedded `@font-face` rules.
  Future<String> _buildCss(LyricFont font) async {
    final faces = StringBuffer();

    // The chosen font (regular + bold), if it has bundled assets. The plain
    // "system" choice has none, so Latin falls back to the Malayalam font's
    // Latin glyphs and then to the web view's sans-serif.
    final hasChosen = font.regularAsset != null && font.family != null;
    if (hasChosen) {
      faces.write(
        await _fontFace(font.family!, font.regularAsset!, bold: false),
      );
      if (font.boldAsset != null) {
        faces.write(await _fontFace(font.family!, font.boldAsset!, bold: true));
      }
    }

    // The Malayalam fallback, always embedded (regular + bold).
    const fallback = LyricFont.malayalamFallback;
    faces.write(
      await _fontFace(_malayalamFamily, fallback.regularAsset!, bold: false),
    );
    if (fallback.boldAsset != null) {
      faces.write(
        await _fontFace(_malayalamFamily, fallback.boldAsset!, bold: true),
      );
    }

    // Font stack: chosen font first (both scripts when it is a Malayalam font),
    // then the bundled Malayalam fallback, then a generic sans-serif.
    final stack = <String>[
      if (hasChosen) "'${font.family}'",
      "'$_malayalamFamily'",
      'sans-serif',
    ].join(', ');

    return '''
$faces
@page { size: A4; margin: 32pt; }
html, body { margin: 0; padding: 0; }
body { font-family: $stack; color: #000; line-height: 1.35; }
.title { font-size: 22pt; font-weight: 700; color: $_accent; margin: 0; }
.artist { font-size: 12pt; color: $_grey700; margin: 2pt 0 0 0; }
.meta { font-size: 11pt; margin: 4pt 0 0 0; }
.rule { border: none; border-top: 0.5pt solid #bdbdbd; margin: 8pt 0; }
.line {
  display: flex; flex-wrap: wrap; align-items: flex-end; margin: 0 0 2pt 0;
}
.blank { height: 10pt; }
.piece { display: flex; flex-direction: column; align-items: flex-start; }
.piece .chord {
  height: 11pt; font-size: 8pt; font-weight: 700; color: $_accent;
  white-space: pre;
}
.piece .word { font-size: 11pt; white-space: pre; }
''';
  }

  /// Loads a bundled `.ttf` [asset] and returns an `@font-face` rule that embeds
  /// it as a base64 data URI under [family].
  Future<String> _fontFace(
    String family,
    String asset, {
    required bool bold,
  }) async {
    final data = await rootBundle.load(asset);
    final b64 = base64Encode(data.buffer.asUint8List());
    final weight = bold ? 700 : 400;
    return "@font-face{font-family:'$family';font-weight:$weight;"
        "font-style:normal;src:url(data:font/ttf;base64,$b64) "
        'format("truetype");}';
  }

  // --- Header ---------------------------------------------------------------

  String _header(SongNote song, String key) {
    final b = StringBuffer()
      ..write('<h1 class="title">${_esc(song.title)}</h1>');
    if (song.artist.trim().isNotEmpty) {
      b.write('<p class="artist">${_esc(song.artist)}</p>');
    }
    b.write(
      '<p class="meta">Key: ${_esc(key)}&nbsp;&nbsp;&nbsp;&nbsp;'
      'BPM: ${song.bpm}</p>',
    );
    return b.toString();
  }

  // --- Lyrics ---------------------------------------------------------------

  String _lyricsBlock(List<ChordLine> lines) {
    final b = StringBuffer();
    for (final line in lines) {
      if (line.isBlank) {
        b.write('<div class="blank"></div>');
        continue;
      }
      b.write('<div class="line">');
      for (final piece in _wordPieces(line.segments)) {
        b.write('<span class="piece">');
        if (piece.chord == null) {
          b.write('<span class="chord"></span>');
        } else {
          b.write('<span class="chord">${_esc(piece.chord!)}</span>');
        }
        b.write('<span class="word">${_esc(piece.text)}</span>');
        b.write('</span>');
      }
      b.write('</div>');
    }
    return b.toString();
  }

  /// Splits each segment at word boundaries so a long line wraps between words,
  /// mirroring the on-screen `ChordSheetView`. The chord stays on the first word
  /// of its segment.
  List<ChordSegment> _wordPieces(List<ChordSegment> segments) {
    final pieces = <ChordSegment>[];
    for (final segment in segments) {
      final words = _wordPattern
          .allMatches(segment.text)
          .map((m) => m.group(0)!)
          .toList(growable: false);
      if (words.isEmpty) {
        pieces.add(segment);
        continue;
      }
      for (var i = 0; i < words.length; i++) {
        pieces.add(
          ChordSegment(chord: i == 0 ? segment.chord : null, text: words[i]),
        );
      }
    }
    return pieces;
  }

  static final RegExp _wordPattern = RegExp(r'\S+\s*|\s+');

  // --- Helpers --------------------------------------------------------------

  /// Escapes text for safe use inside HTML content.
  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
