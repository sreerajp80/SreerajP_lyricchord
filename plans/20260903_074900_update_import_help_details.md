# Update Import Help Topic with Multi-Song and Format Details

**Status:** completed

## Issue

The current "Import" topic under Settings → Help is very brief. It mentions that files can hold one or many songs, but does not clarify:
1. Whether files can be plain text files (`.txt`) or ChordPro files (`.cho`, `.pro`, `.chordpro`).
2. How the app identifies and separates multiple songs inside a single file (using `{new_song}`/`{ns}` or another `{title}` directive).
3. What happens if an imported text file contains no tags at all.

## Files to change

- `lib/screens/help/help_content.dart` — update the `HelpTopic` for `import` with clear, plain-English points.

## The plan for the fix

Update the `import` topic in `lib/screens/help/help_content.dart`:
- **Heading: Supported file types**
  - Clarify that both text files (`.txt`) and ChordPro files (`.cho`, `.pro`, `.chordpro`) can be imported.
  - Note that ChordPro files are plain text files with chord tags like `[C]` and directives like `{title: ...}`.
- **Heading: Multiple songs in one file**
  - Method 1: Place `{new_song}` (or `{ns}`) on its own line between songs. (This is also what the app outputs when exporting all songs).
  - Method 2: Start a new song by simply adding another `{title: Song Name}` (or `{t: ...}`) tag.
- **Heading: Plain text files without tags**
  - Files without directives or tags are safely loaded as a single song ("Untitled Song" in key C).
  - You can immediately edit the title, key, chords, and tempo in the song editor.
- Keep existing information on duplicate handling and picking multiple files.

## After the change

- Run `flutter analyze` and `flutter test`.
- Format code with `dart format .`.
- Write change log entry to `change_log/20260903_074900_update_import_help_details.md`.
