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

  /// shared_preferences key for whether the one-time Stage Mode gesture guide
  /// has already been shown.
  static const String prefStageHelpSeen = 'stage_help_seen';

  /// shared_preferences key for import duplicate strategy.
  static const String prefImportDuplicateStrategy = 'import_duplicate_strategy';

  /// shared_preferences keys for pitch pipe, shruti drone, and stage font scale.
  static const String prefPitchDroneKey = 'pitch_drone_key';
  static const String prefPitchDroneInterval = 'pitch_drone_interval';
  static const String prefPitchDroneVolume = 'pitch_drone_volume';
  static const String prefFontScaleIndex = 'stage_font_scale_index';

  /// Width (in logical pixels) at and above which the tablet dual-pane
  /// layout is used; below this a single-pane phone layout is used.
  static const double tabletBreakpoint = 600.0;
}
