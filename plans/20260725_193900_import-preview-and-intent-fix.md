# Plan: Import Preview & Intent Stream Resolution

**Status:** Approved & Implemented

## Problem
1. When double-tapping or opening a `.chordpro` file from an external Android app/file manager, the app was auto-importing all songs into the database without letting the user preview or selectively import.
2. Opening `file://` URIs on Android 10+ caused `EACCES (Permission denied)` when calling `contentResolver.openInputStream(uri)`.
3. Flutter's default deep linking engine attempted to interpret `content://` URIs as internal app route locations, displaying a "Page Not Found" screen.

## Fix Strategy
1. Create `ImportPreviewArgs` and `ImportPreviewScreen` showing detected songs, duplicate status badges (`In Songbook`), lyrics/chord previews, and selective checkboxes.
2. Update `FileIntentListener` and `ImportExportScreen` to push `/import-preview`.
3. Disable `flutter_deeplink_enabled` in `AndroidManifest.xml` and redirect `content:` / `file:` schemes to `/` in `GoRouter`.
4. Update `MainActivity.kt` to inspect URI schemes (`file:` vs `content:`) and safely open file streams with `java.io.File(path).inputStream()`.

## Files Modified
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/in/sreerajp/lyricchord/MainActivity.kt`
- `lib/core/router/app_router.dart`
- `lib/models/import_preview_args.dart`
- `lib/screens/import_preview_screen.dart`
- `lib/widgets/file_intent_listener.dart`
- `lib/screens/import_export_screen.dart`
- `test/screens/import_preview_screen_test.dart`
