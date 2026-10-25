/// Turns published Carnatic notation into LyricChord `{melody}` lines.
///
/// The rules are set out in `docs/carnatic_notation.md`; this file implements
/// them. The short version, counting in **aksharakalas** (one beat = two):
///
/// | Written | Aksharakalas |
/// |---|---|
/// | uppercase note `S` | 2 |
/// | lowercase note `s` | 1 |
/// | `;` | 2 |
/// | `,` | 1 |
/// | letters written together (`snrs`) | share their beat |
/// | `_snrs_` (underlined in print) | packed faster still |
/// | `-` | a pause/split mark, no duration |
/// | `*` | anya svara mark, no duration |
///
/// **Why this is a converter and not a looser parser.** `-` means "split the
/// phrase here" in published notation but "share a beat" in our format. A
/// straight paste would silently misread it. Converting is the only safe path.
///
/// Nothing here throws — hard rule 4. Bad input comes back as problems.
library;

import 'package:lyricchord/models/carnatic_import_result.dart';
import 'package:lyricchord/services/swara_notation_service.dart';

/// Converts a block of published notation into `{melody}` lines.
class CarnaticNotationImporter {
  const CarnaticNotationImporter();

  static const SwaraNotation _swara = SwaraNotation();

  /// Durations are counted in **quarter-aksharakalas**, not aksharakalas.
  ///
  /// One beat is two aksharakalas, so it is eight of these. The finer unit
  /// exists because an underlined run halves every duration inside it, and a
  /// lowercase note is already the shortest thing there is — halving it needs
  /// somewhere to go. Integers throughout, so no rounding creeps in.
  static const int _perBeat = 4;

  /// One aksharakala, in the unit above.
  static const int _akshara = 2;

  /// What one `,` is worth under each reading.
  ///
  /// The two conventions do not merely disagree about letter case — they count
  /// in different grains. Where case carries the duration, the base unit is the
  /// aksharakala and a note is one or two of them. Where case carries the
  /// octave, every written note is one akshara of the tala, so the base unit is
  /// a whole beat. Getting this wrong makes the comparison in [convert]
  /// meaningless, because both readings would be scored on the same scale.
  static int _unit(CarnaticCaseReading reading) => switch (reading) {
    CarnaticCaseReading.duration => _akshara,
    CarnaticCaseReading.octave => _perBeat,
  };

  /// The seven swara letters, lower-cased.
  static const String _letters = 'srgmpdn';

  /// Reads [notation] against [tala] and returns the better of the two case
  /// readings (see `docs/carnatic_notation.md` §4a).
  ///
  /// [tala] is a name `SwaraNotation.talaBeats` understands, such as
  /// `'Misra Chapu'`. [defaultMadhyamam] picks which madhyamam a bare `m`
  /// becomes — `1` for shuddha, `2` for prati, which is the Kalyani default.
  ///
  /// [applyAnyaSvaraRule] is **off by default and deliberately so.** A bhashanga
  /// raga's borrowed note belongs only to one phrase, and published notation
  /// does not mark which madhyamam is meant — that is raga grammar, and the
  /// importer will not decide it behind a musician's back. Switched on, it
  /// applies the documented Yamunakalyani rule: shuddha madhyamam in a
  /// descending `Ga -> Ma -> Ri`, prati everywhere else
  /// (`docs/carnatic_notation.md` section 5). Either way the phrase's positions
  /// come back in [CarnaticImportResult.anyaSvaraHints].
  CarnaticImportResult convert(
    String notation, {
    required String tala,
    int defaultMadhyamam = 2,
    bool applyAnyaSvaraRule = false,
  }) {
    final beats = _swara.talaBeats(tala);
    if (beats == null || beats <= 0) {
      return CarnaticImportResult.failure(CarnaticUnknownTala(tala));
    }

    final avartas = _splitAvartas(notation);
    if (avartas.isEmpty) {
      return CarnaticImportResult.failure(const CarnaticNoNotation());
    }

    final byDuration = _readAll(
      avartas,
      beats,
      CarnaticCaseReading.duration,
      defaultMadhyamam,
      applyAnyaSvaraRule,
    );
    final byOctave = _readAll(
      avartas,
      beats,
      CarnaticCaseReading.octave,
      defaultMadhyamam,
      applyAnyaSvaraRule,
    );

    // The right convention makes every cycle land on the tala. Where they tie,
    // duration wins only because it is the commoner krithi convention — and the
    // tie is reported so the caller never presents it as settled.
    final durationWins = byDuration.fit.fitting >= byOctave.fit.fitting;
    final chosen = durationWins ? byDuration : byOctave;
    final other = durationWins ? byOctave : byDuration;

    final problems = <CarnaticProblem>[...chosen.problems];
    if (!chosen.fit.isPerfect) {
      problems.insert(
        0,
        CarnaticCyclesOffTala(
          fitting: chosen.fit.fitting,
          total: chosen.fit.total,
          tala: tala,
        ),
      );
    }
    if (other.fit.fitting == chosen.fit.fitting) {
      problems.add(const CarnaticReadingsTie());
    }

    return CarnaticImportResult(
      melodyLines: chosen.lines,
      chosen: chosen.fit,
      rejected: other.fit,
      problems: problems,
      anyaSvaraHints: chosen.anyaSvaraHints,
    );
  }

