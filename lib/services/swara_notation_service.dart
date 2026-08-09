/// Indian classical music vocabulary: swara names and tala beat counts.
///
/// Pure logic — no UI, no storage.
///
/// This service **does not convert** between notations. A Western song stays
/// Western and an Indian song stays Indian; the app only needs to *recognise*
/// swara text the writer typed, never to invent it from a chord. (Mapping a
/// chord root to a swara and keeping the Western quality produced nonsense like
/// `P7`, which is why that code is gone.)
library;

/// Swara vocabulary and tala lengths.
class SwaraNotation {
  const SwaraNotation();

  /// Short swara symbols, low to high.
  static const List<String> swaraSymbols = ['S', 'R', 'G', 'M', 'P', 'D', 'N'];

  /// Full swara names, low to high.
  static const List<String> swaraFullNames = [
    'Sa',
    'Ri',
    'Ga',
    'Ma',
    'Pa',
    'Dha',
    'Ni',
  ];

  /// Alternative spellings people write for the same swaras.
  static const List<String> _swaraAliases = [
    'Re', // Hindustani spelling of Ri
    'Dh', // short Dha
  ];

  /// Characters that only separate swaras and carry no pitch: the beat dash,
  /// the tala bar line, commas and the octave dots/apostrophes people add.
  static const String separators = '-|,.’\'`^_ \t';

  /// True when [token] is a swara, with any octave or variant marks removed.
  ///
  /// Accepts `S`, `Sa`, `R1`, `R₂`, `ma`, `Dha`, `Re` and the same with octave
  /// marks (`S'`, `.P`). Returns false for anything else, so a Western chord or
  /// an ordinary lyric word is never mistaken for a swara.
  bool isSwaraToken(String token) {
    final bare = _stripMarks(token);
    if (bare.isEmpty) return false;

    final lower = bare.toLowerCase();
    for (final name in swaraFullNames) {
      if (lower == name.toLowerCase()) return true;
    }
    for (final alias in _swaraAliases) {
      if (lower == alias.toLowerCase()) return true;
    }
    if (bare.length == 1) {
      final upper = bare.toUpperCase();
      return swaraSymbols.contains(upper);
    }
    return false;
  }

  /// Where [token] sits in the octave: semitones above Sa, `0`–`11`. Returns
  /// `null` when the token is not a swara this can place.
  ///
  /// The count is **relative to Sa, not to C**. `7` means "seven semitones
  /// above Sa, wherever Sa is" — the same relative counting a Swaram line
  /// already uses. Nothing here names a Western pitch.
  ///
  /// Sa and Pa are fixed. The other five each have two forms:
  ///
  /// | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
  /// |---|---|---|---|---|---|---|---|---|---|----|----|
  /// | S | r | R | g | G | m | M | P | d | D | n  | N  |
  ///
  /// How a written token is read:
  ///
  /// 1. A Carnatic digit wins over everything: `R1`, `G3`, `M2`, `N3`.
  /// 2. A full name is always shuddha: `Sa`, `Ri`/`Re`, `Ga`, `Ma`, `Pa`,
  ///    `Dha`, `Ni`.
  /// 3. A lowercase single letter is komal: `r`, `g`, `d`, `n`.
  /// 4. An uppercase single letter is shuddha: `R`, `G`, `D`, `N`.
  ///
  /// **`M` means shuddha Ma here, not tivra.** Strict Hindustani shorthand
  /// reads a capital M as tivra, but this app's own seeded songs shipped `[M]`
  /// meaning the ordinary Ma, and that text is on users' phones. Reading it as
  /// tivra now would silently change songs people already have. Tivra Ma is
  /// written `M2`, `Ma tivra`, or `M'`.
  int? swaraPosition(String token) {
    var text = token.trim();
    if (text.isEmpty) return null;

    // Octave marks do not change which swara it is, and they must come off
    // before the tivra apostrophe is looked for.
    text = text.replaceAll(RegExp(r'[.`^_]'), '').trim();
    if (text.isEmpty) return null;

    // A trailing "tivra"/"teevra" or an apostrophe on Ma raises it. Read this
    // before the digit, so `M'` and `M2` agree.
    final tivra = RegExp(r"(\s*(tivra|teevra)|['’])$", caseSensitive: false);
    final isTivra = tivra.hasMatch(text);
    if (isTivra) text = text.replaceAll(tivra, '').trim();

    // A trailing "komal" lowers it, the same way as a lowercase letter.
    final komal = RegExp(r'\s*komal$', caseSensitive: false);
    final isKomal = komal.hasMatch(text);
    if (isKomal) text = text.replaceAll(komal, '').trim();
    if (text.isEmpty) return null;

    // 1. Carnatic digits are exact — read them before anything is stripped.
    final digit = _carnaticPositions[_normaliseDigit(text)];
    if (digit != null) return digit;

    final lower = text.toLowerCase();

    // 2. A full name is shuddha. `Ma tivra` has already lost its suffix, so
    // the tivra flag is applied here.
    final full = _shuddhaByName[lower];
    if (full != null) {
      if (isKomal) return _komalOf(full);
      if (isTivra) return _tivraOf(full);
      return full;
    }

    // 3 and 4. A single letter: case carries komal/shuddha.
    if (text.length == 1) {
      final shuddha = _shuddhaByLetter[text.toUpperCase()];
      if (shuddha == null) return null;

      final lowercase = text != text.toUpperCase();
      if (lowercase || isKomal) return _komalOf(shuddha);
      if (isTivra) return _tivraOf(shuddha);
      return shuddha;
    }

    return null;
  }

