/// Key-aware chord suggestions for the editor's Quick Chord Inserter.
///
/// Pure logic — no UI, no storage, no navigation. Given a key written by the
/// user (`C`, `Am`, `Bb`, `F#m`, …) it returns the chords that key normally
/// uses, so the toolbar offers the right chords as the key field changes.
///
/// The note tables here are the app's single source of truth for note spelling.
/// Phase 4's transposer reuses them so a transposed chord is spelled the same
/// way a suggested chord is.
library;

/// The twelve notes written with sharps. Index = semitones above C.
const List<String> sharpNotes = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B',
];

/// The same twelve notes written with flats. Index = semitones above C.
const List<String> flatNotes = [
  'C',
  'Db',
  'D',
  'Eb',
  'E',
  'F',
  'Gb',
  'G',
  'Ab',
  'A',
  'Bb',
  'B',
];

/// A key split into its root note and whether it is minor.
class ParsedKey {
  /// Semitones above C, 0–11.
  final int rootSemitone;

  /// True for a minor key (`Am`, `F#m`), false for a major one (`C`, `Bb`).
  final bool minor;

  /// True when the key should be written with flats (`Bb`, `Eb`, …).
  final bool useFlats;

  const ParsedKey({
    required this.rootSemitone,
    required this.minor,
    required this.useFlats,
  });

  @override
  bool operator ==(Object other) =>
      other is ParsedKey &&
      other.rootSemitone == rootSemitone &&
      other.minor == minor &&
      other.useFlats == useFlats;

  @override
  int get hashCode => Object.hash(rootSemitone, minor, useFlats);

  @override
  String toString() =>
      'ParsedKey(rootSemitone: $rootSemitone, minor: $minor, '
      'useFlats: $useFlats)';
}

/// Builds the chord list shown in the editor toolbar.
///
/// Never throws and never returns an empty list: an unreadable key falls back
/// to C major, so the toolbar is always usable (see CLAUDE.md hard rule 4).
class ChordSuggestionService {
  const ChordSuggestionService();

  /// The key used when the typed key cannot be read.
  static const ParsedKey fallbackKey = ParsedKey(
    rootSemitone: 0,
    minor: false,
    useFlats: false,
  );

  /// Major-key chords: I, ii, iii, IV, V, vi, V7, then the borrowed flat-VII.
  static const List<_Degree> _majorDegrees = [
    _Degree(0, ''),
    _Degree(2, 'm'),
    _Degree(4, 'm'),
    _Degree(5, ''),
    _Degree(7, ''),
    _Degree(9, 'm'),
    _Degree(7, '7'),
    _Degree(10, '', flatName: true),
  ];

  /// Minor-key chords: i, ii(dim), flat-III, iv, v, flat-VI, flat-VII, and the
  /// major V7 that the harmonic minor borrows.
  static const List<_Degree> _minorDegrees = [
    _Degree(0, 'm'),
    _Degree(2, 'dim'),
    _Degree(3, '', flatName: true),
    _Degree(5, 'm'),
    _Degree(7, 'm'),
    _Degree(8, '', flatName: true),
    _Degree(10, '', flatName: true),
    _Degree(7, '7'),
  ];

  /// The chords normally used in [key].
  List<String> suggestionsForKey(String key) {
    final parsed = parseKey(key) ?? fallbackKey;
    final notes = parsed.useFlats ? flatNotes : sharpNotes;
    final degrees = parsed.minor ? _minorDegrees : _majorDegrees;

    return degrees
        .map((d) {
          final table = d.flatName ? flatNotes : notes;
          return table[(parsed.rootSemitone + d.semitones) % 12] + d.suffix;
        })
        .toList(growable: false);
  }

  /// Reads a key such as `C`, `Am`, `Bb`, `F#m`, `c#min`.
  ///
  /// Returns `null` when the text does not start with a note letter, so the
  /// caller can fall back instead of guessing.
  ParsedKey? parseKey(String key) {
    final text = key.trim();
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
    final semitone = accidental == 'b'
        ? flatNotes.indexOf(name)
        : sharpNotes.indexOf(name);
    if (semitone < 0) return null;

    return ParsedKey(
      rootSemitone: semitone,
      minor: _isMinor(rest),
      useFlats: accidental == 'b',
    );
  }

  static const Set<String> _noteLetters = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

  /// `m`, `min`, `minor` mean minor; `maj` does not.
  bool _isMinor(String quality) {
    final q = quality.trim().toLowerCase();
    if (q.isEmpty) return false;
    if (q.startsWith('maj')) return false;
    return q.startsWith('m');
  }
}

/// One chord of a key: how far above the root it sits, and its suffix.
class _Degree {
  final int semitones;
  final String suffix;

  /// True for degrees musicians name with a flat (♭III, ♭VI, ♭VII), so the
  /// flat-VII of C comes out as `Bb`, not `A#`.
  final bool flatName;

  const _Degree(this.semitones, this.suffix, {this.flatName = false});
}
