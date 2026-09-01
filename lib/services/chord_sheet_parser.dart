/// Turns lyric text with inline `[Chord]` markers into something a widget can
/// draw.
///
/// Pure logic — no UI, no storage. The renderer only receives ready-made
/// segments, so no widget ever has to know ChordPro syntax (architecture §4).
///
/// Nothing here throws. Broken input (an unclosed `[`, a stray `]`, an empty
/// marker) is kept as plain lyric text, which is CLAUDE.md hard rule 4.
library;

import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/services/melody_parser_service.dart';
import 'package:lyricchord/services/swara_notation_service.dart';

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

/// What a line is, so the renderer can lay it out without knowing any music
/// syntax itself (architecture §4, layer boundaries).
enum ChordLineKind {
  /// Ordinary words, with or without chords above them.
  lyric,

  /// A swaram passage — only swaras and separators, e.g.
  /// `Sa - Ri - Ga - Ma - | Pa - Dha - Ni - Sa -`. Drawn in a fixed-width grid
  /// that does not wrap, because a swaram only reads correctly when the beats
  /// line up.
  swaram,

  /// A `{melody}` line: the tune for the lyric line above it, written in beats.
  ///
  /// Unlike [swaram] this carries timing, so it can be drawn as a beat grid and
  /// played back. The parsed form is on `ChordLine.melody`.
  melody,
}

/// One line of the sheet. A blank line has no segments.
class ChordLine {
  /// The chunks of this line, left to right.
  final List<ChordSegment> segments;

  /// Whether this is lyrics, a swaram passage or a melody line.
  final ChordLineKind kind;

  /// The parsed tune, set only when [kind] is [ChordLineKind.melody].
  ///
  /// The renderer draws it as a beat grid and the player sings it. Nothing else
  /// on the line changes, so a sheet with no melody lines behaves exactly as it
  /// did before this existed.
  final MelodyLine? melody;

  const ChordLine(
    this.segments, {
    this.kind = ChordLineKind.lyric,
    this.melody,
  });

  /// True for a blank line, which the renderer draws as vertical space.
  bool get isBlank => segments.isEmpty;

  /// Every chord used on this line, in the order it appears.
  Iterable<String> get chords =>
      segments.map((s) => s.chord).whereType<String>();

  /// The plain text of this line, with the chord markers taken out.
  String get text => segments.map((s) => s.text).join();

