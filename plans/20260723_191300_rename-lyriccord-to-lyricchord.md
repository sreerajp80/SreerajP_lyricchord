# Plan: Rename App Identifier & References from LyricCord to LyricChord

**Status:** Implemented

## Issue
The app name was updated from `lyriccord` / `LyricCord` to `lyricchord` / `LyricChord`. Several source files, config files, iOS configurations, and documentation files still contained the old name.

## Proposed Changes
1. Update `lib/core/config/app_config.dart` fallback `appName` to `'LyricChord'`.
2. Update doc comments in `lib/core/errors/app_exception.dart` and `lib/models/song_note.dart`.
3. Update `ios/Runner/Info.plist` display name and bundle name.
4. Update tooling (`tool/generate_icon.py`), `README.md`, `CLAUDE.md`, and documentation under `docs/`.
