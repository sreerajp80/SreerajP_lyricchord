import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lyricchord/core/constants/app_constants.dart';
import 'package:lyricchord/core/errors/app_exception.dart';
import 'package:lyricchord/core/logging/app_logger.dart';

/// Deletes all of the app's own data on this device (engineering standard
/// §15.4): the song database, every saved setting, and the temporary audio and
/// export files. The app then starts as it did on first install.
///
/// The caller must have stopped using the database: [closeDatabase] is called
/// first, and the database cannot be used again afterwards. `main()` reopens a
/// fresh one by restarting the app.
///
/// Every step runs even if an earlier one fails, so as much as possible is
/// removed. If any step failed, a [StorageException] is thrown at the end.
class DataPurgeService {
  DataPurgeService({
    required this._closeDatabase,
    required this._preferences,
    Future<Directory> Function()? documentsDirectory,
    Future<Directory> Function()? temporaryDirectory,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<void> Function() _closeDatabase;
  final SharedPreferences _preferences;
  final Future<Directory> Function() _documentsDirectory;
  final Future<Directory> Function() _temporaryDirectory;

  /// SQLite keeps these files next to the database while it is open.
  static const _databaseSuffixes = ['', '-wal', '-shm', '-journal'];

  Future<void> deleteAllData() async {
    Object? firstError;

    Future<void> step(String name, Future<void> Function() run) async {
      try {
        await run();
      } catch (error, stack) {
        AppLogger.error(
          'Delete all data: $name failed',
          error: error,
          stackTrace: stack,
        );
        firstError ??= error;
      }
    }

    await step('close database', _closeDatabase);
    await step('delete database', () async {
      final dir = await _documentsDirectory();
      for (final suffix in _databaseSuffixes) {
        final file = File(p.join(dir.path, AppConstants.databaseName + suffix));
        if (await file.exists()) await file.delete();
      }
    });
    await step('clear settings', () async {
      final cleared = await _preferences.clear();
      if (!cleared) throw StateError('SharedPreferences.clear returned false');
    });
    await step('delete temporary files', () async {
      final dir = await _temporaryDirectory();
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        await entity.delete(recursive: true);
      }
    });

    if (firstError != null) {
      throw StorageException(
        'Could not delete all data',
        kind: StorageFailure.deleteAllData,
        cause: firstError,
      );
    }
    AppLogger.info('Delete all data: done');
  }
}
