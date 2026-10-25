/// Reads a `{melody}` line into beats and notes.
///
/// Pure logic — no UI, no storage, no audio. The player and the grid both take
/// a `MelodyLine` and neither has to know the syntax (architecture §4).
///
/// **Nothing here throws.** A melody line is written by hand, so it will be
/// wrong sometimes. Anything unreadable becomes an `unknown` beat, keeping its
/// place in the line so every later beat stays where the writer put it, and a
/// [MelodyProblem] is added to `MelodyLine.problems` (CLAUDE.md hard rule 4).
///
/// The format, in full:
///
/// * Beats are separated by spaces.
/// * `,` holds the note before it for one more beat.
/// * `|` is a bar line. It takes no time — it only shows where a tala group
///   starts.
/// * `-` joins notes that share one beat. A `,` inside the group extends the
///   note before it.
/// * `!` slides into a note. `M2!G3` starts the slide at Ma; a bare `!G3` is a
///   short slide in from just under Ga.
/// * `~` shakes the note.
/// * A leading `.` drops a note an octave; a trailing `'` or `^` raises it.
///
/// A bare swara name is the note from the plain Sa Re Ga Ma Pa Dha Ni row, so
/// `M` is Ma1. A digit names the exact variant, so the raised Ma is `M2` or
/// `Ma2`. The raga never changes what a name means, which is why no raga table
/// is needed here.
library;

import 'package:lyricchord/models/melody_beat.dart';
import 'package:lyricchord/models/melody_line.dart';
import 'package:lyricchord/models/melody_note.dart';
import 'package:lyricchord/services/swara_notation_service.dart';

/// A swara with its octave, read off one written token.
class _Swara {
  final int position;
  final int octave;

  const _Swara(this.position, this.octave);
}

/// Turns melody text into a [MelodyLine].
class MelodyParser {
  const MelodyParser();

  static const SwaraNotation _swara = SwaraNotation();

  /// The directive that marks a melody line.
  static const String directiveName = 'melody';

  /// Marks that raise a note by an octave. A leading `.` lowers it.
  ///
  /// The apostrophe means **upper octave** on a melody line, not tivra Ma.
  /// Octave marks are taken off before the pitch is looked up, so the tivra
  /// reading in [SwaraNotation.swaraPosition] never sees them. Tivra Ma is
  /// written `M2` here, which is the one rule the whole format uses.
  static const Set<String> _upperOctaveMarks = {"'", '’', '^'};

  /// True when [line] is a melody line.
  ///
  /// Only a line that opens with the directive counts, so an ordinary lyric
  /// that happens to contain a brace is left alone.
  bool isMelodyLine(String line) => _prefix.hasMatch(line.trimLeft());

  /// The melody text of [line] with its `{melody}` prefix taken off.
  ///
  /// Returns [line] unchanged when it is not a melody line, so this is safe to
  /// call on anything.
  String stripPrefix(String line) {
    final trimmed = line.trim();
    final match = _prefix.firstMatch(trimmed);
    if (match == null) return line;

    var rest = trimmed.substring(match.end);
    // `{melody: ... }` is accepted as well as `{melody} ...`, so drop a closing
    // brace the writer added to balance the opening one.
    if (rest.endsWith('}')) rest = rest.substring(0, rest.length - 1);
    return rest.trim();
  }

  /// `{melody}` or `{melody:` at the start of a line.
  static final RegExp _prefix = RegExp(
    r'^\{\s*melody\s*(?::|\})\s*',
    caseSensitive: false,
  );

  /// Reads [line] into beats. Never throws.
  MelodyLine parse(String line) {
    final source = stripPrefix(line).trim();
    if (source.isEmpty) {
      return MelodyLine(beats: const [], source: source);
    }

    final beats = <MelodyBeat>[];
    final problems = <MelodyProblem>[];

    for (final token in source.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      beats.add(_beat(token, problems));
    }

    return MelodyLine(beats: beats, source: source, problems: problems);
  }

