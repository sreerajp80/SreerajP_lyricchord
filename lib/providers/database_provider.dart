import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lyriccord/data/app_database.dart';
import 'package:lyriccord/repositories/song_repository.dart';

/// The opened [AppDatabase]. This default throws — `main()` overrides it with
/// the real database, and tests override it with an in-memory one.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with an opened AppDatabase.',
  );
});

/// The song data access layer, built on top of [appDatabaseProvider].
final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepository(ref.watch(appDatabaseProvider));
});
