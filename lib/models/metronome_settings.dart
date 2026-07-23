/// The saved metronome preferences.
///
/// Immutable view of what the user turned on for the metronome: the master
/// switch plus whether each beat flashes and/or clicks. Stored in
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

  /// Default: the metronome is off, but flash and click are pre-armed so it
  /// works the moment it is enabled.
  const MetronomeSettings({
    this.enabled = false,
    this.flash = true,
    this.click = true,
  });

  MetronomeSettings copyWith({bool? enabled, bool? flash, bool? click}) {
    return MetronomeSettings(
      enabled: enabled ?? this.enabled,
      flash: flash ?? this.flash,
      click: click ?? this.click,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MetronomeSettings &&
      other.enabled == enabled &&
      other.flash == flash &&
      other.click == click;

  @override
  int get hashCode => Object.hash(enabled, flash, click);

  @override
  String toString() =>
      'MetronomeSettings(enabled: $enabled, flash: $flash, click: $click)';
}
