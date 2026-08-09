# Change Log: Migrate Database to Schema v4 for Classical Songs

**Date:** 2026-08-08
**Plan Ref:** `plans/20260808_221830_migrate_database_schema_v4_seed_classical_songs.md`

## Summary
Migrated database schema version to 4 (`onUpgrade` from 3 to 4) so existing app installations automatically seed missing classical Indian songs (`Vathapi Ganapathim`, `Raghupati Raghava Raja Ram`, `Krishna Nee Begane Baro`) on app start.

## Changes Made
1. **`lib/data/app_database.dart`**:
   - Incremented `schemaVersion` from `3` to `4`.
   - Added `if (from < 4)` block to `onUpgrade` calling `_seedMissingClassicSongs()`.
   - Implemented `_seedMissingClassicSongs()` helper to check existing song titles and insert missing classical seed songs without duplicating existing data.

2. **`test/repositories/song_repository_test.dart`**:
   - Added unit test verifying `schema v4 migration populates missing classical songs`.

## Verification
- Executed `flutter analyze`: 0 issues found.
- Executed `flutter test`: All 351 tests passed.