  /// Uppercases the letter and drops a subscript digit, so `r₁` and `R1` match
  /// the same key in [_carnaticPositions].
  String _normaliseDigit(String text) {
    const subscripts = {'₁': '1', '₂': '2', '₃': '3'};
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(subscripts[char] ?? char);
    }
    return buffer.toString().toUpperCase();
  }

  /// One semitone below the shuddha form.
  ///
  /// Only Ri, Ga, Dha and Ni have a komal form. Sa and Pa are fixed, and Ma
  /// moves the other way (tivra), so all three stay where they are — this is
  /// why a lowercase `m` is still shuddha Ma and not Ga.
  int _komalOf(int shuddha) =>
      const {2, 4, 9, 11}.contains(shuddha) ? shuddha - 1 : shuddha;

  /// One semitone above. Only Ma has a tivra form; everything else is already
  /// at its highest and stays put.
  int _tivraOf(int shuddha) => shuddha == 5 ? 6 : shuddha;

  /// The shuddha (natural) position of each full swara name.
  static const Map<String, int> _shuddhaByName = {
    'sa': 0,
    'ri': 2,
    're': 2,
    'ga': 4,
    'ma': 5,
    'pa': 7,
    'dha': 9,
    'dh': 9,
    'ni': 11,
  };

  /// The shuddha position of each single-letter short form.
  static const Map<String, int> _shuddhaByLetter = {
    'S': 0,
    'R': 2,
    'G': 4,
    'M': 5,
    'P': 7,
    'D': 9,
    'N': 11,
  };

  /// The Carnatic numbered swaras. Several share a position — R3 and G2 are the
  /// same key, named differently depending on the raga.
  static const Map<String, int> _carnaticPositions = {
    'R1': 1,
    'R2': 2,
    'R3': 3,
    'G1': 2,
    'G2': 3,
    'G3': 4,
    'M1': 5,
    'M2': 6,
    'D1': 8,
    'D2': 9,
    'D3': 10,
    'N1': 9,
    'N2': 10,
    'N3': 11,
  };

  /// True when every token in [line] is a swara — i.e. the line is a swaram
  /// passage rather than lyrics. A line with no swaras at all is false.
  ///
  /// Used by the parser to tag a line so the renderer can lay it out in a
  /// fixed-width grid without knowing any swara syntax itself.
  bool isSwaramLine(String line) {
    final tokens = line
        .split(RegExp('[${RegExp.escape(separators)}]+'))
        .where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return false;
    return tokens.every(isSwaraToken);
  }

  /// Beats (aksharas) in one cycle of [tala], or `null` when unknown.
  ///
  /// Matching ignores case and a trailing "tala"/"talam"/"taal", so
  /// `Adi`, `adi talam` and `ADI TALA` all give 8.
  int? talaBeats(String tala) {
    final name = tala.trim().toLowerCase();
    if (name.isEmpty) return null;

    // The whole name first. This matters for the Hindustani talas whose own
    // names end in "tal" — stripping it would turn Teental into "teen".
    final exact = _talaBeats[name];
    if (exact != null) return exact;

    for (final suffix in _talaSuffixes) {
      if (!name.endsWith(suffix)) continue;
      final stripped = name.substring(0, name.length - suffix.length).trim();
      if (stripped.isEmpty) continue;
      final beats = _talaBeats[stripped];
      if (beats != null) return beats;
    }
    return null;
  }

  /// Words for "tala" that people append to the name — "Adi talam" is Adi.
  /// Longest first, so "taalam" is tried before "tala".
  static const List<String> _talaSuffixes = [
    'taalam',
    'thalam',
    'taala',
    'thala',
    'talam',
    'taal',
    'thal',
    'tala',
    'tal',
  ];

  /// Cycle lengths in beats. Carnatic first, then Hindustani.
  static const Map<String, int> _talaBeats = {
    // Carnatic
    'adi': 8,
    'rupaka': 6,
    'rupakam': 6,
    'misra chapu': 7,
    'mishra chapu': 7,
    'khanda chapu': 5,
    'ata': 14,
    'atta': 14,
    'jhampa': 10,
    'jampa': 10,
    'triputa': 7,
    'matya': 10,
    'dhruva': 14,
    'eka': 4,
    // Hindustani
    'teental': 16,
    'teentaal': 16,
    'tintal': 16,
    'trital': 16,
    'ektal': 12,
    'ektaal': 12,
    'jhaptal': 10,
    'jhaptaal': 10,
    'keherwa': 8,
    'kaharwa': 8,
    'dadra': 6,
    'rupak': 7,
    'deepchandi': 14,
    'tilwada': 16,
    'jhoomra': 14,
    'chautal': 12,
  };

  /// Strips octave dots, apostrophes and variant digits (`R1`, `M₂`) so the
  /// bare swara letter is left.
  String _stripMarks(String token) {
    final buffer = StringBuffer();
    for (final rune in token.trim().runes) {
      final char = String.fromCharCode(rune);
      if (_markCharacters.contains(char)) continue;
      buffer.write(char);
    }
    return buffer.toString();
  }

  /// Octave and variant marks that do not change which swara it is.
  static const Set<String> _markCharacters = {
    '.', "'", '’', '`', '^', '_',
    '1', '2', '3', '4',
    '₀', '₁', '₂', '₃', '₄', // subscript digits
  };
}
