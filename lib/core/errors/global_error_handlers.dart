import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:lyricchord/core/logging/app_logger.dart';
import 'package:lyricchord/widgets/safe_error_fallback.dart';

/// Installs the app-wide error handlers (engineering standard §11.1). Call it in
/// `main()` right after `AppLogger.init()` and before anything else can fail.
///
/// - Framework errors (build, layout, paint) are logged. Debug builds still dump
///   them to the console and show Flutter's red error box.
/// - Uncaught async errors (futures, timers, platform channels) are logged and
///   kept from crashing the app.
/// - Release builds show [SafeErrorFallback] instead of the grey error box.
///
/// [releaseMode] exists for tests.
void installGlobalErrorHandlers({bool releaseMode = kReleaseMode}) {
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!releaseMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };

  if (releaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const SafeErrorFallback();
  }
}
