/// Builds a `{melody}` line one tap at a time, for the melody keypad.
///
/// Pure logic — no Flutter, no UI, no storage. The keypad widget calls these
/// operations and never builds a token string itself (architecture §4, layer
/// boundaries).
///
/// Everything this writes is a token `MelodyParser` already reads, so a line
/// built here always parses. See `docs/carnatic_notation.md` §7 for the format.
library;

import 'package:lyricchord/services/melody_parser_service.dart';

/// A mark that sits on the last note entered.
///
/// All four are toggles: tapping the same mark twice takes it off again.
/// Stacking would produce text like `S''`, which the parser does not read.
enum MelodyMark {
  /// One octave up, written as a trailing `'`.
  octaveUp,

  /// One octave down, written as a leading `.`.
  octaveDown,

  /// Slide into the note (jaru), written as a leading `!`.
  slide,

  /// Shake the note (kampita), written as a trailing `~`.
  shake,
}

/// The tokens entered so far, plus whether the next one shares the last beat.
///
/// Immutable: every operation hands back a new [MelodyEntry], which is what
/// makes undo inside the keypad a matter of keeping the previous value.
class MelodyEntry {
  /// One beat per token, in written order — `Sa`, `Ga3-Ma1`, `,`, `|`.
  final List<String> tokens;

  /// True when the next note joins the last beat instead of starting its own.
  ///
  /// Set by [share] and by [tie], cleared as soon as something is added.
  final bool shareArmed;

  const MelodyEntry({this.tokens = const [], this.shareArmed = false});

  /// An empty keypad.
  static const MelodyEntry empty = MelodyEntry();

  /// Reads an existing line back in, so a typed line can be edited.
  ///
  /// Accepts the line with or without its `{melody}` prefix. Tokens are kept
  /// exactly as written — this never re-spells what someone typed.
  factory MelodyEntry.fromLine(String line) {
    const parser = MelodyParser();
    final text = parser.stripPrefix(line).trim();
    if (text.isEmpty) return empty;
    return MelodyEntry(tokens: text.split(RegExp(r'\s+')));
  }

  /// The melody without the `{melody}` prefix.
  String get text => tokens.join(' ');

  /// The full line, ready to drop into the lyrics.
  String get line => '{${MelodyParser.directiveName}} $text';

  /// True when nothing has been entered yet.
  bool get isEmpty => tokens.isEmpty;

  /// True when there is a note the mark buttons can act on.
  ///
  /// A bar line and a bare hold carry no note, so the mark buttons are dead
  /// there rather than writing a mark with nothing to attach it to.
  bool get canMarkLastNote => _lastNoteIndex() != null;

  /// True when a note can join the last beat — i.e. [share] would do something.
  bool get canShare {
    if (tokens.isEmpty) return false;
    return tokens.last != _barLine;
  }

  /// Adds a note. Joins the last beat when [share] or [tie] armed it.
  ///
  /// [label] is written through untouched, so `Ga3` in means `Ga3` out and the
  /// note keeps the writer's own spelling.
  MelodyEntry addNote(String label) => _addPiece(label.trim());

  /// Adds a silence — the mark that *stops* a sound part-way through a beat.
  MelodyEntry silence() => _addPiece(_silence);

  /// Adds a hold: one more beat of whatever is already sounding.
  MelodyEntry hold() => MelodyEntry(tokens: [...tokens, _hold]);

  /// Adds a bar line. It takes no time — it only marks a tala group.
  MelodyEntry barLine() => MelodyEntry(tokens: [...tokens, _barLine]);

  /// Arms the next note to share the last beat rather than start a new one.
  MelodyEntry share() =>
      canShare ? MelodyEntry(tokens: tokens, shareArmed: true) : this;

  /// Starts a new beat with a tie, so the next note begins part-way through it.
  ///
  /// This is a hold with sharing armed: on its own it reads as a hold, and the
  /// next note turns it into `,-Ri2`.
  MelodyEntry tie() =>
      MelodyEntry(tokens: [...tokens, _hold], shareArmed: true);

  /// True when [mark] is already on the last note.
  bool markActive(MelodyMark mark) {
    final piece = _lastNotePiece();
    if (piece == null) return false;
    return switch (mark) {
      MelodyMark.octaveUp => piece.endsWith(_octaveUp),
      MelodyMark.octaveDown => _bodyOf(piece).startsWith(_octaveDown),
      MelodyMark.slide => piece.startsWith(_slide),
      MelodyMark.shake => piece.endsWith(_shake),
    };
  }

  /// Turns [mark] on or off on the last note.
  ///
  /// Does nothing when there is no note to mark. The two octave marks are
  /// exclusive — turning one on takes the other off, because a note cannot be
  /// an octave up and an octave down at once.
  MelodyEntry toggle(MelodyMark mark) {
    final index = _lastNoteIndex();
    if (index == null) return this;

    final (tokenIndex, pieceIndex) = index;
    final pieces = tokens[tokenIndex].split(_shareMark);
    pieces[pieceIndex] = _toggleOn(pieces[pieceIndex], mark);

    final updated = [...tokens];
    updated[tokenIndex] = pieces.join(_shareMark);
    return MelodyEntry(tokens: updated, shareArmed: shareArmed);
  }

