import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'package:lyricchord/core/config/app_flavor_config.dart';

/// The app's one logger (engineering standard §14). Use it instead of `print`
/// or `debugPrint`.
///
/// - **dev flavor:** every level, with error detail and stack traces.
/// - **prod flavor:** `info` and above. `trace` and `debug` print nothing.
/// - **prod release builds:** an error is logged by its type only — never its
///   message or stack trace — because a message can carry song text or a file
///   name, and song content must never reach the release log
///   (`docs/security.md`).
///
/// Logs go to the console only (logcat on Android). Nothing is written to disk.
///
/// Never pass song content (titles, lyrics, notes) in a message.
class AppLogger {
  AppLogger._();

  static Logger _logger = _create(AppFlavorConfig.instance, ConsoleOutput());
  static bool _redact = AppFlavorConfig.instance.isProd && kReleaseMode;

  /// Sets the logger up for this build. Called first thing in `main()`
  /// (engineering standard §4.5, step 2). Until then, logs still go to the
  /// console with the same rules, so a log call never fails.
  ///
  /// The parameters exist for tests.
  static void init({
    AppFlavorConfig? flavor,
    LogOutput? output,
    bool? releaseMode,
  }) {
    final config = flavor ?? AppFlavorConfig.instance;
    _redact = config.isProd && (releaseMode ?? kReleaseMode);
    _logger = _create(config, output ?? ConsoleOutput());
  }

  static Logger _create(AppFlavorConfig config, LogOutput output) => Logger(
    // The default filter drops everything outside debug mode; this one keeps
    // the level below in every build mode.
    filter: ProductionFilter(),
    level: config.enableVerboseLogging ? Level.trace : Level.info,
    printer: config.isDev
        ? PrettyPrinter(methodCount: 0, colors: false, printEmojis: false)
        : SimplePrinter(colors: false),
    output: output,
  );

  /// Very detailed, dev-only.
  static void trace(String message) => _logger.t(message);

  /// Useful development context, dev-only.
  static void debug(String message) => _logger.d(message);

  /// A normal, significant event (app start, a finished user action).
  static void info(String message) => _logger.i(message);

  /// Something unexpected that the app recovered from.
  static void warning(String message, {Object? error}) =>
      _log(Level.warning, message, error, null);

  /// An operation failed. Pass the [error] and [stackTrace] when you have them.
  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(Level.error, message, error, stackTrace);

  /// The app cannot carry on safely.
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(Level.fatal, message, error, stackTrace);

  static void _log(
    Level level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (_redact) {
      final kind = error == null ? '' : ' (${error.runtimeType})';
      _logger.log(level, '$message$kind');
      return;
    }
    _logger.log(level, message, error: error, stackTrace: stackTrace);
  }
}
