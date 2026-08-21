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

  /// Lyric size a line starts at, in points. Chords are sized from this, so one
  /// number scales a whole line.
  static const double _lyricPt = 15;

  /// Smallest lyric size the auto-fit script may shrink a line to. Below this
  /// the line wraps instead, because it would stop being readable.
  static const double _minLyricPt = 9;

  /// How much the auto-fit script shrinks a line per step, in points.
  static const double _fitStepPt = 0.5;

  /// Chord size as a share of the lyric size on the same line.
  static const double _chordEm = 0.73;

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
      isIndian: song.isIndian,
    );
    final key = _transposer.transposeKey(song.key, semitones);
    final sheet = _parser.parseSheet(lyrics);
    final lines = sheet.lines;

    final css = await _buildCss(font);

    final body = StringBuffer()
      ..write(_header(song, key, sheet))
      ..write('<hr class="rule">')
      ..write(_lyricsBlock(lines));

    return '<!DOCTYPE html>'
        '<html><head><meta charset="utf-8">'
        '<style>$css</style></head>'
        '<body>$body${_fitScript()}</body></html>';
  }

  /// Builds the HTML sheet for multiple [songs].
  ///
  /// Each song is wrapped in a container that breaks pages after it, ensuring
  /// each song starts on a clean A4 page in the PDF.
  Future<String> buildHtmlForMultiple(
    List<SongNote> songs, {
    LyricFont font = LyricFont.fallback,
  }) async {
    if (songs.isEmpty) {
      return '<!DOCTYPE html><html><head><meta charset="utf-8"></head><body></body></html>';
    }
    if (songs.length == 1) {
      return buildHtml(songs.first, font: font);
    }

    final css = await _buildCss(font);
    final body = StringBuffer();

    for (var i = 0; i < songs.length; i++) {
      final song = songs[i];
      final sheet = _parser.parseSheet(song.lyrics);
      final lines = sheet.lines;

      body.write('<div class="song-container">');
      body.write(_header(song, song.key, sheet));
      body.write('<hr class="rule">');
      body.write(_lyricsBlock(lines));
      body.write('</div>');
    }

    return '<!DOCTYPE html>'
        '<html><head><meta charset="utf-8">'
        '<style>$css</style></head>'
        '<body>$body${_fitScript()}</body></html>';
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
/* Page size is set by native print attributes; page margins are set here in
   @page so HTML content is offset from paper edges when printed. */
@page { margin: 20pt; }
html, body { margin: 0; padding: 0; }
body { font-family: $stack; color: #000; line-height: 1.30; }
.song-container { page-break-after: always; }
.song-container:last-child { page-break-after: avoid; }
.title { font-size: 26pt; font-weight: 700; color: $_accent; margin: 0; }
.artist { font-size: 13pt; color: $_grey700; margin: 2pt 0 0 0; }
.meta { font-size: 12pt; margin: 4pt 0 0 0; }
.rule { border: none; border-top: 0.5pt solid #bdbdbd; margin: 8pt 0; }
/* One font size per line drives both the words and their chords, so the
   auto-fit script can shrink a whole line by setting a single value. Lines
   never wrap on their own; only a line the script could not fit gets the
   "wrapped" class back. */
.line {
  display: flex; flex-wrap: nowrap; align-items: flex-end; margin: 0 0 3pt 0;
  font-size: ${_lyricPt}pt;
}
.line.wrapped { flex-wrap: wrap; }
.blank { height: 13pt; }
.piece { display: flex; flex-direction: column; align-items: flex-start; }
.piece .chord {
  height: 1.28em; font-size: ${_chordEm}em; font-weight: 700; color: $_accent;
  white-space: pre;
}
.piece .word { font-size: 1em; white-space: pre; }
/* A swaram passage: fixed-width so the beats line up, and kept on one row. */
.swaram {
  font-family: monospace; font-size: ${_lyricPt}pt; color: $_accent;
  letter-spacing: 0.06em; white-space: pre; margin: 0 0 3pt 0;
}
''';
  }

  // --- Measure / fit script -------------------------------------------------

  /// Extra width kept as a safety allowance, so a rounding difference between
  /// measuring and printing can never push a line over the page edge.
  static const double _fitSlack = 1.02;

  /// The script that sizes the page to the song and keeps every lyric line on
  /// a single line.
  ///
  /// It defines two functions the native renderer calls in order, once the
  /// embedded fonts have loaded (measuring before that would give wrong
  /// widths) — see `LcHtmlToPdf`:
  ///
  /// * `lcMeasure()` widens the sheet far past any real page so no line can
  ///   wrap, measures the true width of every lyric line, and returns the
  ///   widest one **in points**. The native side turns that into the page
  ///   width. It returns `0` if nothing could be measured, which tells the
  ///   native side to fall back to a full-width page.
  /// * `lcApplyWidth(pt)` sets the sheet to the chosen content width and then
  ///   shrinks any line that still does not fit — only possible for a song so
  ///   wide that the page hit its maximum. A line shrinks step by step down to
  ///   [_minLyricPt]; chords shrink with the words because they are sized in
  ///   `em`, so a chord always stays over its own word. A line that still does
  ///   not fit at the smallest size is allowed to wrap, which is better than
  ///   running off the edge of the page.
  ///
  /// Fixing the width in points is what makes this correct: all measuring is
  /// then in page units, so the device screen size cannot affect the result,
  /// and the layout measured here is exactly the layout that gets printed.
  ///
  /// Plain inline JavaScript with no URL and no library, so the sheet stays
  /// self-contained and offline (CLAUDE.md hard rule 1). It never throws: any
  /// problem simply leaves the sheet at its normal size.
  static String _fitScript() =>
      '''
<script>
(function () {
  var START = $_lyricPt, MIN = $_minLyricPt, STEP = $_fitStepPt;

  // Width of the real content of a line, in CSS pixels.
  function contentWidth(line) {
    var kids = line.children, left = null, right = null;
    for (var j = 0; j < kids.length; j++) {
      var box = kids[j].getBoundingClientRect();
      if (left === null || box.left < left) left = box.left;
      if (right === null || box.right > right) right = box.right;
    }
    return right === null ? 0 : right - left;
  }

  window.lcMeasure = function () {
    try {
      // Far wider than any page, so every line lies out at its natural width.
      document.body.style.width = '5000pt';
      var lines = document.querySelectorAll('.line');
      var widest = 0;
      for (var i = 0; i < lines.length; i++) {
        var w = contentWidth(lines[i]);
        if (w > widest) widest = w;
      }
      // CSS pixels are 1/96 inch, points are 1/72 inch.
      return Math.ceil(widest * 72 / 96 * $_fitSlack);
    } catch (e) {
      return 0;
    }
  };

  window.lcApplyWidth = function (widthPt) {
    try {
      if (widthPt > 0) document.body.style.width = widthPt + 'pt';
      var lines = document.querySelectorAll('.line');
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        var limit = line.clientWidth;
        if (!limit) continue;
        var size = START;
        line.style.fontSize = size + 'pt';
        while (contentWidth(line) > limit + 0.5 && size > MIN) {
          size -= STEP;
          line.style.fontSize = size + 'pt';
        }
        if (contentWidth(line) > limit + 0.5) {
          line.className = 'line wrapped';
        }
      }
    } catch (e) {
      /* Never block the export because a line could not be measured. */
    }
  };
})();
</script>''';

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

  String _header(SongNote song, String key, ParsedSheet sheet) {
    final b = StringBuffer()
      ..write('<h1 class="title">${_esc(song.title)}</h1>');
    if (song.artist.trim().isNotEmpty) {
      b.write('<p class="artist">${_esc(song.artist)}</p>');
    }
    // An Indian sheet prints no key. A Western note letter has no place on it,
    // and a swara is already named relative to Sa. The raga and tala below say
    // what the song is.
    b.write(
      song.isIndian
          ? '<p class="meta">BPM: ${song.bpm}</p>'
          : '<p class="meta">Key: ${_esc(key)}&nbsp;&nbsp;&nbsp;&nbsp;'
                'BPM: ${song.bpm}</p>',
    );

    // The raga and tala are song information, not lyrics, so they belong in
    // the header rather than on the sheet.
    final parts = [
      if (sheet.raga != null && sheet.raga!.isNotEmpty)
        'Raga: ${_esc(sheet.raga!)}',
      if (sheet.tala != null && sheet.tala!.isNotEmpty)
        'Tala: ${_esc(sheet.tala!)}',
    ];
    if (parts.isNotEmpty) {
      b.write('<p class="meta">${parts.join('&nbsp;&nbsp;&nbsp;&nbsp;')}</p>');
    }
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
      // A swaram only reads correctly when the beats line up, so it prints as
      // one fixed-width row instead of being split into chord/word pieces.
      if (line.kind == ChordLineKind.swaram) {
        b.write('<div class="swaram">${_esc(line.text)}</div>');
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
