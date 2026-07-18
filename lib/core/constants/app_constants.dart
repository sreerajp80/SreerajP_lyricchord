/// Technical constants for the app (values only, no logic).
///
/// About-screen text does NOT belong here — that lives in
/// `assets/config/app_config.json` (see the About config pattern).
class AppConstants {
  AppConstants._();

  /// drift (SQLite) database file name.
  static const String databaseName = 'lyriccord.db';

  /// shared_preferences key for the saved theme mode.
  static const String prefThemeMode = 'theme_mode';

  /// Width (in logical pixels) at and above which the tablet dual-pane
  /// layout is used; below this a single-pane phone layout is used.
  static const double tabletBreakpoint = 600.0;
}
