/// Works out how to play a chord: guitar fingering and harmonium (keyboard)
/// notes.
///
/// Pure logic — no UI, no storage. The Chord Reference dialog hands this service
/// a chord name (already transposed to the current key) and draws whatever comes
/// back. Widgets never do note theory themselves (architecture §"Rules").
///
/// Nothing here throws. A name that is not a real chord returns a safe fallback:
/// [guitarShape] returns `null` (the guitar tab then says "diagram not
/// available") and [harmoniumShape] returns the plain major triad. This is
/// CLAUDE.md hard rule 4 — never crash on odd input.
library;

import 'package:lyriccord/services/chord_suggestion_service.dart';

/// A guitar chord as fret numbers, one per string.
///
/// [frets] has six entries, low E first (index 0) to high e (index 5):
/// `-1` = the string is not played (muted, drawn `X`), `0` = played open
/// (drawn `O`), any other number = the absolute fret to press.
class GuitarChordShape {
  /// Six fret values, low E (index 0) to high e (index 5).
  final List<int> frets;

  const GuitarChordShape(this.frets);

  /// The highest fret that is actually pressed, or `0` if the chord is all
  /// open/muted. Used by the diagram to decide how far up the neck to draw.
  int get maxFret => frets.where((f) => f > 0).fold(0, (a, b) => a > b ? a : b);

  /// The lowest fret that is actually pressed, or `0` if none is.
  int get minFret {
    final pressed = frets.where((f) => f > 0);
    if (pressed.isEmpty) return 0;
    return pressed.reduce((a, b) => a < b ? a : b);
  }

  @override
  bool operator ==(Object other) =>
      other is GuitarChordShape && _listEquals(other.frets, frets);

  @override
  int get hashCode => Object.hashAll(frets);

  @override
  String toString() => 'GuitarChordShape($frets)';
}

/// A chord as notes on a keyboard, for the harmonium diagram.
///
/// Notes are pitch classes 0–11 (semitones above C), so the diagram can light
/// up the matching keys in any octave it draws.
class HarmoniumChordShape {
  /// The chord's notes as pitch classes 0–11, root first, no duplicates.
  final List<int> notes;

  /// The root note's pitch class (0–11) — drawn in a stronger shade.
  final int root;

  /// The bass note's pitch class for a slash chord (`C/E` → `E`), or `null`.
  final int? bass;

  const HarmoniumChordShape({
    required this.notes,
    required this.root,
    this.bass,
  });

  @override
  bool operator ==(Object other) =>
      other is HarmoniumChordShape &&
      _listEquals(other.notes, notes) &&
      other.root == root &&
      other.bass == bass;

  @override
  int get hashCode => Object.hash(Object.hashAll(notes), root, bass);

  @override
  String toString() =>
      'HarmoniumChordShape(notes: $notes, root: $root, bass: $bass)';
}

/// A chord split into its root note and the quality text after it.
class _ParsedChord {
  /// The root's pitch class, 0–11.
  final int root;

  /// The lower-cased quality suffix, e.g. `m`, `7`, `maj7`, `sus4`, or `''`.
  final String quality;

  const _ParsedChord(this.root, this.quality);
}

/// Turns a chord name into a guitar shape and a harmonium note set.
class ChordShapeService {
  const ChordShapeService();

  /// Notes (semitones above the root) for each chord quality.
  ///
  /// The lookup is longest-match-first (see [_intervalsFor]) so `maj7` is read
  /// as a major-seventh, not a major triad plus a stray `7`.
  static const Map<String, List<int>> _intervals = {
    'maj7': [0, 4, 7, 11],
    'maj9': [0, 4, 7, 11, 2],
    'm7b5': [0, 3, 6, 10],
    'm7': [0, 3, 7, 10],
    'm9': [0, 3, 7, 10, 2],
    'm6': [0, 3, 7, 9],
    'madd9': [0, 3, 7, 2],
    'mmaj7': [0, 3, 7, 11],
    'dim7': [0, 3, 6, 9],
    'dim': [0, 3, 6],
    'aug': [0, 4, 8],
    'sus2': [0, 2, 7],
    'sus4': [0, 5, 7],
    'sus': [0, 5, 7],
    'add9': [0, 4, 7, 2],
    '6': [0, 4, 7, 9],
    '9': [0, 4, 7, 10, 2],
    '7': [0, 4, 7, 10],
    'm': [0, 3, 7],
    '': [0, 4, 7],
  };

