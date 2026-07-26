# Change Log: Import Preview & Intent Stream Resolution

**Date:** 2026-07-25
**Plan:** [plans/20260725_193900_import-preview-and-intent-fix.md](../plans/20260725_193900_import-preview-and-intent-fix.md)

## Changes Implemented

1. **Import Preview Screen**:
   - Added `ImportPreviewArgs` model to carry file data and parsed songs.
   - Built `ImportPreviewScreen` featuring file summary, duplicate title detection (`In Songbook` badge), song preview bottom sheet, selective checkboxes, "Select All" / "Deselect All" options, and an "Import Selected" action button.

2. **File Intent & Picker Integration**:
   - Updated `FileIntentListener` and `ImportExportScreen` to launch `/import-preview` instead of auto-persisting to the database.

3. **Android Native & Intent Handling**:
   - Added `<meta-data android:name="flutter_deeplink_enabled" android:value="false" />` to `AndroidManifest.xml`.
   - Added `pathSuffix` intent filters for `.chordpro`, `.cho`, `.pro`, `.chopro`, and `.txt`.
   - Updated `MainActivity.kt` to handle `file://` streams via `java.io.File(path).inputStream()` to prevent `EACCES (Permission denied)` on Android 10+ devices.

4. **Testing**:
   - Added `test/screens/import_preview_screen_test.dart`.
   - Verified that all 278 unit and widget tests pass.
