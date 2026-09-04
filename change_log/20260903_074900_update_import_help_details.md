# Change log — Update Import Help Topic with Multi-Song and Format Details

Implements plan: `plans/20260903_074900_update_import_help_details.md`

## What changed

- `lib/screens/help/help_content.dart` — updated the `HelpTopic` for `import` with clear, expanded sections:
  1. **Supported file types** — explains that users can pick `.cho`, `.pro`, `.chordpro`, or `.txt` files; notes that ChordPro files are plain text files with chord/header tags; confirms multiple files can be picked at once.
  2. **Multiple songs in one file** — explains that a single file can hold many songs; details separating them with `{new_song}` / `{ns}` on its own line (matching exported songbook files) or by starting a new `{title: ...}` / `{t: ...}` tag.
  3. **Text files without tags** — explains that plain text files without directives or tags are imported safely as a single song ("Untitled Song" in key C) ready for editing.
  4. **Duplicate songs** — notes how duplicate titles follow the user's duplicate setting (overwrite, rename new, rename old, or ask).

## Verification

- `dart format lib/screens/help/help_content.dart` — 0 changes needed.
- `flutter analyze` — clean (No issues found).
- `flutter test test/screens/settings_screen_test.dart test/services/chord_pro_service_test.dart` — all 41 tests passed.