  /// The triad most players want for each quality when a barre shape is needed.
  /// Anything not here (a rich extension) uses the plain major/minor shape.
  static const Set<String> _majorLike = {'', '6', '9', 'add9', 'sus2', 'sus4'};
  static const Set<String> _minorLike = {'m', 'm6', 'm9', 'madd9', 'mmaj7'};

  // --- Guitar --------------------------------------------------------------

  /// The guitar fingering for [chord], or `null` when there is no known shape.
  ///
  /// Common open chords (C, G, Am, E7 …) use a hand-picked shape so they look
  /// the way a player expects. Everything else falls back to a movable barre
  /// shape at the chord's root, which covers all twelve roots.
  GuitarChordShape? guitarShape(String chord) {
    final root = chord.split('/').first.trim();
    if (root.isEmpty) return null;

    final open = _openChords[root];
    if (open != null) return GuitarChordShape(open);

    final parsed = _parse(root);
    if (parsed == null) return null;

    return _barreShape(parsed.root, parsed.quality);
  }

  /// Hand-picked open-position shapes for the everyday chords.
  static const Map<String, List<int>> _openChords = {
    // Major
    'C': [-1, 3, 2, 0, 1, 0],
    'A': [-1, 0, 2, 2, 2, 0],
    'G': [3, 2, 0, 0, 0, 3],
    'E': [0, 2, 2, 1, 0, 0],
    'D': [-1, -1, 0, 2, 3, 2],
    'F': [1, 3, 3, 2, 1, 1],
    // Minor
    'Am': [-1, 0, 2, 2, 1, 0],
    'Em': [0, 2, 2, 0, 0, 0],
    'Dm': [-1, -1, 0, 2, 3, 1],
    // Dominant 7
    'C7': [-1, 3, 2, 3, 1, 0],
    'A7': [-1, 0, 2, 0, 2, 0],
    'G7': [3, 2, 0, 0, 0, 1],
    'E7': [0, 2, 0, 1, 0, 0],
    'D7': [-1, -1, 0, 2, 1, 2],
    'B7': [-1, 2, 1, 2, 0, 2],
    // Minor 7
    'Am7': [-1, 0, 2, 0, 1, 0],
    'Em7': [0, 2, 0, 0, 0, 0],
    'Dm7': [-1, -1, 0, 2, 1, 1],
    // Major 7
    'Cmaj7': [-1, 3, 2, 0, 0, 0],
    'Amaj7': [-1, 0, 2, 1, 2, 0],
    'Gmaj7': [3, 2, 0, 0, 0, 2],
    'Emaj7': [0, 2, 1, 1, 0, 0],
    'Dmaj7': [-1, -1, 0, 2, 2, 2],
    'Fmaj7': [-1, -1, 3, 2, 1, 0],
  };

  /// Builds a movable barre chord for [rootSemitone] and [quality].
  ///
  /// It tries the E-shape (root on the low E string) and the A-shape (root on
  /// the A string) and keeps whichever sits at the lower fret, so the diagram
  /// stays near the nut. Returns `null` for a quality with no barre template.
  GuitarChordShape? _barreShape(int rootSemitone, String quality) {
    final shape = _barreTemplateFor(quality);
    if (shape == null) return null;

    // Open-string pitch classes, low E to high e: E A D G B e.
    const eStringNote = 4; // E
    const aStringNote = 9; // A

    final eBarre = _wrap(rootSemitone - eStringNote); // 0–11
    final aBarre = _wrap(rootSemitone - aStringNote);

    // A barre at fret 0 means an open chord we did not list; push it up an
    // octave (fret 12) so the finger positions are real presses, not "open".
    final ePos = eBarre == 0 ? 12 : eBarre;
    final aPos = aBarre == 0 ? 12 : aBarre;

    final useE = ePos <= aPos;
    final barre = useE ? ePos : aPos;
    final template = useE ? shape.eShape : shape.aShape;

    return GuitarChordShape([
      for (final offset in template) offset < 0 ? -1 : barre + offset,
    ]);
  }

