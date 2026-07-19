import 'package:drift/native.dart';
import 'package:lyriccord/data/app_database.dart';

/// Builds a fresh in-memory [AppDatabase] for tests. Each call is a brand-new
/// database, so `onCreate` (and first-run seeding) runs every time.
AppDatabase newInMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
