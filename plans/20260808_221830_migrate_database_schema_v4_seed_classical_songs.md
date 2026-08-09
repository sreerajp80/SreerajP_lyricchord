# Plan: Migrate Database to Schema v4 for Existing Installs

**Status:** Proposed

## Issue
On existing app installations (like the running dev app on the test device), SQLite's `onCreate` callback does not re-run because the database file already exists. As a result, newly added seed songs only appear on clean database creations unless a schema migration is executed.

## Fix Strategy
1. Bump `schemaVersion` from `3` to `4` in `lib/data/app_database.dart`.
2. Add a migration step in `onUpgrade` (`from < 4`) that runs `_seedMissingClassicSongs()`.
3. `_seedMissingClassicSongs()` checks for the classical songs (`Vathapi Ganapathim`, `Raghupati Raghava Raja Ram`, `Krishna Nee Begane Baro`) and inserts any that are not present in the existing database.

## Target Files
1. `lib/data/app_database.dart` — Bump `schemaVersion` to 4, add `from < 4` migration step to `onUpgrade`, and implement `_seedMissingClassicSongs()`.
2. `test/repositories/song_repository_test.dart` — Add a test for database schema v4 upgrade migration.

## Verification Plan
- Run `flutter analyze` to ensure zero static analysis warnings or errors.
- Run `flutter test` to ensure all unit and integration tests pass.