  /// Picks the barre template (E-shape and A-shape offsets) for a quality.
  _BarreTemplate? _barreTemplateFor(String quality) {
    if (_majorLike.contains(quality)) return _BarreTemplate.major;
    if (_minorLike.contains(quality)) return _BarreTemplate.minor;
    switch (quality) {
      case '7':
      case '9':
        return _BarreTemplate.dom7;
      case 'm7':
        return _BarreTemplate.min7;
      case 'maj7':
      case 'maj9':
        return _BarreTemplate.maj7;
      default:
        // A quality we cannot draw as a barre (dim, aug, …) — fall back to the
        // plain major/minor triad so the player at least sees the root chord.
        return quality.startsWith('m')
            ? _BarreTemplate.minor
            : _BarreTemplate.major;
    }
  }

  // --- Harmonium -----------------------------------------------------------

  /// The keyboard notes for [chord]. Always returns a value.
  ///
  /// A quality it does not recognise falls back to the major triad, so the
  /// harmonium tab always draws something.
  HarmoniumChordShape harmoniumShape(String chord) {
    final parts = chord.split('/');
    final parsed = _parse(parts.first.trim());

    // Unreadable root — show C major rather than nothing.
    final root = parsed?.root ?? 0;
    final quality = parsed?.quality ?? '';
    final intervals = _intervalsFor(quality);

    final notes = <int>[];
    for (final step in intervals) {
      final note = _wrap(root + step);
      if (!notes.contains(note)) notes.add(note);
    }

    int? bass;
    if (parts.length > 1) {
      final bassParsed = _parse(parts[1].trim());
      bass = bassParsed?.root;
    }

    return HarmoniumChordShape(notes: notes, root: root, bass: bass);
  }

  /// The interval set for a quality, longest suffix first so `maj7` wins over
  /// `7`. Unknown qualities fall back to the major triad.
  List<int> _intervalsFor(String quality) {
    if (_intervals.containsKey(quality)) return _intervals[quality]!;
    // Try the longest known suffix that the quality starts with, e.g. `7sus4`
    // or `9` variants map to a sensible base.
    for (final key in _intervalsLongestFirst) {
      if (key.isNotEmpty && quality.startsWith(key)) return _intervals[key]!;
    }
    return _intervals['']!;
  }

  /// Interval keys sorted longest first, for the startsWith fallback above.
  static final List<String> _intervalsLongestFirst = _intervals.keys.toList(
    growable: false,
  )..sort((a, b) => b.length.compareTo(a.length));

  // --- Parsing -------------------------------------------------------------

  /// Reads a chord's root note and quality, e.g. `F#m7` → (root F#, `m7`).
  ///
  /// Returns `null` when the text does not start with a note letter, so the
  /// caller can fall back instead of guessing.
  _ParsedChord? _parse(String chord) {
    final text = chord.trim();
    if (text.isEmpty) return null;

    final letter = text[0].toUpperCase();
    if (!_noteLetters.contains(letter)) return null;

    var rest = text.substring(1);
    var accidental = '';
    if (rest.startsWith('#') || rest.startsWith('b')) {
      accidental = rest[0];
      rest = rest.substring(1);
    }

    final name = letter + accidental;
    final root = accidental == 'b'
        ? flatNotes.indexOf(name)
        : sharpNotes.indexOf(name);
    if (root < 0) return null;

    return _ParsedChord(root, rest.trim());
  }

  static const Set<String> _noteLetters = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

  /// Keeps a pitch class inside 0–11.
  int _wrap(int semitone) => ((semitone % 12) + 12) % 12;
}

/// A movable barre chord as string offsets above the barre fret.
///
/// `-1` means the string is muted. Index 0 is low E, index 5 is high e.
class _BarreTemplate {
  final List<int> eShape;
  final List<int> aShape;

  const _BarreTemplate(this.eShape, this.aShape);

  // E-shape: root on the low E string. A-shape: root on the A string (low E
  // muted). Offsets are frets above the barre.
  static const major = _BarreTemplate([0, 2, 2, 1, 0, 0], [-1, 0, 2, 2, 2, 0]);
  static const minor = _BarreTemplate([0, 2, 2, 0, 0, 0], [-1, 0, 2, 2, 1, 0]);
  static const dom7 = _BarreTemplate([0, 2, 0, 1, 0, 0], [-1, 0, 2, 0, 2, 0]);
  static const min7 = _BarreTemplate([0, 2, 0, 0, 0, 0], [-1, 0, 2, 0, 1, 0]);
  static const maj7 = _BarreTemplate([0, 2, 1, 1, 0, 0], [-1, 0, 2, 1, 2, 0]);
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
