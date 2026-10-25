import 'package:flutter/widgets.dart';

import 'package:lyricchord/core/logging/app_logger.dart';

/// App-wide lifecycle handling (engineering standard §9). Screens that need
/// their own lifecycle behaviour (the performance view's wake lock and scroll
/// speed, the AirQR camera) keep their own observers.
///
/// - **detached** (the app is shutting down): runs [onDetached] — `main()` passes
///   the database's write-ahead-log checkpoint. The database is not closed:
///   on Android a detached engine can be shown again, and a closed database
///   could not be reopened.
/// - **memory pressure**: clears the image cache.
class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService({required this.onDetached, this._imageCache});

  /// Work to finish before the app shuts down.
  final Future<void> Function() onDetached;

  final ImageCache? _imageCache;

  /// Starts listening. Call once, from `main()`.
  void init() => WidgetsBinding.instance.addObserver(this);

  /// Stops listening.
  void dispose() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      onDetached().catchError((Object error, StackTrace stack) {
        AppLogger.error(
          'Shutdown database checkpoint failed',
          error: error,
          stackTrace: stack,
        );
      });
    }
  }

  @override
  void didHaveMemoryPressure() {
    final cache = _imageCache ?? PaintingBinding.instance.imageCache;
    cache
      ..clear()
      ..clearLiveImages();
    AppLogger.info('Memory pressure: image cache cleared');
  }
}