  @override
  bool operator ==(Object other) {
    if (other is! ChordLine) return false;
    if (other.kind != kind) return false;
    if (other.melody != melody) return false;
    if (other.segments.length != segments.length) return false;
    for (var i = 0; i < segments.length; i++) {
      if (other.segments[i] != segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(segments), kind, melody);

  @override
  String toString() => 'ChordLine($segments, kind: ${kind.name})';
}

/// A whole sheet: the header directives plus the lines to draw.
///
/// `{raga: Yamunakalyani}` and `{tala: Adi}` are song *information*, not lyrics.
/// They are pulled out here so the screen can show them in the header and the
/// renderer never draws the curly braces.
class ParsedSheet {
  /// Directive name (lower case) to its value, e.g. `{'raga': 'Yamunakalyani'}`.
  final Map<String, String> directives;

  /// The lines to draw, with directive lines already removed.
  final List<ChordLine> lines;

  const ParsedSheet({required this.directives, required this.lines});

  /// The raga name, or `null` when the song does not name one.
  String? get raga => directives['raga'];

  /// The tala name, or `null` when the song does not name one.
  String? get tala => directives['tala'];

  /// The sruti the song is sung in, or `null` when it does not say.
  ///
  /// Written `{sruti: madhyama}`. Only meaningful for Indian songs.
  String? get sruti => directives['sruti'];

  /// True when the song is sung in **madhyama sruti**.
  ///
  /// Some ragas — Yamunakalyani, Kurinji, Nadanamakriya, Chenchurutti — are
  /// traditionally sung with the tambura's Pa string dropped to shuddha
  /// madhyamam, and that note taken as the base Sa. Such a song is notated
  /// starting on `Sa`, but its Sa is **not** the singer's adhara shadja: it is
  /// the shuddha madhyamam five semitones above it.
  ///
  /// Without this the melody player would hum the tune a fourth too low against
  /// the drone. See `docs/carnatic_notation.md` section 5.
  bool get isMadhyamaSruti {
    final value = sruti?.trim().toLowerCase() ?? '';
    return value.startsWith('madhyam') || value.startsWith('madyam');
  }

  /// True when the song is written in Indian notation — it names a raga.
  bool get isIndianNotation => raga != null;
}

/// Reads lyric text into lines of chord/lyric segments.
class ChordSheetParser {
  const ChordSheetParser();

  static const SwaraNotation _swara = SwaraNotation();
  static const MelodyParser _melody = MelodyParser();

  /// Splits [lyrics] into lines, then each line into [ChordSegment]s.
  ///
  /// Handles `\r\n` and `\n` line endings. A line with only whitespace comes
  /// back blank so the sheet keeps the writer's spacing between verses.
  /// Directive lines such as `{raga: Kalyani}` are left out — use [parseSheet]
  /// when you also want to read them.
  List<ChordLine> parse(String lyrics) => parseSheet(lyrics).lines;

  /// Reads [lyrics] into its header directives and its drawable lines.
  ParsedSheet parseSheet(String lyrics) {
    if (lyrics.isEmpty) {
      return const ParsedSheet(directives: {}, lines: []);
    }

    final directives = <String, String>{};
    final lines = <ChordLine>[];

    final rawLines = lyrics
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');

    for (final raw in rawLines) {
      // Checked before the directive test on purpose: `{melody: ...}` would
      // otherwise be swallowed as a header directive and the tune would vanish.
      if (_melody.isMelodyLine(raw)) {
        lines.add(parseMelodyLine(raw));
        continue;
      }

      final directive = _directive(raw);
      if (directive != null) {
        // Last one wins, and an unknown name is simply kept and never drawn.
        directives[directive.key] = directive.value;
        continue;
      }
      lines.add(parseLine(raw));
    }

    return ParsedSheet(directives: directives, lines: lines);
  }

  /// Reads a whole-line `{name: value}` directive, or `null` when [line] is not
  /// one.
  ///
  /// Only a line that is *nothing but* a directive counts, so a lyric that
  /// happens to contain a brace is left alone (hard rule 4).
  MapEntry<String, String>? _directive(String line) {
    final match = _directivePattern.firstMatch(line.trim());
    if (match == null) return null;

    final name = match.group(1)!.trim().toLowerCase();
    if (name.isEmpty) return null;
    return MapEntry(name, match.group(2)!.trim());
  }

  /// `{name: value}` or `{name}` on a line of its own.
  static final RegExp _directivePattern = RegExp(
    r'^\{([^:{}]+?)\s*:\s*([^{}]*)\}$',
  );

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

    return ChordLine(segments, kind: _kindOf(segments));
  }

  /// Reads a `{melody}` line into a [ChordLine] carrying the parsed tune.
  ///
  /// The line keeps its place in the sheet, so it draws under the lyric line it
  /// was written under. Its single segment holds the melody text as typed, so a
  /// screen that knows nothing about melodies still shows something sensible
  /// rather than a blank.
  ChordLine parseMelodyLine(String line) {
    final melody = _melody.parse(line);
    return ChordLine(
      [ChordSegment(text: melody.source)],
      kind: ChordLineKind.melody,
      melody: melody,
    );
  }

  /// A line with no chords whose words are all swaras is a swaram passage.
  ///
  /// The chord check matters: `[S]Krishna nee begane baro` is a *lyric* line
  /// that happens to carry swara markers, and must keep wrapping normally.
  ChordLineKind _kindOf(List<ChordSegment> segments) {
    if (segments.any((s) => s.chord != null)) return ChordLineKind.lyric;

    final text = segments.map((s) => s.text).join();
    return _swara.isSwaramLine(text)
        ? ChordLineKind.swaram
        : ChordLineKind.lyric;
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