  // --- reading ---------------------------------------------------------------

  /// One avarta per entry, `||` and line breaks both ending a cycle.
  List<String> _splitAvartas(String notation) {
    return notation
        .split(RegExp(r'\|\||\r?\n'))
        .map((a) => a.trim())
        .where(
          (a) =>
              a.isNotEmpty &&
              a.contains(RegExp('[$_letters;,]', caseSensitive: false)),
        )
        .toList();
  }

  _Reading _readAll(
    List<String> avartas,
    int beats,
    CarnaticCaseReading reading,
    int defaultMadhyamam,
    bool applyAnyaSvaraRule,
  ) {
    final lines = <String>[];
    final problems = <CarnaticProblem>[];
    final hints = <int>[];
    var fitting = 0;

    for (var i = 0; i < avartas.length; i++) {
      final one = _readAvarta(
        avartas[i],
        beats,
        reading,
        defaultMadhyamam,
        applyAnyaSvaraRule,
      );
      lines.add(one.line);
      problems.addAll(one.problems.map((p) => p.inCycle(i + 1)));
      if (one.fits) fitting++;
      if (one.sawAnyaSvaraPhrase) hints.add(i);
    }

    return _Reading(
      lines: lines,
      problems: problems,
      anyaSvaraHints: hints,
      fit: CarnaticFit(
        reading: reading,
        fitting: fitting,
        total: avartas.length,
      ),
    );
  }

  /// Reads one cycle into a single `{melody}` line.
  _Avarta _readAvarta(
    String avarta,
    int beats,
    CarnaticCaseReading reading,
    int defaultMadhyamam,
    bool applyAnyaSvaraRule,
  ) {
    final problems = <CarnaticProblem>[];
    final events = <_Event>[];

    for (final group in avarta.split('|')) {
      for (final token in group.trim().split(RegExp(r'\s+'))) {
        if (token.isEmpty) continue;
        _readToken(token, reading, defaultMadhyamam, events, problems);
      }
    }

    if (events.isEmpty) {
      return const _Avarta(
        line: '',
        problems: [CarnaticNothingReadable()],
        fits: false,
      );
    }

    if (applyAnyaSvaraRule) _applyAnyaSvaraRule(events);

    final wanted = beats * _perBeat;
    final total = events.fold<int>(0, (sum, e) => sum + e.units);
    final fits = total == wanted;
    if (!fits) {
      problems.add(
        CarnaticWrongLength(got: total / _akshara, wanted: beats * 2),
      );
    }

    return _Avarta(
      line: _render(events, beats),
      problems: problems,
      fits: fits,
      sawAnyaSvaraPhrase: _hasGaMaRiDescent(events),
    );
  }

  /// Reads one whitespace-separated token, appending its events.
  void _readToken(
    String token,
    CarnaticCaseReading reading,
    int defaultMadhyamam,
    List<_Event> out,
    List<CarnaticProblem> problems,
  ) {
    // An underlined run is written _like this_ when pasted as plain text; it
    // means the notes are packed faster still into their beat.
    var text = token;
    var packed = false;
    if (text.length > 2 && text.startsWith('_') && text.endsWith('_')) {
      packed = true;
      text = text.substring(1, text.length - 1);
    }

    var pendingOctave = 0;
    var readAnything = false;
    final startedAt = out.length;

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];

      if (ch == ';') {
        out.add(_Event.rest(2 * _unit(reading)));
        readAnything = true;
        continue;
      }
      if (ch == ',') {
        // A karvai lengthens the note before it. With nothing before it there
        // is nothing to lengthen, so it becomes a rest of its own.
        if (out.isNotEmpty && out.last.isNote) {
          out.last.units += _unit(reading);
        } else {
          out.add(_Event.rest(_unit(reading)));
        }
        readAnything = true;
        continue;
      }
      // A pause/split mark and an anya-svara mark carry no time.
      if (ch == '-' || ch == '*') continue;
      // Octave dots: a leading dot lowers, a trailing dot or apostrophe raises.
      if (ch == '.') {
        if (out.isNotEmpty && out.last.isNote && readAnything) {
          out.last.octave -= 1;
        } else {
          pendingOctave = -1;
        }
        continue;
      }
      if (ch == "'" || ch == '’' || ch == '^') {
        if (out.isNotEmpty && out.last.isNote) out.last.octave += 1;
        continue;
      }

