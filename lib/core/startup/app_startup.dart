import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/logging/app_logger.dart';
import 'package:lyricchord/core/router/app_router.dart';
import 'package:lyricchord/data/app_database.dart';
import 'package:lyricchord/l10n/app_localizations.dart';
import 'package:lyricchord/providers/data_purge_provider.dart';
import 'package:lyricchord/providers/database_provider.dart';
import 'package:lyricchord/providers/theme_mode_provider.dart';
import 'package:lyricchord/screens/busy_app.dart';
import 'package:lyricchord/screens/startup_error_screen.dart';
import 'package:lyricchord/services/app_lifecycle_service.dart';
import 'package:lyricchord/services/data_purge_service.dart';

/// A message shown once the app has (re)started.
enum StartupNotice { allDataDeleted, deleteAllDataFailed }

/// Start-up steps 5–8 (engineering standard §4.5; `docs/architecture.md` §5),
/// kept out of `main.dart` so it stays thin. Also restarts the app fresh after
/// "Delete all data".
class AppStartup {
  AppStartup._();

  static AppLifecycleService? _lifecycle;

  /// Opens the data and runs [app]. On failure shows [StartupErrorApp], whose
  /// "Try again" calls this again. [notice] is shown after the first frame.
  static Future<void> start({
    required Widget app,
    StartupNotice? notice,
  }) async {
    try {
      // 5. The database. It opens on first use and seeds the classic songs
      //    on first run.
      final database = AppDatabase();

      // 6. Saved settings, read before the first frame so the app opens with
      //    the right theme. (The About config loads when About opens.)
      final prefs = await SharedPreferences.getInstance();

      // 7. App-wide lifecycle handling (one observer, even after a restart).
      _lifecycle?.dispose();
      _lifecycle = AppLifecycleService(onDetached: database.checkpointWal)
        ..init();

      final purge = DataPurgeService(
        closeDatabase: database.close,
        preferences: prefs,
      );

      // 8. Run.
      runApp(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            sharedPreferencesProvider.overrideWithValue(prefs),
            deleteAllDataProvider.overrideWithValue(
              () => _deleteAllDataAndRestart(purge, app),
            ),
          ],
          child: app,
        ),
      );
      if (notice != null) _showAfterFirstFrame(notice);
    } catch (error, stack) {
      AppLogger.fatal('Start-up failed', error: error, stackTrace: stack);
      runApp(
        StartupErrorApp(
          error: error,
          stackTrace: stack,
          onRetry: () => start(app: app),
        ),
      );
    }
  }

  /// Shows a plain busy screen (so nothing reads the database while it is
  /// closed), deletes everything, then starts the app fresh. A partial failure
  /// still restarts the app, with an error message.
  static Future<void> _deleteAllDataAndRestart(
    DataPurgeService purge,
    Widget app,
  ) async {
    runApp(const BusyApp());
    // Let the old screens close before the database does.
    await WidgetsBinding.instance.endOfFrame;
    var notice = StartupNotice.allDataDeleted;
    try {
      await purge.deleteAllData();
    } catch (_) {
      // Already logged step by step by the service.
      notice = StartupNotice.deleteAllDataFailed;
    }
    await start(app: app, notice: notice);
  }

  static void _showAfterFirstFrame(StartupNotice notice) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = rootScaffoldMessengerKey.currentContext;
      final messenger = rootScaffoldMessengerKey.currentState;
      if (context == null || messenger == null) return;
      final l10n = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (notice) {
            StartupNotice.allDataDeleted => l10n.bodyAllDataDeleted,
            StartupNotice.deleteAllDataFailed => l10n.errorStorageDeleteAllData,
          }),
        ),
      );
    });
  }
}
