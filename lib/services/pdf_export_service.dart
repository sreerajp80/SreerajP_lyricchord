/// Builds a printable A4 PDF of a song: header, guitar diagrams, and the
/// chorded lyrics.
///
/// Output only — no UI, no navigation, no file IO. The screen edge shares or
/// saves the bytes; this service just returns them. It reuses the same pure
/// services the screens use ([ChordTransposer], [ChordSheetParser],
/// [ChordShapeService]) so the PDF matches what the app shows.
///
/// Nothing here throws for odd song content: an unknown chord simply has no
/// guitar diagram, and a song with no chords still produces a clean sheet
/// (CLAUDE.md hard rule 4).
library;

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:lyriccord/models/lyric_font.dart';
import 'package:lyriccord/models/song_note.dart';
import 'package:lyriccord/services/chord_sheet_parser.dart';
import 'package:lyriccord/services/chord_shape_service.dart';
import 'package:lyriccord/services/chord_transposer.dart';

/// Turns a [SongNote] into A4 PDF bytes.
class PdfExportService {
  const PdfExportService();

  static const ChordTransposer _transposer = ChordTransposer();
  static const ChordSheetParser _parser = ChordSheetParser();
  static const ChordShapeService _shapes = ChordShapeService();

  /// The purple used for chords and finger dots, matching the app's palette.
  static const PdfColor _accent = PdfColor.fromInt(0xFF6750A4);

  /// Builds the PDF for [song], applying [semitones] of transpose when set.
  ///
  /// [font] is the lyric font the user picked. The chosen font is used for all
  /// text; a Malayalam fallback font is always attached to the page theme, so
  /// Malayalam lyrics print correctly even when [font] has no Malayalam letters
  /// of its own (for example the plain [LyricFont.system] default).
  Future<Uint8List> buildPdf(
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
    final chords = _transposer.chordsUsed(song.lyrics, semitones, song.key);
    final lines = _parser.parse(lyrics);

    final doc = pw.Document();

    // The chosen font (regular + bold). For the plain "system" choice there is
    // no bundled file, so fall back to the built-in Helvetica.
    final regularFont = font.regularAsset == null
        ? pw.Font.helvetica()
        : await _loadFont(font.regularAsset!);
    final boldFont = font.boldAsset == null
        ? pw.Font.helveticaBold()
        : await _loadFont(font.boldAsset!);

    // A Malayalam-capable font, attached below as a fallback so Malayalam
    // renders no matter which font was chosen.
    final malayalamFont = await _loadFont(
      LyricFont.malayalamFallback.regularAsset!,
    );

    // Page theme: the chosen font as the base, with Malayalam as the fallback.
    // Every text widget inherits this fallback through style merging, so the
    // per-widget `font:` styles below do not need to repeat it.
    final theme = pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      fontFallback: [malayalamFont],
    );

