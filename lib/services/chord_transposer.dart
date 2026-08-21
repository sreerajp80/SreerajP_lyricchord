/// Moves chords up or down by semitones.
///
/// Pure logic — no UI, no storage. Ported from the Android app's
/// `ChordTransposer`.
///
/// Two rules matter:
/// - **Slash chords move as a whole.** `C/E` up two semitones is `D/F#`, so the
///   bass note stays a third below the root.
/// - **Spelling follows the resulting key.** In Bb the chords are written with
///   flats (`Bb`, `Eb`), in D with sharps (`D`, `F#`). Musicians read that way,
///   and it matches the editor's chord suggestions, which use the same note
///   tables.
///
/// Nothing here throws. Text that is not a chord — a word, a number, an odd
/// notation — is returned exactly as it came in (CLAUDE.md hard rule 4).
library;

import 'package:lyricchord/services/chord_sheet_parser.dart';
import 'package:lyricchord/services/chord_suggestion_service.dart';

/// Transposes single chords, whole lyric bodies, and keys.
class ChordTransposer {
  const ChordTransposer();

  static const ChordSuggestionService _keys = ChordSuggestionService();
  static const ChordSheetParser _parser = ChordSheetParser();

  /// Major keys normally written with flats: Db, Eb, Ab, Bb.
  static const Set<int> _flatMajorRoots = {1, 3, 8, 10};

  /// Minor keys normally written with flats: Eb minor and Bb minor.
  static const Set<int> _flatMinorRoots = {3, 10};

  /// True when a key [semitones] above [key] is normally written with flats.
  ///
  /// Used so a transposed sheet is spelled the way the new key is spelled. An
  /// unreadable key falls back to sharps, the safer default.
  bool useFlatsAfter(String key, int semitones) {
    final parsed = _keys.parseKey(key);
    if (parsed == null) return false;

    final root = _wrap(parsed.rootSemitone + semitones);
    return parsed.minor
        ? _flatMinorRoots.contains(root)
        : _flatMajorRoots.contains(root);
  }

  /// The key [semitones] away from [key], e.g. `Am` + 2 → `Bm`.
  ///
  /// Returns [key] unchanged when it cannot be read, so the header never shows
  /// nonsense.
  String transposeKey(String key, int semitones) {
    final parsed = _keys.parseKey(key);
    if (parsed == null) return key;

    final root = _wrap(parsed.rootSemitone + semitones);
    final useFlats = parsed.minor
        ? _flatMinorRoots.contains(root)
        : _flatMajorRoots.contains(root);
    final name = (useFlats ? flatNotes : sharpNotes)[root];

    // Keep whatever minor wording the user typed (`m`, `min`, `minor`).
    if (!parsed.minor) return name;
    final quality = _minorQualityOf(key);
    return name + quality;
  }

  /// Moves one chord, e.g. `C/E` + 2 → `D/F#`.
  ///
  /// [useFlats] picks the spelling; get it from [useFlatsAfter] so the whole
  /// sheet agrees. Anything that is not a chord comes back untouched.
  String transposeChord(String chord, int semitones, {bool useFlats = false}) {
    final text = chord.trim();
    if (text.isEmpty) return chord;
    if (semitones % 12 == 0) return chord;

    final slash = text.indexOf('/');
    if (slash >= 0) {
      final root = _transposeToken(
        text.substring(0, slash),
        semitones,
        useFlats,
      );
      final bass = _transposeToken(
        text.substring(slash + 1),
        semitones,
        useFlats,
      );
      if (root == null || bass == null) return chord;
      return '$root/$bass';
    }

    return _transposeToken(text, semitones, useFlats) ?? chord;
  }

  /// Moves every `[Chord]` inside [lyrics], leaving the words alone.
  ///
  /// [originalKey] decides the spelling of the result.
  ///
  /// An Indian sheet — one that names a `{raga: …}` — comes back completely
  /// unchanged. That is right musically: a swara is already named relative to
  /// Sa, so moving Sa moves every swara with it and the written notation does
  /// not change. There is nothing for a transpose to do.
  ///
  /// It is also necessary. [transposeChord] reads only the first letter, so
  /// `[Ga]` and `[Dha]` look like a G and a D chord and would be mangled into
  /// `[Aa]` and `[Eha]`. The song has to decide, not the token: a lone `[D]` in
  /// a Western song really is a D chord, and nothing about that one token can
  /// tell the two apart.
  ///
  /// Pass [isIndian] from the song's stored `tradition` whenever the caller has
  /// a saved song. Reading the `{raga: …}` line is only a fallback for text
  /// that has no row yet, such as a file being imported: a misspelt header
  /// (`{ragam: …}`) would otherwise make an Indian sheet look Western and get
  /// its swaras rewritten.
  String transposeLyrics(
    String lyrics,
    int semitones,
    String originalKey, {
    bool? isIndian,
  }) {
    if (isIndian ?? _parser.parseSheet(lyrics).isIndianNotation) return lyrics;

    final useFlats = useFlatsAfter(originalKey, semitones);

    return lyrics.replaceAllMapped(_chordMarker, (match) {
      final inner = match.group(1) ?? '';
      final movedChord = semitones % 12 == 0
          ? inner
          : transposeChord(inner, semitones, useFlats: useFlats);
      return '[$movedChord]';
    });
  }

  /// The chords used in [lyrics], already moved by [semitones].
  ///
  /// Phase 6's chord reference dialog needs the sounding chords, not the
  /// written ones.
  ///
  /// An Indian sheet's markers are returned as written, for the same reason as
  /// in [transposeLyrics]. [isIndian] works the same way there too.
  List<String> chordsUsed(
    String lyrics,
    int semitones,
    String originalKey, {
    bool? isIndian,
  }) {
    if (isIndian ?? _parser.parseSheet(lyrics).isIndianNotation) {
      return _parser.chordsUsed(lyrics);
    }

    final useFlats = useFlatsAfter(originalKey, semitones);
    final moved = _parser
        .chordsUsed(lyrics)
        .map((c) => transposeChord(c, semitones, useFlats: useFlats));
    return {...moved}.toList(growable: false);
  }

  /// A `[Chord]` marker. The inner part must not contain a bracket, so an
  /// unclosed `[` is left alone.
  static final RegExp _chordMarker = RegExp(r'\[([^\[\]]+)\]');

  /// Moves one chord with no slash. Returns `null` when the root is not a note.
  String? _transposeToken(String token, int semitones, bool useFlats) {
    final text = token.trim();
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
    final from = accidental == 'b'
        ? flatNotes.indexOf(name)
        : sharpNotes.indexOf(name);
    if (from < 0) return null;

    final to = _wrap(from + semitones);
    return (useFlats ? flatNotes : sharpNotes)[to] + rest;
  }

  static const Set<String> _noteLetters = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

  /// The minor wording the user typed, e.g. `m`, `min`, `minor`. Defaults to
  /// `m` when the key was written some other way.
  String _minorQualityOf(String key) {
    final text = key.trim();
    var rest = text.length > 1 ? text.substring(1) : '';
    if (rest.startsWith('#') || rest.startsWith('b')) {
      rest = rest.substring(1);
    }
    return rest.isEmpty ? 'm' : rest;
  }

  /// Keeps a semitone count inside 0–11, so going past B wraps back to C and
  /// going below C wraps up to B.
  int _wrap(int semitone) => ((semitone % 12) + 12) % 12;
}
