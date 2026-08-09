# Change Log: Add Classical Songs with Swara and Raga

**Date:** 2026-08-08
**Plan Ref:** `plans/20260808_220412_add_classical_swara_raga_songs.md`

## Summary
Added classical Indian songs containing Raga metadata tags and Swara notation to the LyricChord seed database and unit/widget test repositories.

## Changes Made
1. **`lib/data/app_database.dart`**:
   - Added 3 classical songs to `_seedClassicSongs()`:
     - `Vathapi Ganapathim (Raga Hamsadhvani)` by Muthuswami Dikshitar (Key C, BPM 72, Starred)
     - `Raghupati Raghava Raja Ram (Raga Mishra Gara)` by Traditional Bhajan (Key D, BPM 84)
     - `Krishna Nee Begane Baro (Raga Yamunakalyani)` by Vyasatirtha (Key E, BPM 68)
   - Included `{raga: ...}` annotations and bracketed Swara/Chord lines in lyrics.

2. **`test/helpers/fake_song_repository.dart`**:
   - Updated `FakeSongRepository.seeded()` to include the classical songs for unit and widget test consistency.

3. **`test/repositories/song_repository_test.dart`**:
   - Updated database seeding test expectations for 6 total seed songs.

4. **`test/providers/song_list_provider_test.dart`**, **`test/providers/song_editor_provider_test.dart`**, **`test/screens/song_list_screen_test.dart`**, **`test/screens/song_editor_screen_test.dart`**, **`test/widget_test.dart`**:
   - Updated test expectations to align with the expanded 6 seed songs dataset.

## Verification
- Executed `flutter analyze`: Passed with 0 errors/warnings.
- Executed `flutter test`: All 350 tests passed.
