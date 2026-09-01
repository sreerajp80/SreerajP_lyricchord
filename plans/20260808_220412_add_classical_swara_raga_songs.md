# Plan: Add Classical Songs with Swara and Raga

**Status:** completed

## Task Summary
Add classical Indian songs featuring Raga metadata and Swara notation to the LyricChord seed database and test seed repositories.

## Target Files
1. `lib/data/app_database.dart` — Add classical songs with Swara notation and Raga headers to `_seedClassicSongs()`.
2. `test/helpers/fake_song_repository.dart` — Update test seed repository to include the classical songs for widget test alignment.
3. `test/repositories/song_repository_test.dart` — Update test assertions for database initial seeding test.

## Proposed Classical Songs
1. **Vathapi Ganapathim**
   - Raga: Hamsadhvani | Tala: Adi
   - Key: C | BPM: 72
   - Artist: Muthuswami Dikshitar
   - Lyrics & Swara notation in bracketed ChordPro format.

2. **Raghupati Raghava Raja Ram**
   - Raga: Mishra Gara
   - Key: D | BPM: 84
   - Artist: Traditional Bhajan
   - Lyrics & Swara notation in bracketed ChordPro format.

3. **Krishna Nee Begane Baro**
   - Raga: Yamunakalyani
   - Key: E | BPM: 68
   - Artist: Vyasatirtha
   - Lyrics & Swara notation in bracketed ChordPro format.

## Verification Plan
- Run `flutter analyze` to ensure zero warnings or errors.
- Run `flutter test` to ensure all unit and widget tests pass.
