/// The saved metronome preferences.
///
/// Immutable view of what the user turned on for the metronome: the master
/// switch, whether each beat flashes and/or clicks, how loud the click is, how
/// many beats make one bar, and whether beat 1 is accented. Stored in
/// `shared_preferences`, so it survives a restart. Use [copyWith] to make a
/// changed copy instead of mutating in place.
class MetronomeSettings {
  /// Master switch. When off, the metronome does not appear on the performance
  /// screen at all.
  final bool enabled;

  /// Show a visual flash on each beat.
  final bool flash;

  /// Play a click sound on each beat.
  final bool click;

  /// Click loudness, 0.0 (silent) to 1.0 (loudest).
  final double volume;

  /// How many beats make one bar — the top number of the time signature. Beat 1
  /// of every bar is the accented one. Must be one of [beatsPerBarChoices].
  final int beatsPerBar;

  /// Make beat 1 of each bar louder and higher, so you can hear where the bar
  /// starts. Turn off for a flat, every-beat-the-same tick.
  final bool accent;

  /// The time signatures offered in settings: 2/4, 3/4, 4/4 and 6/8.
  static const List<int> beatsPerBarChoices = [2, 3, 4, 6];

  /// Quietest and loudest allowed [volume].
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;

  /// Default: the metronome is off, but everything else is pre-armed so it
  /// works the moment it is enabled.
  const MetronomeSettings({
    this.enabled = false,
    this.flash = true,
    this.click = true,
    this.volume = 0.8,
    this.beatsPerBar = 4,
    this.accent = true,
  });

  MetronomeSettings copyWith({
    bool? enabled,
    bool? flash,
    bool? click,
    double? volume,
    int? beatsPerBar,
    bool? accent,
  }) {
    return MetronomeSettings(
      enabled: enabled ?? this.enabled,
      flash: flash ?? this.flash,
      click: click ?? this.click,
      volume: volume ?? this.volume,
      beatsPerBar: beatsPerBar ?? this.beatsPerBar,
      accent: accent ?? this.accent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MetronomeSettings &&
      other.enabled == enabled &&
      other.flash == flash &&
      other.click == click &&
      other.volume == volume &&
      other.beatsPerBar == beatsPerBar &&
      other.accent == accent;

  @override
  int get hashCode =>
      Object.hash(enabled, flash, click, volume, beatsPerBar, accent);

  @override
  String toString() =>
      'MetronomeSettings(enabled: $enabled, flash: $flash, click: $click, '
      'volume: $volume, beatsPerBar: $beatsPerBar, accent: $accent)';
}