      final lower = ch.toLowerCase();
      if (!_letters.contains(lower)) {
        problems.add(CarnaticUnreadableCharacter(character: ch, token: token));
        continue;
      }

      // A digit straight after the letter is a variant: Ma1, Ri2, Ga3.
      var variant = '';
      if (i + 1 < text.length && RegExp(r'[1-4]').hasMatch(text[i + 1])) {
        variant = text[i + 1];
        i++;
      }

      final isUpper = ch == ch.toUpperCase();
      final units = switch (reading) {
        // Case is length: uppercase two aksharakalas, lowercase one.
        CarnaticCaseReading.duration => isUpper ? 2 * _akshara : _akshara,
        // Case is octave: every note is worth one akshara of the tala, which
        // is a whole beat. Case says nothing about how long a note lasts, so
        // upper and lower are the same length here.
        CarnaticCaseReading.octave => _perBeat,
      };
      final octave = switch (reading) {
        CarnaticCaseReading.duration => pendingOctave,
        CarnaticCaseReading.octave =>
          isUpper ? pendingOctave + 1 : pendingOctave,
      };

      out.add(
        _Event.note(
          name: _name(lower, variant, defaultMadhyamam),
          letter: lower,
          units: units,
          octave: octave,
        ),
      );
      pendingOctave = 0;
      readAnything = true;
    }

    if (packed) {
      // An underline means "sung together and faster within a particular beat"
      // — one kalam quicker, so everything this token added takes half as long.
      for (var i = startedAt; i < out.length; i++) {
        out[i].units = (out[i].units / 2).round().clamp(1, 1 << 20);
      }
    }
  }

  /// The two-letter name for a swara letter, per the app's house rule.
  ///
  /// A bare `m` has no variant in the source, so [defaultMadhyamam] decides.
  /// This is *not* raga grammar — see `docs/carnatic_notation.md` §5. The
  /// importer reports where the anya-svara phrase appears and leaves the call to
  /// a musician.
  String _name(String letter, String variant, int defaultMadhyamam) {
    const full = {
      's': 'Sa',
      'r': 'Ri',
      'g': 'Ga',
      'm': 'Ma',
      'p': 'Pa',
      'd': 'Da',
      'n': 'Ni',
    };
    final base = full[letter]!;
    if (variant.isNotEmpty) return '$base$variant';
    // Sa and Pa have no variants; the rest take the raga's usual one.
    const usual = {'r': '2', 'g': '3', 'd': '2', 'n': '3'};
    if (letter == 'm') return 'Ma$defaultMadhyamam';
    final digit = usual[letter];
    return digit == null ? base : '$base$digit';
  }

  /// Rewrites each madhyamam by the bhashanga rule: shuddha inside a
  /// descending `Ga -> Ma -> Ri`, prati everywhere else.
  ///
  /// Only called when the caller opts in. See [convert].
  void _applyAnyaSvaraRule(List<_Event> events) {
    final notes = events.where((e) => e.isNote).toList();
    for (var i = 0; i < notes.length; i++) {
      if (notes[i].letter != 'm') continue;
      final before = i > 0 ? notes[i - 1].letter : '';
      final after = i + 1 < notes.length ? notes[i + 1].letter : '';
      final shuddha = before == 'g' && after == 'r';
      notes[i].name = shuddha ? 'Ma1' : 'Ma2';
    }
  }

  /// True when this cycle contains a `Ga → Ma → Ri` descent.
  bool _hasGaMaRiDescent(List<_Event> events) {
    final notes = events.where((e) => e.isNote).toList();
    for (var i = 1; i + 1 < notes.length; i++) {
      if (notes[i].letter == 'm' &&
          notes[i - 1].letter == 'g' &&
          notes[i + 1].letter == 'r') {
        return true;
      }
    }
    return false;
  }

  // --- rendering -------------------------------------------------------------

  /// Lays the events on a timeline and writes them in our own format.
  ///
  /// The timeline is one cell per quarter-aksharakala, so a note that runs past
  /// a beat boundary keeps its real length instead of being snapped to the beat.
  /// The beat it continues into gets a **tie** slot, which our format writes as
  /// a `,` — the player stretches the sound rather than striking it again.
  String _render(List<_Event> events, int beats) {
    final cells = beats * _perBeat;
    // Which event owns each cell, and whether the cell is where it begins.
    final owner = List<_Event?>.filled(cells, null);
    final starts = List<bool>.filled(cells, false);

    var at = 0;
    for (final e in events) {
      final units = e.units <= 0 ? 1 : e.units;
      for (var i = 0; i < units && at + i < cells; i++) {
        owner[at + i] = e;
        starts[at + i] = i == 0;
      }
      at += units;
    }

    final tokens = <String>[];
    for (var b = 0; b < beats; b++) {
      tokens.add(_beatToken(owner, starts, b * _perBeat));
    }

    return '{melody} ${_group(tokens, beats)}';
  }

  /// One beat's worth of cells, written as a token in our format.
  String _beatToken(List<_Event?> owner, List<bool> starts, int from) {
    // Group the beat's cells into runs of the same event.
    final runs = <_Run>[];
    for (var i = from; i < from + _perBeat && i < owner.length; i++) {
      final event = owner[i];
      final isStart = starts[i];
      if (runs.isNotEmpty && !isStart && identical(runs.last.event, event)) {
        runs.last.count++;
      } else {
        runs.add(_Run(event, isStart));
      }
    }
    if (runs.isEmpty) return ',';

    // A beat made of one run needs no subdivision at all.
    if (runs.length == 1) {
      final run = runs.first;
      return run.isNoteStart ? run.event!.render() : ',';
    }

    // Shorten the counts as far as they will go: a beat of 2 + 2 quarter-cells
    // is two halves, so it is written with two slots, not four.
    var divisor = runs.first.count;
    for (final run in runs) {
      divisor = _gcd(divisor, run.count);
    }
    if (divisor <= 0) divisor = 1;

    final parts = <String>[];
    for (final run in runs) {
      final slots = run.count ~/ divisor;
      // A run that did not begin in this beat carries the previous sound on.
      parts.add(run.isNoteStart ? run.event!.render() : ',');
      for (var i = 1; i < slots; i++) {
        parts.add(',');
      }
    }
    return parts.join('-');
  }

  static int _gcd(int a, int b) {
    var x = a.abs();
    var y = b.abs();
    while (y != 0) {
      final t = y;
      y = x % y;
      x = t;
    }
    return x == 0 ? 1 : x;
  }

  /// How each tala divides its beats into angas.
  ///
  /// From `docs/carnatic_notation.md` §3. A `|` marks the end of an **anga** —
  /// a laghu, dhruta or anudhruta — not merely a visual gap, so these are the
  /// real divisions and not a formatting choice. A tala not listed here is
  /// written as one undivided run.
  static const Map<int, List<int>> _angas = {
    4: [4],
    5: [2, 3],
    6: [2, 4],
    7: [3, 2, 2],
    8: [4, 2, 2],
    10: [2, 4, 4],
    14: [4, 4, 2, 4],
  };

  /// Puts the tala's anga dividers back between the beats.
  String _group(List<String> tokens, int beats) {
    final groups = _angas[beats] ?? [beats];
    final out = <String>[];
    var i = 0;
    for (final size in groups) {
      if (i >= tokens.length) break;
      final end = (i + size).clamp(0, tokens.length);
      out.add(tokens.sublist(i, end).join(' '));
      i = end;
    }
    if (i < tokens.length) out.add(tokens.sublist(i).join(' '));
    return out.join(' | ');
  }
}

