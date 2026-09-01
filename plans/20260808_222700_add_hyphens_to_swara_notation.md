# Plan: Add Hyphens to Swara Notation in Classical Songs

**Status:** completed

## Issue
In Indian classical music (Carnatic and Hindustani), Swara notation uses hyphens (`-`) between swaras (e.g. `S - R - G - P - N - S -`) to denote beat timing and note separation. Currently, the swara lines in the seed songs lack hyphens.

## Proposed Changes
1. **Update Swara Notation Text in `lib/data/app_database.dart`**:
   - Update `_seedClassicSongs()` and `_seedMissingClassicSongs()` with hyphenated swara notation:
     - **Vathapi Ganapathim**: `[C]S - R - G - [F]P - N - [C]S - | [G]S - N - P - [C]G - R - S -`
     - **Raghupati Raghava Raja Ram**: `[D]S - S - P - P - | [G]M - M - [D]S - S -` / `[D]S - S - P - P - | [A7]N - N - [D]S - S -`
     - **Krishna Nee Begane Baro**: `[E]S - R - G - M - [A]P - D - N - S - | [B7]S - N - D - P - [E]M - G - R - S -`
2. **Database Migration to Schema v5**:
   - Bump `schemaVersion` from `4` to `5`.
   - In `onUpgrade` (`from < 5`), run an update query to refresh the lyrics of these 3 classical songs with hyphenated Swara notation on existing installations.
3. **Test Fixtures**:
   - Update `FakeSongRepository.seeded()` in `test/helpers/fake_song_repository.dart` to match.

## Verification Plan
- Run `flutter analyze` to ensure zero errors/warnings.
- Run `flutter test` to ensure all tests pass.
