import 'package:lyricchord/models/pitch_tradition.dart';
import 'package:lyricchord/services/swara_notation_service.dart';

/// Names a pitch the way a song's own tradition names it, and works out which
/// tradition a song belongs to.
///
/// **Why an absolute pitch is still needed.** In Indian classical music Sa is
/// movable — it sits wherever the singer's voice is comfortable, so "Sa" alone
/// cannot produce a tone. The app must anchor Sa to a real frequency. Indian
/// musicians do exactly the same thing; they simply name the anchor their own
/// way ("my Sa is 5 kattai"), which is what this service provides.
///
/// Pure logic — no UI, no storage, no audio.
class PitchNamingService {
  const PitchNamingService({this._swara = const SwaraNotation()});

  final SwaraNotation _swara;

  /// The twelve pitches, written with sharps. Index = semitones above C.
  ///
  /// This is the list the key chips are built from, so everything else maps
  /// into it.
  static const List<String> chromatic = [
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

  /// Carnatic kattai names, index = semitones above C.
  ///
  /// This follows the common harmonium convention: whole numbers for the white
  /// keys, halves for the black ones. Some teachers count 1–12 straight up
  /// instead; if that is wanted, this one list is the only thing to change.
  static const List<String> _kattai = [
    '1',
    '1½',
    '2',
    '2½',
    '3',
    '4',
    '4½',
    '5',
    '5½',
    '6',
    '6½',
    '7',
  ];

  /// Hindustani harmonium names, index = semitones above C.
  /// White keys are "safed", black keys are "kaali", each counted separately.
  static const List<String> _harmonium = [
    'safed 1',
    'kaali 1',
    'safed 2',
    'kaali 2',
    'safed 3',
    'safed 4',
    'kaali 3',
    'safed 5',
    'kaali 4',
    'safed 6',
    'kaali 5',
    'safed 7',
  ];

  /// Flats spelled as the sharp that sounds the same.
  ///
  /// [ChordTransposer] deliberately writes Db, Eb, Ab and Bb with flats because
  /// musicians read them that way, so a song key can arrive spelled either way.
  static const Map<String, String> _flatToSharp = {
    'Db': 'C#',
    'Eb': 'D#',
    'Fb': 'E',
    'Gb': 'F#',
    'Ab': 'G#',
    'Bb': 'A#',
    'Cb': 'B',
  };

  /// [note] named for [tradition] — `G`, `5 kattai (G)` or `safed 5 (G)`.
  ///
  /// The Western letter is kept in brackets for the Indian traditions on
  /// purpose: it is the anchor the tone is actually generated from, and many
  /// players cross-check it against a tuner or a keyboard.
  ///
  /// An unknown note is returned unchanged rather than throwing — a bad key in
  /// an imported file must never break the screen (hard rule 4).
  String label(String note, PitchTradition tradition) {
    if (tradition == PitchTradition.western) return note;

    final index = _semitone(note);
    if (index == null) return note;

    return switch (tradition) {
      PitchTradition.carnatic => '${_kattai[index]} kattai ($note)',
      PitchTradition.hindustani => '${_harmonium[index]} ($note)',
      PitchTradition.western => note,
    };
  }

  /// Just the tradition's own name for [note], with no Western letter —
  /// `G`, `5 kattai`, `safed 5`. For places too tight for the full label.
  String shortLabel(String note, PitchTradition tradition) {
    if (tradition == PitchTradition.western) return note;

    final index = _semitone(note);
    if (index == null) return note;

    return switch (tradition) {
      PitchTradition.carnatic => '${_kattai[index]} kattai',
      PitchTradition.hindustani => _harmonium[index],
      PitchTradition.western => note,
    };
  }

  /// The chip in [chromatic] that [songKey] sounds as, or `null` when the key
  /// cannot be read.
  ///
  /// Song keys arrive in more shapes than the chip list holds: minor keys
  /// (`Am`, `F#m`), flats (`Bb`, `Eb`), and lower case from a hand-typed file.
  /// All of those name a real pitch, so all of them should light up a chip.
  /// Only the root matters — a drone on A is the same tone for `A` and `Am`.
  String? chipForSongKey(String songKey) {
    final index = _semitone(songKey);
    return index == null ? null : chromatic[index];
  }

  /// Which tradition a song belongs to.
  ///
  /// A song with no raga is Western. A song with a raga is Indian, and its tala
  /// says which kind. When a song names a raga but no tala this can place, the
  /// caller's [fallback] decides — that is the user's "Pitch naming" setting.
  PitchTradition detect({
    String? raga,
    String? tala,
    PitchTradition fallback = PitchTradition.carnatic,
  }) {
    if (raga == null || raga.trim().isEmpty) return PitchTradition.western;

    if (tala != null && tala.trim().isNotEmpty) {
      final tradition = _swara.talaTradition(tala);
      if (tradition != null) {
        return tradition == TalaTradition.carnatic
            ? PitchTradition.carnatic
            : PitchTradition.hindustani;
      }
    }

    // A raga with no readable tala is still Indian, so never fall back to
    // Western here — that would put letters back on an Indian sheet.
    return fallback == PitchTradition.western
        ? PitchTradition.carnatic
        : fallback;
  }

  /// Whether [tala] belongs to [tradition], or `null` when it cannot be judged.
  ///
  /// `null` covers an empty tala, a tala name the app does not know, and a
  /// Western [tradition] — in none of those cases is there anything to compare.
  /// Callers should treat `null` as "no opinion" and stay silent.
  ///
  /// The check is on the **tala**, not the raga, for the same reason [detect]
  /// is: tala names split cleanly between the two traditions, while many raga
  /// names are shared. Picking "Carnatic" and then typing a Hindustani tala is
  /// worth a warning, but the app cannot judge a raga name at all.
  bool? talaMatchesTradition(String tala, PitchTradition tradition) {
    if (tradition == PitchTradition.western) return null;
    if (tala.trim().isEmpty) return null;

    final talaTradition = _swara.talaTradition(tala);
    if (talaTradition == null) return null;

    final expected = talaTradition == TalaTradition.carnatic
        ? PitchTradition.carnatic
        : PitchTradition.hindustani;
    return expected == tradition;
  }

  /// Reads a `{tonic: ...}` value back into a note key such as `C` or `F#`.
  ///
  /// Accepts what a musician would actually type for their Sa: a Western key
  /// (`C#`, `Bb`), or a Carnatic kattai (`1 kattai`, `5½ kattai`, `5.5`,
  /// `5 1/2`). Returns `null` for anything it cannot place, so the caller can
  /// stay silent rather than humming a guessed pitch.
  ///
  /// This is the reverse of [shortLabel] for the Carnatic tradition, and it is
  /// the one thing that turns a written tonic into a real frequency.
  String? noteForTonic(String tonic) {
    var text = tonic.trim().toLowerCase();
    if (text.isEmpty) return null;

    // Drop the word itself so `1 kattai` and `1` are the same.
    text = text.replaceAll(RegExp(r'\s*kattai\s*'), ' ').trim();
    if (text.isEmpty) return null;

    // Halves get written several ways. Fold them all to the ½ the table uses.
    final kattai = text
        .replaceAll(RegExp(r'\s*(1/2|\.5|½)\s*$'), '½')
        .replaceAll(' ', '');
    final kattaiIndex = _kattai.indexOf(kattai);
    if (kattaiIndex != -1) return chromatic[kattaiIndex];

    final semitone = _semitone(tonic);
    return semitone == null ? null : chromatic[semitone];
  }

  /// Semitones above C for [key], or `null` when it names no pitch.
  ///
  /// Reads the root and any single sharp/flat, then ignores everything after
  /// it — the `m` of `Am`, the `maj7` of `Cmaj7`, and anything past a slash.
  int? _semitone(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return null;

    final root = trimmed.split('/').first.trim();
    final match = RegExp(r'^([A-Ga-g])([#b]?)').firstMatch(root);
    if (match == null) return null;

    final letter = match.group(1)!.toUpperCase();
    final accidental = match.group(2)!;
    final spelled = '$letter$accidental';

    final sharp = _flatToSharp[spelled] ?? spelled;
    final index = chromatic.indexOf(sharp);
    return index == -1 ? null : index;
  }
}