/// One thing that takes time: a note, or a rest.
class _Event {
  String? name;
  final String letter;
  int units;
  int octave;

  _Event.note({
    required this.name,
    required this.letter,
    required this.units,
    this.octave = 0,
  });

  _Event.rest(this.units) : name = null, letter = '', octave = 0;

  bool get isNote => name != null;

  /// The note as our format writes it, with its octave mark.
  String render() {
    final body = name!;
    if (octave < 0) return '.' * -octave + body;
    if (octave > 0) return body + "'" * octave;
    return body;
  }
}

/// A stretch of cells inside one beat that belong to the same event.
class _Run {
  _Run(this.event, this.isStart);

  final _Event? event;
  final bool isStart;
  int count = 1;

  /// True when a note begins here, rather than carrying on from before.
  bool get isNoteStart => isStart && (event?.isNote ?? false);
}

class _Avarta {
  final String line;
  final List<CarnaticProblem> problems;
  final bool fits;
  final bool sawAnyaSvaraPhrase;

  const _Avarta({
    required this.line,
    required this.problems,
    required this.fits,
    this.sawAnyaSvaraPhrase = false,
  });
}

class _Reading {
  final List<String> lines;
  final List<CarnaticProblem> problems;
  final List<int> anyaSvaraHints;
  final CarnaticFit fit;

  const _Reading({
    required this.lines,
    required this.problems,
    required this.anyaSvaraHints,
    required this.fit,
  });
}
