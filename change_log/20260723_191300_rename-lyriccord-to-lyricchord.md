# Change Log: Rename App Identifier & References from LyricCord to LyricChord

**Date:** 2026-07-23  
**Plan:** `plans/20260723_191300_rename-lyriccord-to-lyricchord.md`

## Summary
Renamed all remaining occurrences of `lyriccord` / `LyricCord` to `lyricchord` / `LyricChord` across the codebase, iOS settings, tooling, and documentation.

## Changes Made
- **`lib/core/config/app_config.dart`**: Updated `AppConfig.fallback` `appName` from `'LyricCord'` to `'LyricChord'`.
- **`lib/core/errors/app_exception.dart` & `lib/models/song_note.dart`**: Updated doc comments.
- **`ios/Runner/Info.plist`**: Updated `CFBundleDisplayName` to `LyricChord` and `CFBundleName` to `lyricchord`.
- **`tool/generate_icon.py`**: Updated script docstring.
- **`README.md` & `CLAUDE.md`**: Updated project title, package ID (`in.sreerajp.lyricchord`), and dev flavor notes.
- **`docs/`**: Updated `security.md`, `release_process.md`, `architecture.md`, and `implementation_plan.md`.

## Verification
- `flutter analyze` passed with 0 issues.
- `flutter test` passed all test suites.
- Android APK compiled cleanly (`flutter build apk --flavor dev`).
