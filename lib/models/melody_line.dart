/// A whole `{melody}` line, read into beats.
///
/// This is what the grid draws and what the player sings. It never knows a
/// frequency, a tempo or a widget — those belong to the player and the screen.
library;

import 'package:lyricchord/models/melody_beat.dart';

/// What kind of trouble a [MelodyProblem] reports.
enum MelodyProblemKind {
  /// A piece of a beat is not a swara or a mark: `Sx` in `Sx,`.
  unreadablePiece,

  /// A beat held nothing that sounds or holds.
  nothingToPlay,
}

/// One thing on a melody line that could not be read.
///
/// The parser only says *what* went wrong and where; the screen turns it into
/// words (`lib/l10n/l10n_labels.dart`), so no English is built here.
class MelodyProblem {
  const MelodyProblem(this.kind, {required this.token, this.piece = ''});

  final MelodyProblemKind kind;

  /// The whole token the problem is in, as written.
  final String token;

  /// The part of [token] that could not be read, for [MelodyProblemKind.unreadablePiece].
  final String piece;

  @override
  bool operator ==(Object other) =>
      other is MelodyProblem &&
      other.kind == kind &&
      other.token == token &&
      other.piece == piece;

  @override
  int get hashCode => Object.hash(kind, token, piece);

  @override
  String toString() => 'MelodyProblem($kind, token: $token, piece: $piece)';
}

/// One parsed melody line.
class MelodyLine {
  /// The beats and bar lines, left to right, exactly in written order.
  final List<MelodyBeat> beats;

  /// The line as the writer typed it, without the `{melody}` prefix.
  final String source;

  /// Anything that could not be read.
  ///
  /// A melody line never throws (hard rule 4). Problems are collected here so
  /// the editor can show them, and the rest of the line still plays.
  final List<MelodyProblem> problems;

  const MelodyLine({
    required this.beats,
    required this.source,
    this.problems = const [],
  });

  /// An empty line — no beats, nothing to play.
  static const MelodyLine empty = MelodyLine(beats: [], source: '');

  /// How many beats of time this line takes. Bar lines are not counted.
  int get beatCount => beats.where((b) => b.takesTime).length;

  /// True when nothing on this line can be played.
  bool get isEmpty => beats.every((b) => !b.takesTime);

  /// True when something on the line could not be read.
  bool get hasProblems => problems.isNotEmpty;

  /// Whether this line fills a cycle of [talaBeats] exactly.
  ///
  /// Returns `null` when the tala is unknown, so the caller can stay quiet
  /// rather than guessing. The commonest data-entry mistake is a line one beat
  /// short or one beat long, and this is what catches it.
  bool? fitsTala(int? talaBeats) {
    if (talaBeats == null || talaBeats <= 0) return null;
    return beatCount % talaBeats == 0;
  }

  @override
  bool operator ==(Object other) {
    if (other is! MelodyLine) return false;
    if (other.source != source) return false;
    if (other.beats.length != beats.length) return false;
    for (var i = 0; i < beats.length; i++) {
      if (other.beats[i] != beats[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(source, Object.hashAll(beats));

  @override
  String toString() => 'MelodyLine("$source", beats: $beatCount)';
}
