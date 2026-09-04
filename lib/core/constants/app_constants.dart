/// Technical constants for the app (values only, no logic).
///
/// About-screen text does NOT belong here — that lives in
/// `assets/config/app_config.json` (see the About config pattern).
class AppConstants {
  AppConstants._();

  /// drift (SQLite) database file name.
  static const String databaseName = 'lyricchord.db';

  /// shared_preferences key for the saved theme mode.
  static const String prefThemeMode = 'theme_mode';

  /// shared_preferences key for the user's saved custom chord notations.
  static const String prefCustomChords = 'custom_chords';

  /// shared_preferences key for the chosen lyric font (a [LyricFont] id).
  static const String prefLyricFont = 'lyric_font';

  /// shared_preferences key for whether the metronome is enabled (`true`/`false`).
  static const String prefMetronomeEnabled = 'metronome_enabled';

  /// shared_preferences key for whether the metronome flashes on each beat.
  static const String prefMetronomeFlash = 'metronome_flash';

  /// shared_preferences key for whether the metronome clicks on each beat.
  static const String prefMetronomeClick = 'metronome_click';

  /// shared_preferences key for the metronome click loudness (0.0–1.0). Kept
  /// separate from [prefPitchDroneVolume] so the drone and the beat do not
  /// fight over one slider.
  static const String prefMetronomeVolume = 'metronome_volume';

  /// shared_preferences key for how many beats make one bar (the time
  /// signature's top number).
  static const String prefMetronomeBeatsPerBar = 'metronome_beats_per_bar';

  /// shared_preferences key for whether beat 1 of each bar is accented.
  static const String prefMetronomeAccent = 'metronome_accent';

  /// shared_preferences key for the last tempo used by the metronome, so a song
  /// with no saved tempo still starts at something sensible.
  static const String prefMetronomeLastBpm = 'metronome_last_bpm';

  /// shared_preferences key for whether the one-time Stage Mode gesture guide
  /// has already been shown.
  static const String prefStageHelpSeen = 'stage_help_seen';

  /// shared_preferences key for import duplicate strategy.
  static const String prefImportDuplicateStrategy = 'import_duplicate_strategy';

  /// shared_preferences key for the manual auto-scroll speed a song starts at
  /// when it has none of its own.
  static const String prefDefaultScrollSpeed = 'default_scroll_speed';

  /// shared_preferences keys for pitch pipe, shruti drone, western chord drone, and stage font scale.
  static const String prefPitchDroneKey = 'pitch_drone_key';
  static const String prefPitchDroneInterval = 'pitch_drone_interval';
  static const String prefPitchDroneVolume = 'pitch_drone_volume';
  static const String prefFontScaleIndex = 'stage_font_scale_index';
  static const String prefDroneMode = 'pitch_drone_mode';
  static const String prefChordQuality = 'pitch_drone_chord_quality';

  /// shared_preferences key for where the singer's **Sa** sits, held as a pitch
  /// name (`G` = 5 kattai = safed 5).
  ///
  /// Kept apart from [prefPitchDroneKey] because the two answer different
  /// questions. Sa belongs to the singer's voice and hardly ever changes; the
  /// drone key follows whichever Western song is open. Sharing one value would
  /// make every song overwrite the singer's own pitch.
  static const String prefSaKey = 'pitch_sa_key';

  /// shared_preferences key for how pitches are named — `western`, `carnatic`
  /// or `hindustani`. Used when a song's own tradition cannot be worked out.
  static const String prefPitchNaming = 'pitch_naming';

  /// Width (in logical pixels) at and above which the tablet dual-pane
  /// layout is used; below this a single-pane phone layout is used.
  static const double tabletBreakpoint = 600.0;
}
