# Change Log: Add Hyphens to Swara Notation (Schema v5)

**Date:** 2026-08-08
**Plan Ref:** `plans/20260808_222700_add_hyphens_to_swara_notation.md`

## Summary
Added hyphens (`-`) between swaras across classical songs to follow standard Indian classical notation (e.g. `S - R - G - P - N - S - | S - N - P - G - R - S -`) and migrated database schema to version 5.

## Changes Made
1. **`lib/data/app_database.dart`**:
   - Incremented `schemaVersion` to `5`.
   - Updated `_seedClassicSongs()` and `_seedMissingClassicSongs()` swara lines to format with hyphens.
   - Added `_updateSwaraNotationWithHyphens()` and invoked it in `onUpgrade` (`from < 5`).

2. **`test/repositories/song_repository_test.dart`**:
   - Added unit test for schema v5 database migration.

## Verification
- Executed `flutter analyze`: 0 issues found.
- Executed `flutter test`: All 352 tests passed.
