/// Turns lyric text with inline `[Chord]` markers into something a widget can
/// draw.
///
/// Pure logic — no UI, no storage. The renderer only receives ready-made
/// segments, so no widget ever has to know ChordPro syntax (architecture §4).
///
/// Nothing here throws. Broken input (an unclosed `[`, a stray `]`, an empty
/// marker) is kept as plain lyric text, which is CLAUDE.md hard rule 4.
library;

/// One chunk of a line: an optional chord sitting above some lyric text.
///
/// `[C]Amazing [F]grace` becomes two segments: (`C`, `Amazing `) and
/// (`F`, `grace`). Text before the first chord becomes a segment with no chord.
class ChordSegment {
  /// The chord shown above [text], or `null` when this chunk has no chord.
  final String? chord;

  /// The lyric text under [chord]. May be empty when a chord sits alone at the
  /// end of a line.
  final String text;

  const ChordSegment({this.chord, required this.text});

  /// True when there is no chord and nothing to read.
  bool get isEmpty => chord == null && text.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ChordSegment && other.chord == chord && other.text == text;

  @override
  int get hashCode => Object.hash(chord, text);

  @override
  String toString() => 'ChordSegment(chord: $chord, text: "$text")';
}

/// One line of the sheet. A blank line has no segments.
class ChordLine {
  /// The chunks of this line, left to right.
  final List<ChordSegment> segments;

  const ChordLine(this.segments);

  /// True for a blank line, which the renderer draws as vertical space.
  bool get isBlank => segments.isEmpty;

  /// Every chord used on this line, in the order it appears.
  Iterable<String> get chords =>
      segments.map((s) => s.chord).whereType<String>();

  @override
  bool operator ==(Object other) {
    if (other is! ChordLine) return false;
    if (other.segments.length != segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (other.segments[i] != segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(segments);

  @override
  String toString() => 'ChordLine($segments)';
}

/// Reads lyric text into lines of chord/lyric segments.
class ChordSheetParser {
  const ChordSheetParser();

  /// Splits [lyrics] into lines, then each line into [ChordSegment]s.
  ///
  /// Handles `\r\n` and `\n` line endings. A line with only whitespace comes
  /// back blank so the sheet keeps the writer's spacing between verses.
  List<ChordLine> parse(String lyrics) {
    if (lyrics.isEmpty) return const [];

    return lyrics
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map(parseLine)
        .toList(growable: false);
  }

  /// Splits a single line. Exposed for testing and for reuse by later phases.
  ChordLine parseLine(String line) {
    if (line.trim().isEmpty) return const ChordLine([]);

    final segments = <ChordSegment>[];
    final buffer = StringBuffer();
    String? pendingChord;

    var i = 0;
    while (i < line.length) {
      if (line[i] != '[') {
        buffer.write(line[i]);
        i++;
        continue;
      }

      final close = line.indexOf(']', i + 1);
      final chord = close < 0 ? '' : line.substring(i + 1, close).trim();
      if (chord.isEmpty) {
        // Unclosed or empty marker — keep it as plain text rather than
        // guessing what the writer meant.
        buffer.write(line[i]);
        i++;
        continue;
      }

      // A chord starts a new chunk, so close off the text collected so far.
      if (pendingChord != null || buffer.isNotEmpty) {
        segments.add(
          ChordSegment(chord: pendingChord, text: buffer.toString()),
        );
        buffer.clear();
      }
      pendingChord = chord;
      i = close + 1;
    }

    if (pendingChord != null || buffer.isNotEmpty) {
      segments.add(ChordSegment(chord: pendingChord, text: buffer.toString()));
    }

    return ChordLine(segments);
  }

  /// Every distinct chord used in [lyrics], in the order it first appears.
  ///
  /// Phase 6's chord reference and Phase 7's PDF export both need this list.
  List<String> chordsUsed(String lyrics) {
    final seen = <String>{};
    for (final line in parse(lyrics)) {
      for (final chord in line.chords) {
        seen.add(chord);
      }
    }
    return seen.toList(growable: false);
  }
}
