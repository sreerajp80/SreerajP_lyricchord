/// The outcome of converting published Carnatic notation into `{melody}` lines.
///
/// Published notation is not one system. The same letter case means note
/// *duration* on some pages and note *octave* on others, and a page rarely says
/// which — see `docs/carnatic_notation.md` §4a. So the importer does not guess:
/// it converts under both readings, scores each against the tala, and hands back
/// the winner together with the evidence.
///
/// Nothing here throws. Bad input comes back as [problems], never as an
/// exception, because the one untrusted input this app has is a pasted file.
library;

/// Which meaning a page gives to upper- and lower-case swara letters.
enum CarnaticCaseReading {
  /// Uppercase is two aksharakalas, lowercase is one — case carries length.
  ///
  /// The convention Ramya documents and the one the krithi notation pages use.
  duration,

  /// Uppercase is the upper octave, lowercase the middle — case carries pitch.
  ///
  /// The convention karnatik.com documents and the beginner exercise pages use.
  octave,

  // The screen label lives in `lib/l10n/l10n_labels.dart` (no UI text in
  // models).
}

/// How well one reading of the notation lands on the tala.
///
/// The right convention makes **every** cycle come out to the tala's beat count.
/// A reading that leaves cycles short or long is the wrong reading, so this
/// score is what decides between them.
class CarnaticFit {
  /// The reading this score belongs to.
  final CarnaticCaseReading reading;

  /// Cycles whose beats add up exactly to the tala.
  final int fitting;

  /// Cycles found in the input.
  final int total;

  const CarnaticFit({
    required this.reading,
    required this.fitting,
    required this.total,
  });

  /// `0.0`–`1.0`. A perfect reading scores `1.0`.
  double get ratio => total == 0 ? 0 : fitting / total;

  /// True when every cycle lands on the tala.
  bool get isPerfect => total > 0 && fitting == total;

  @override
  String toString() => '${reading.name}: $fitting/$total';
}

/// One thing the caller should see before trusting an import.
///
/// The importer only says *what* went wrong; the screen turns it into words
/// (`lib/l10n/l10n_labels.dart`), so no English is built in the service.
/// [cycle] is set (1-based) for a problem found inside one avarta.
sealed class CarnaticProblem {
  const CarnaticProblem({this.cycle});

  final int? cycle;

  /// The same problem, tagged with the avarta it was found in.
  CarnaticProblem inCycle(int cycle) => this;
}

/// The tala name gave no beat count.
class CarnaticUnknownTala extends CarnaticProblem {
  const CarnaticUnknownTala(this.tala);

  final String tala;
}

/// The pasted text held no notation at all.
class CarnaticNoNotation extends CarnaticProblem {
  const CarnaticNoNotation();
}

/// Only [fitting] of [total] cycles came out the length of [tala].
class CarnaticCyclesOffTala extends CarnaticProblem {
  const CarnaticCyclesOffTala({
    required this.fitting,
    required this.total,
    required this.tala,
  });

  final int fitting;
  final int total;
  final String tala;
}

/// Both readings of letter case scored the same, so the choice is a guess.
class CarnaticReadingsTie extends CarnaticProblem {
  const CarnaticReadingsTie();
}

/// A cycle held nothing that could be read.
class CarnaticNothingReadable extends CarnaticProblem {
  const CarnaticNothingReadable({super.cycle});

  @override
  CarnaticProblem inCycle(int cycle) => CarnaticNothingReadable(cycle: cycle);
}

/// A cycle came out [got] aksharakalas long instead of [wanted].
class CarnaticWrongLength extends CarnaticProblem {
  const CarnaticWrongLength({
    required this.got,
    required this.wanted,
    super.cycle,
  });

  /// Aksharakalas the cycle actually holds; may be a half (3.5).
  final double got;
  final int wanted;

  @override
  CarnaticProblem inCycle(int cycle) =>
      CarnaticWrongLength(got: got, wanted: wanted, cycle: cycle);
}

/// [character] in [token] is not a swara letter or a mark.
class CarnaticUnreadableCharacter extends CarnaticProblem {
  const CarnaticUnreadableCharacter({
    required this.character,
    required this.token,
    super.cycle,
  });

  final String character;
  final String token;

  @override
  CarnaticProblem inCycle(int cycle) => CarnaticUnreadableCharacter(
    character: character,
    token: token,
    cycle: cycle,
  );
}

/// Converted melody lines plus everything needed to judge the conversion.
class CarnaticImportResult {
  /// One `{melody}` line per avarta, in source order.
  final List<String> melodyLines;

  /// The reading the importer chose, and how it scored.
  final CarnaticFit chosen;

  /// The reading it rejected, and how that scored. `null` when only one was
  /// tried (an input with no case variation, say).
  final CarnaticFit? rejected;

  /// Anything the caller should see before trusting the result: cycles that did
  /// not land on the tala, tokens that could not be read, a tie between the two
  /// readings.
  final List<CarnaticProblem> problems;

  /// Places where a `Ga → Ma → Ri` descent was seen.
  ///
  /// In a bhashanga raga such as Yamunakalyani the borrowed shuddha madhyamam
  /// belongs only to this phrase (`docs/carnatic_notation.md` §5). The notation
  /// does not mark it and the importer will not guess it — it reports the
  /// positions and leaves the choice to a musician.
  final List<int> anyaSvaraHints;

  const CarnaticImportResult({
    required this.melodyLines,
    required this.chosen,
    this.rejected,
    this.problems = const [],
    this.anyaSvaraHints = const [],
  });

  /// An empty result carrying a single problem, for input that cannot be read.
  factory CarnaticImportResult.failure(CarnaticProblem problem) =>
      CarnaticImportResult(
        melodyLines: const [],
        chosen: const CarnaticFit(
          reading: CarnaticCaseReading.duration,
          fitting: 0,
          total: 0,
        ),
        problems: [problem],
      );

  /// True when there is something usable to insert.
  bool get hasLines => melodyLines.isNotEmpty;

  /// True when the chosen reading fits perfectly and nothing was flagged.
  bool get isClean => chosen.isPerfect && problems.isEmpty;

  /// True when both readings fit equally well, so the choice between them was
  /// arbitrary and the caller should say so rather than present it as settled.
  ///
  /// Equal scores of zero are not ambiguity — that is both readings failing,
  /// which the problems list already reports.
  bool get isAmbiguous =>
      rejected != null &&
      rejected!.fitting == chosen.fitting &&
      chosen.fitting > 0;
}