    // The low-level canvas draws the guitar diagrams' O/X and fret numbers,
    // which are ASCII only, so plain Helvetica is enough here.
    final canvasFont = PdfFont.helvetica(doc.document);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _header(song, key, regularFont, boldFont),
          if (chords.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _diagramsBlock(chords, regularFont, boldFont, canvasFont),
          ],
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey400, thickness: 0.5),
          pw.SizedBox(height: 8),
          ..._lyricWidgets(lines, regularFont, boldFont),
        ],
      ),
    );

    return doc.save();
  }

  /// Loads a bundled `.ttf` [asset] into a PDF [pw.Font].
  Future<pw.Font> _loadFont(String asset) async {
    final data = await rootBundle.load(asset);
    return pw.Font.ttf(data);
  }

  // --- Header ---------------------------------------------------------------

  pw.Widget _header(SongNote song, String key, pw.Font font, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          song.title,
          style: pw.TextStyle(font: bold, fontSize: 22, color: _accent),
        ),
        if (song.artist.trim().isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            song.artist,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
        pw.SizedBox(height: 4),
        pw.Text(
          'Key: $key    BPM: ${song.bpm}',
          style: pw.TextStyle(font: font, fontSize: 11),
        ),
      ],
    );
  }

  // --- Guitar diagrams ------------------------------------------------------

  pw.Widget _diagramsBlock(
    List<String> chords,
    pw.Font font,
    pw.Font bold,
    PdfFont canvasFont,
  ) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final chord in chords)
          _guitarDiagram(
            chord,
            _shapes.guitarShape(chord),
            font,
            bold,
            canvasFont,
          ),
      ],
    );
  }

  pw.Widget _guitarDiagram(
    String name,
    GuitarChordShape? shape,
    pw.Font font,
    pw.Font bold,
    PdfFont canvasFont,
  ) {
    const w = 58.0;
    const h = 72.0;
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: w,
          height: h,
          child: shape == null
              ? pw.Center(
                  child: pw.Text(
                    'no diagram',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                )
              : pw.CustomPaint(
                  size: const PdfPoint(w, h),
                  painter: (canvas, size) =>
                      _paintGuitar(canvas, size, shape, canvasFont),
                ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(name, style: pw.TextStyle(font: bold, fontSize: 9)),
      ],
    );
  }

  /// Draws a fret grid, nut, finger dots, and open/muted markers for [shape].
  ///
  /// The PDF canvas origin is the bottom-left corner, so [flip] turns the
  /// top-down layout (the same one the on-screen diagram uses) into PDF
  /// coordinates.
  void _paintGuitar(
    PdfGraphics canvas,
    PdfPoint size,
    GuitarChordShape shape,
    PdfFont font,
  ) {
    const fretCount = 5;
    const stringCount = 6;
    final width = size.x;
    final height = size.y;
    double flip(double topY) => height - topY;

    final maxFret = shape.maxFret;
    final startFret = maxFret <= fretCount ? 1 : shape.minFret;
    final showNut = startFret == 1;

    const topPad = 12.0;
    final leftPad = showNut ? 8.0 : 15.0;
    const rightPad = 8.0;
    const bottomPad = 4.0;

    final gridW = width - leftPad - rightPad;
    final gridH = height - topPad - bottomPad;
    final stringGap = gridW / (stringCount - 1);
    final fretGap = gridH / fretCount;

    canvas
      ..setLineWidth(0.7)
      ..setStrokeColor(PdfColors.grey700);

    // Vertical string lines.
    for (var s = 0; s < stringCount; s++) {
      final x = leftPad + s * stringGap;
      canvas.drawLine(x, flip(topPad), x, flip(topPad + gridH));
    }
    // Horizontal fret lines.
    for (var f = 0; f <= fretCount; f++) {
      final y = topPad + f * fretGap;
      canvas.drawLine(leftPad, flip(y), leftPad + gridW, flip(y));
    }
    canvas.strokePath();

    if (showNut) {
      canvas
        ..setLineWidth(2.5)
        ..drawLine(leftPad, flip(topPad), leftPad + gridW, flip(topPad))
        ..strokePath();
    } else {
      _text(
        canvas,
        font,
        '$startFret',
        leftPad - 4,
        flip(topPad + fretGap / 2) - 8 * 0.35,
        8,
        PdfColors.grey700,
        alignRight: true,
      );
    }

    final markerBaseline = flip(topPad - 6) - 9 * 0.35;
    for (var s = 0; s < stringCount; s++) {
      final fret = shape.frets[s];
      final x = leftPad + s * stringGap;
      if (fret < 0) {
        _text(canvas, font, 'X', x, markerBaseline, 9, PdfColors.grey700);
      } else if (fret == 0) {
        _text(canvas, font, 'O', x, markerBaseline, 9, PdfColors.grey700);
      } else {
        final row = fret - startFret;
        final y = topPad + row * fretGap + fretGap / 2;
        canvas
          ..setFillColor(_accent)
          ..drawEllipse(x, flip(y), fretGap * 0.26, fretGap * 0.26)
          ..fillPath();
      }
    }
  }

  /// Draws [s] at PDF baseline [baselineY], centred (or right-aligned) on [cx].
  void _text(
    PdfGraphics canvas,
    PdfFont font,
    String s,
    double cx,
    double baselineY,
    double fontSize,
    PdfColor color, {
    bool alignRight = false,
  }) {
    final textWidth = font.stringMetrics(s).advanceWidth * fontSize;
    final x = alignRight ? cx - textWidth : cx - textWidth / 2;
    canvas
      ..setFillColor(color)
      ..drawString(font, fontSize, s, x, baselineY);
  }

  // --- Lyrics ---------------------------------------------------------------

  List<pw.Widget> _lyricWidgets(
    List<ChordLine> lines,
    pw.Font font,
    pw.Font bold,
  ) {
    final widgets = <pw.Widget>[];
    for (final line in lines) {
      if (line.isBlank) {
        widgets.add(pw.SizedBox(height: 10));
        continue;
      }
      widgets.add(
        pw.Wrap(
          crossAxisAlignment: pw.WrapCrossAlignment.end,
          children: [
            for (final piece in _wordPieces(line.segments))
              _segment(piece, font, bold),
          ],
        ),
      );
    }
    return widgets;
  }

  pw.Widget _segment(ChordSegment segment, pw.Font font, pw.Font bold) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 11,
          child: segment.chord == null
              ? null
              : pw.Text(
                  segment.chord!,
                  style: pw.TextStyle(font: bold, fontSize: 8, color: _accent),
                ),
        ),
        pw.Text(segment.text, style: pw.TextStyle(font: font, fontSize: 11)),
      ],
    );
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
}
