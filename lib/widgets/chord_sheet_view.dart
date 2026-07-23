import 'package:flutter/material.dart';

import 'package:lyriccord/services/chord_sheet_parser.dart';

/// Draws the lyric sheet with chord badges above the words.
///
/// Each chunk of a line becomes a small column — chord on top, lyric below —
/// and the chunks sit in a [Wrap], so a long line breaks between chunks instead
/// of running off the screen. Blank lines become vertical space, keeping the
/// gaps the writer put between verses.
///
/// This widget knows nothing about ChordPro: it is handed ready-made
/// [ChordLine]s (architecture §4, layer boundaries).
class ChordSheetView extends StatelessWidget {
  const ChordSheetView({
    super.key,
    required this.lines,
    required this.fontSize,
    this.showChords = true,
    this.lyricFontFamily,
  });

  /// The parsed sheet, already transposed if a transpose is active.
  final List<ChordLine> lines;

  /// Lyric text size in logical pixels.
  final double fontSize;

  /// False hides the chord badges and leaves the lyrics only.
  final bool showChords;

  /// Font family for the lyric words, or `null` for the theme default. Chords
  /// keep their own monospace font regardless.
  final String? lyricFontFamily;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lyricStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: lyricFontFamily,
      height: 1.2,
      color: theme.colorScheme.onSurface,
    );
    // Bold monospace so chords line up and stand out over the lyrics
    // (idea doc §4, typography).
    final chordStyle = TextStyle(
      fontSize: fontSize * 0.8,
      fontFamily: 'monospace',
      fontWeight: FontWeight.bold,
      height: 1.1,
      color: theme.colorScheme.secondary,
    );

    if (lines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'This song has no lyrics yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          if (line.isBlank)
            SizedBox(height: fontSize)
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _SheetLine(
                line: line,
                lyricStyle: lyricStyle,
                chordStyle: chordStyle,
                showChords: showChords,
              ),
            ),
      ],
    );
  }
}

/// One line of the sheet.
class _SheetLine extends StatelessWidget {
  const _SheetLine({
    required this.line,
    required this.lyricStyle,
    required this.chordStyle,
    required this.showChords,
  });

  final ChordLine line;
  final TextStyle lyricStyle;
  final TextStyle chordStyle;
  final bool showChords;

  @override
  Widget build(BuildContext context) {
    // With chords hidden the line is plain text, which wraps better and reads
    // like a normal lyric sheet.
    if (!showChords) {
      return Text(line.segments.map((s) => s.text).join(), style: lyricStyle);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final segment in _wordPieces(line.segments))
          _Segment(
            segment: segment,
            lyricStyle: lyricStyle,
            chordStyle: chordStyle,
          ),
      ],
    );
  }
}

/// Splits each segment at word boundaries so a long line can wrap between
/// words. The chord stays on the first word of its segment; the rest become
/// chordless pieces.
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

/// One word plus the spaces that follow it, or a run of spaces on its own.
final RegExp _wordPattern = RegExp(r'\S+\s*|\s+');

/// A chord badge sitting above its slice of the lyric.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.lyricStyle,
    required this.chordStyle,
  });

  final ChordSegment segment;
  final TextStyle lyricStyle;
  final TextStyle chordStyle;

  @override
  Widget build(BuildContext context) {
    final chord = segment.chord;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An empty box on chordless chunks keeps every chunk in a line the same
        // height, so the lyrics stay on one baseline.
        SizedBox(
          height: chordStyle.fontSize! * 1.1,
          child: chord == null
              ? null
              : Text(chord, style: chordStyle, softWrap: false),
        ),
        Text(segment.text, style: lyricStyle, softWrap: false),
      ],
    );
  }
}
