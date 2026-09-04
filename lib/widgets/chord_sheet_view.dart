import 'package:flutter/material.dart';

import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/widgets/melody_line_row.dart';

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
    this.showMelody = true,
    this.lyricFontFamily,
    this.melodyTonicHz,
    this.melodyTempoBpm,
  });

  /// The frequency of the song's Sa, read from its `{tonic: ...}` line.
  ///
  /// `null` when the song does not name one. A melody line still draws its beat
  /// grid — it just cannot be played, because without a real pitch there is no
  /// frequency to hum.
  final double? melodyTonicHz;

  /// Beats per minute for melody playback, or `null` when the song has none.
  final double? melodyTempoBpm;

  /// The parsed sheet, already transposed if a transpose is active.
  final List<ChordLine> lines;

  /// Lyric text size in logical pixels.
  final double fontSize;

  /// False hides the chord badges and leaves the lyrics only.
  final bool showChords;

  /// False drops the `{melody}` rows completely — no beat grid, no play
  /// button, and no gap where the row used to be.
  ///
  /// Only `{melody}` lines go: a swaram passage and the swara markers written
  /// as chords are part of the written notation, so they follow [showChords].
  final bool showMelody;

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
      color: theme.colorScheme.primary,
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

    // A swaram is read as a grid of beats, so it uses the fixed-width chord
    // font and never wraps. It is drawn at the chord badge size, with no extra
    // letter spacing, so a long phrase stays on screen — the ` - ` beat dashes
    // already separate the swaras.
    final swaramStyle = TextStyle(
      fontSize: fontSize * 0.8,
      fontFamily: 'monospace',
      height: 1.15,
      color: theme.colorScheme.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          if (line.isBlank)
            SizedBox(height: fontSize)
          // Hidden melody rows leave nothing behind, so the lyrics close up
          // instead of scrolling past a column of gaps.
          else if (line.kind == ChordLineKind.melody &&
              line.melody != null &&
              !showMelody)
            const SizedBox.shrink()
          else if (line.kind == ChordLineKind.melody && line.melody != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 2),
              child: MelodyLineRow(
                melody: line.melody!,
                tonicHz: melodyTonicHz,
                tempoBpm: melodyTempoBpm,
                textStyle: swaramStyle,
              ),
            )
          else if (line.kind == ChordLineKind.swaram)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _SwaramLine(text: line.text, style: swaramStyle),
            )
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

/// A swaram passage: one unbroken fixed-width row.
///
/// Wrapping a swaram in the middle would break the beat grid and make it
/// unreadable, so a long phrase scrolls sideways on its own instead. The
/// horizontal scroll does not fight the sheet's vertical auto-scroll — they
/// are different axes, so each gesture goes to only one of them.
class _SwaramLine extends StatelessWidget {
  const _SwaramLine({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text(text, style: style, softWrap: false, maxLines: 1),
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