  /// Reads one whitespace-separated token into a beat.
  MelodyBeat _beat(String token, List<MelodyProblem> problems) {
    if (token == '|') return const MelodyBeat.barLine();
    if (token == ',') return const MelodyBeat.hold();
    // Published notation writes a whole beat of extension as `;` — two
    // aksharakalas, which is one beat, the same thing our `,` means. Accepting
    // it means a line pasted straight from a notation page does not hard-fail.
    // See docs/carnatic_notation.md section 4.
    if (token == ';') return const MelodyBeat.hold();

    // A group sharing the beat. A single note is just a group of one, so there
    // is no separate path for it. A slot can also be silence (`x`) or a tie to
    // whatever sounded before — that is what lets a note start or stop part-way
    // through a beat.
    final pieces = token.split('-');
    final parts = <MelodySlot>[];

    for (final part in pieces) {
      final piece = part.trim();
      if (piece.isEmpty) continue;

      if (piece == ',') {
        if (parts.isEmpty) {
          // Nothing before it *in this beat*, so it carries the previous beat's
          // sound onward. This is how a note starts part-way through a beat:
          // `,-Ri2` holds for the first half, then strikes Ri.
          parts.add(const MelodySlot.tie());
        } else {
          // Extends whatever the slot before it holds.
          parts[parts.length - 1] = parts.last.withCount(parts.last.count + 1);
        }
        continue;
      }

      if (piece == 'x' || piece == 'X') {
        // Silence. Unlike a tie this *stops* what was ringing, which is how a
        // note stops part-way through a beat: `Ri2-x`.
        parts.add(const MelodySlot.silence());
        continue;
      }

      final note = _note(piece);
      if (note == null) {
        problems.add(
          MelodyProblem(
            MelodyProblemKind.unreadablePiece,
            token: token,
            piece: piece,
          ),
        );
        return MelodyBeat.unknown(token);
      }
      parts.add(MelodySlot.note(note));
    }

    if (parts.isEmpty) {
      problems.add(
        MelodyProblem(MelodyProblemKind.nothingToPlay, token: token),
      );
      return MelodyBeat.unknown(token);
    }

    return MelodyBeat.fromSlots(parts, token);
  }

  /// Reads one note, with its slide and shake marks. `null` when unreadable.
  MelodyNote? _note(String token) {
    var text = token;
    var shake = false;

    // Some sources mark the raga's borrowed note (anya svara) with `*`. It
    // says something about the raga, not about this note's pitch or length, so
    // it is dropped rather than allowed to make the note unreadable.
    text = text.replaceAll('*', '');
    if (text.isEmpty) return null;

    // The shake sits at the very end, after any variant digit or octave mark.
    if (text.endsWith('~')) {
      shake = true;
      text = text.substring(0, text.length - 1).trim();
    }
    if (text.isEmpty) return null;

    var slide = false;
    MelodyNote? slideFrom;

    final bang = text.indexOf('!');
    if (bang >= 0) {
      // Two slides in one note is not something that can be sung, and guessing
      // which one was meant would be worse than saying so.
      if (text.indexOf('!', bang + 1) >= 0) return null;

      slide = true;
      final from = text.substring(0, bang).trim();
      text = text.substring(bang + 1).trim();

      if (from.isNotEmpty) {
        final parsed = _readSwara(from);
        if (parsed == null) return null;
        slideFrom = MelodyNote(
          position: parsed.position,
          octave: parsed.octave,
          text: from,
        );
      }
    }

    final target = _readSwara(text);
    if (target == null) return null;

    return MelodyNote(
      position: target.position,
      octave: target.octave,
      slide: slide,
      slideFrom: slideFrom,
      shake: shake,
      text: token,
    );
  }

  /// Reads a swara and its octave — `.N3`, `S'`, `M2`, `Ma2`, `G3`.
  _Swara? _readSwara(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;

    var octave = 0;
    while (text.startsWith('.')) {
      octave -= 1;
      text = text.substring(1);
    }
    while (text.isNotEmpty &&
        _upperOctaveMarks.contains(text[text.length - 1])) {
      octave += 1;
      text = text.substring(0, text.length - 1);
    }
    if (text.isEmpty) return null;

    final position = _swara.swaraPosition(text);
    if (position == null) return null;
    return _Swara(position, octave);
  }
}
