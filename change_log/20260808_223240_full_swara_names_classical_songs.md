# Change Log: Full Swara Names for Classical Songs (Schema v6)

**Date:** 2026-08-08
**Plan Ref:** `plans/20260808_223230_full_swara_names_classical_songs.md`

## Summary
Updated classical seed songs to use full Swara note names (`Sa`, `Ri`/`Re`, `Ga`, `Ma`, `Pa`, `Dha`, `Ni`) instead of single letter abbreviations (`S`, `R`, `G`, `M`, `P`, `D`, `N`), and migrated database schema to version 6.

## Changes Made
1. **`lib/data/app_database.dart`**:
   - Incremented `schemaVersion` to `6`.
   - Updated `_seedClassicSongs()`, `_seedMissingClassicSongs()`, and `_updateSwaraNotationWithFullNames()`.
   - Added `if (from < 6)` migration in `onUpgrade`.

2. **`test/repositories/song_repository_test.dart`**:
   - Added unit test for schema v6 database migration.

## Verification
- Executed `flutter analyze`: 0 issues found.
- Executed `flutter test`: All 353 tests passed.
