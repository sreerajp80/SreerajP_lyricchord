/// One sung note inside a melody line.
///
/// A note knows only *what pitch* and *how it is entered* — never how long it
/// lasts. Length comes from the beat that holds it (see `MelodyBeat`), because
/// the same note written in a beat of its own and in a shared beat is the same
/// note sung for different lengths.
///
/// Pitch is stored as semitones above Sa, not as a frequency. Sa itself is a
/// song setting, so a melody stays correct when the singer changes their pitch.
library;

/// A single note: its pitch, its octave, and any gamaka marks on it.
class MelodyNote {
  /// Semitones above Sa within the octave, `0`–`11`.
  ///
  /// This is what `SwaraNotation.swaraPosition` returns, so `M1` is 5 and `M2`
  /// is 6.
  final int position;

  /// `-1` for the lower octave, `0` for the middle, `1` for the upper.
  ///
  /// Written as a leading dot (`.N3`) or a trailing mark (`S'`, `S^`).
  final int octave;

  /// True when the singer slides into this note rather than landing on it.
  ///
  /// Written with `!` — either `M2!G3` (slide starts at Ma) or `!G3` (a short
  /// slide in from just under Ga).
  final bool slide;

  /// Where the slide starts, or `null` for a bare `!`.
  ///
  /// Only meaningful when [slide] is true. Kept as a note so the starting pitch
  /// carries its own octave — a slide down from `S'` is not the same as a slide
  /// up from `S`.
  final MelodyNote? slideFrom;

  /// True when the note is shaken — the gamaka oscillation written `~`.
  final bool shake;

  /// The token exactly as the writer typed it, for drawing in the grid.
  ///
  /// Kept so the screen shows what the person wrote (`Ma2`) rather than a
  /// re-spelling of it (`M2`).
  final String text;

  const MelodyNote({
    required this.position,
    required this.text,
    this.octave = 0,
    this.slide = false,
    this.slideFrom,
    this.shake = false,
  });

  /// Semitones above the song's Sa, counting octaves.
  ///
  /// `.N3` is `-1`, middle `S` is `0`, `S'` is `12`. This is the number the
  /// player turns into a frequency.
  int get semitonesFromSa => position + octave * 12;

  MelodyNote copyWith({
    int? position,
    int? octave,
    bool? slide,
    MelodyNote? slideFrom,
    bool? shake,
    String? text,
  }) => MelodyNote(
    position: position ?? this.position,
    octave: octave ?? this.octave,
    slide: slide ?? this.slide,
    slideFrom: slideFrom ?? this.slideFrom,
    shake: shake ?? this.shake,
    text: text ?? this.text,
  );

  @override
  bool operator ==(Object other) =>
      other is MelodyNote &&
      other.position == position &&
      other.octave == octave &&
      other.slide == slide &&
      other.slideFrom == slideFrom &&
      other.shake == shake &&
      other.text == text;

  @override
  int get hashCode =>
      Object.hash(position, octave, slide, slideFrom, shake, text);

  @override
  String toString() =>
      'MelodyNote($text, position: $position, octave: $octave, '
      'slide: $slide, shake: $shake)';
}
