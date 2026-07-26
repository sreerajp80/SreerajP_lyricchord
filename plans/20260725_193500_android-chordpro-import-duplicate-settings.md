# Plan: Android .chordpro Intent & Import Duplicate Settings

**Status:** Approved & Implemented

## Goal
Enable opening `.chordpro` files directly from Android file managers into LyricChord, and implement configurable conflict handling settings when imported song titles already exist.

## Files Changed
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`
- `lib/models/import_settings.dart`
- `lib/providers/import_settings_provider.dart`
- `lib/screens/import_settings_screen.dart`
- `lib/screens/general_settings_screen.dart`
- `lib/core/router/app_router.dart`
- `lib/data/app_database.dart`
- `lib/repositories/song_repository.dart`
- `lib/services/import_service.dart`
- `lib/widgets/rename_imported_song_dialog.dart`
- `lib/widgets/file_intent_listener.dart`
- `lib/screens/import_export_screen.dart`
- `lib/main.dart`
- `test/services/import_service_test.dart`
- `test/screens/import_settings_screen_test.dart`
