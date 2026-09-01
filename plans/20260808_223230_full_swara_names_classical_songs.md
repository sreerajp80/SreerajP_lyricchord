# Plan: Use Full Swara Names in Classical Seed Songs (Database Schema v6)

**Status:** completed

## Task Summary
Update all classical seed songs to use full Swara note names (`Sa`, `Ri`/`Re`, `Ga`, `Ma`, `Pa`, `Dha`, `Ni`) instead of single-letter abbreviations (`S`, `R`, `G`, `M`, `P`, `D`, `N`).

## Target Files
1. `lib/data/app_database.dart` — Update `_seedClassicSongs()`, `_seedMissingClassicSongs()`, and add migration helper `_updateSwaraNotationWithFullNames()`. Increment `schemaVersion` to `6`.
2. `test/helpers/fake_song_repository.dart` — Update `FakeSongRepository.seeded()` test fixtures with full Swara names.
3. `test/repositories/song_repository_test.dart` — Add unit test for schema v6 database migration.

## Proposed Swara Text Formatting
1. **Vathapi Ganapathim (Raga Hamsadhvani)**:
   `Swaram:`
   `Sa - Ri - Ga - Pa - Ni - Sa - | Sa - Ni - Pa - Ga - Ri - Sa -`

2. **Raghupati Raghava Raja Ram (Raga Mishra Gara)**:
   `Swaram (Sa = D):`
   `Sa - Sa - Pa - Pa - | Ma - Ma - Sa - Sa -`
   `Sa - Sa - Pa - Pa - | Ni - Ni - Sa - Sa -`

3. **Krishna Nee Begane Baro (Raga Yamunakalyani)**:
   `Swaram:`
   `Sa - Ri - Ga - Ma - Pa - Dha - Ni - Sa - | Sa - Ni - Dha - Pa - Ma - Ga - Ri - Sa -`

## Verification Plan
- Run `flutter analyze` to ensure zero errors/warnings.
- Run `flutter test` to ensure all 350+ unit and widget tests pass cleanly.