  /// Removes the last thing entered.
  ///
  /// In order: an armed share first (it is the newest thing, and undoing it is
  /// what someone means by "I did not mean to tap that"), then the last slot of
  /// a shared beat, then the whole beat.
  MelodyEntry backspace() {
    if (shareArmed) return MelodyEntry(tokens: tokens);
    if (tokens.isEmpty) return this;

    final pieces = tokens.last.split(_shareMark);
    if (pieces.length > 1) {
      final updated = [...tokens];
      updated[updated.length - 1] = pieces
          .take(pieces.length - 1)
          .join(_shareMark);
      return MelodyEntry(tokens: updated);
    }

    return MelodyEntry(tokens: tokens.take(tokens.length - 1).toList());
  }

  /// Clears everything.
  MelodyEntry clear() => empty;

  /// Adds one slot: a new beat, or a share of the last one when armed.
  MelodyEntry _addPiece(String piece) {
    if (piece.isEmpty) return this;

    if (shareArmed && canShare) {
      final updated = [...tokens];
      updated[updated.length - 1] = '${updated.last}$_shareMark$piece';
      return MelodyEntry(tokens: updated);
    }
    return MelodyEntry(tokens: [...tokens, piece]);
  }

  /// Where the last note sits: its token, then its slot inside that token.
  ///
  /// `null` when the last beat holds no note — a bar line, a bare hold, or a
  /// beat whose last slot is silence.
  (int, int)? _lastNoteIndex() {
    if (tokens.isEmpty) return null;

    final tokenIndex = tokens.length - 1;
    final token = tokens[tokenIndex];
    if (token == _barLine) return null;

    final pieces = token.split(_shareMark);
    for (var i = pieces.length - 1; i >= 0; i--) {
      if (_isNote(pieces[i])) return (tokenIndex, i);
    }
    return null;
  }

  /// The text of the last note, marks and all.
  String? _lastNotePiece() {
    final index = _lastNoteIndex();
    if (index == null) return null;
    return tokens[index.$1].split(_shareMark)[index.$2];
  }

  /// True when [piece] carries a pitch, rather than being a hold or a silence.
  static bool _isNote(String piece) {
    if (piece.isEmpty) return false;
    if (piece == _hold) return false;
    return piece.toLowerCase() != _silence;
  }

  /// [piece] without its leading slide mark.
  static String _bodyOf(String piece) =>
      piece.startsWith(_slide) ? piece.substring(_slide.length) : piece;

  /// Puts [mark] on [piece], or takes it off when it is already there.
  ///
  /// The written order is always `!` then `.` then the swara then `'` then `~`,
  /// which is the order the parser reads: it takes the shake off the end, then
  /// splits at the slide, then reads the octave marks around the name.
  static String _toggleOn(String piece, MelodyMark mark) {
    final slide = piece.startsWith(_slide);
    var body = _bodyOf(piece);

    final shake = body.endsWith(_shake);
    if (shake) body = body.substring(0, body.length - _shake.length);

    final up = body.endsWith(_octaveUp);
    if (up) body = body.substring(0, body.length - _octaveUp.length);

    final down = body.startsWith(_octaveDown);
    if (down) body = body.substring(_octaveDown.length);

    var wantSlide = slide;
    var wantShake = shake;
    var wantUp = up;
    var wantDown = down;

    switch (mark) {
      case MelodyMark.slide:
        wantSlide = !slide;
      case MelodyMark.shake:
        wantShake = !shake;
      case MelodyMark.octaveUp:
        wantUp = !up;
        if (wantUp) wantDown = false;
      case MelodyMark.octaveDown:
        wantDown = !down;
        if (wantDown) wantUp = false;
    }

    final buffer = StringBuffer();
    if (wantSlide) buffer.write(_slide);
    if (wantDown) buffer.write(_octaveDown);
    buffer.write(body);
    if (wantUp) buffer.write(_octaveUp);
    if (wantShake) buffer.write(_shake);
    return buffer.toString();
  }

  static const String _hold = ',';
  static const String _barLine = '|';
  static const String _silence = 'x';
  static const String _shareMark = '-';
  static const String _slide = '!';
  static const String _shake = '~';
  static const String _octaveUp = "'";
  static const String _octaveDown = '.';

  @override
  bool operator ==(Object other) =>
      other is MelodyEntry &&
      other.shareArmed == shareArmed &&
      other.text == text;

  @override
  int get hashCode => Object.hash(text, shareArmed);

  @override
  String toString() => 'MelodyEntry("$text"${shareArmed ? ' +share' : ''})';
}
