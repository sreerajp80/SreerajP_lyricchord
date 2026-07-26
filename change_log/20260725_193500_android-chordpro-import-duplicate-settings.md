# Change Log: Android .chordpro Intent & Import Duplicate Settings

**Plan:** `plans/20260725_193500_android-chordpro-import-duplicate-settings.md`

## Summary of Changes

1. **Android File Intent Handling**:
   - Added intent-filters in `AndroidManifest.xml` for file and content schemes for `.chordpro` extension.
   - Added MethodChannel `in.sreerajp.lyricchord/file_intent` in `MainActivity.kt` to extract URI stream contents.
   - Integrated `FileIntentListener` into `main.dart`.

2. **Import Duplicate Handling Settings**:
   - Created `ImportDuplicateStrategy` enum (`overwrite`, `renameImported`, `renameExisting`, `userSuggested`).
   - Created `ImportSettingsNotifier` backed by `SharedPreferences`.
   - Created `ImportSettingsScreen` UI under Settings → General → Import Settings.
   - Implemented `ImportService` and `RenameImportedSongDialog`.
   - Added `findByTitle` with `limit(1)` in `AppDatabase` and `SongRepository`.

3. **Testing**:
   - Added unit tests in `test/services/import_service_test.dart` and `test/screens/import_settings_screen_test.dart`.
   - All 275 tests passed cleanly.
