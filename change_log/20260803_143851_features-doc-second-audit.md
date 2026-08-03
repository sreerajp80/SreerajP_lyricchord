# Change log: second audit fixes for docs/features.md

Implements: `plans/20260803_143103_features-doc-second-audit.md`

## What changed

**`docs/features.md`**

§2.2 Lyrics & Chords Editor:
- Split the old "Form Validation & Unsaved Guard" bullet into a plain "Form
  Validation" bullet.
- Added "Undo / Redo" — the editor app bar has dedicated Undo/Redo buttons.
- Added "Unsaved-Changes Exit Guard" — closing the editor with unsaved edits
  asks for confirmation first; a clean draft closes with no prompt.
- Added "Save As Copy" — the overflow menu on an existing song can save the
  current in-progress edits as a brand-new song, separate from the
  already-documented song-list duplication feature.
- Added "Auto-Collapsing Metadata Fields" — the Title/Artist/Key/Tempo fields
  fold away while the lyrics field has focus, to give lyrics more room.

§2.8 Import & Export Workflows:
- Added a bullet documenting the Settings → Import & Export screen
  (`import_export_screen.dart`) as its own entry point, separate from the
  per-song and multi-selection bulk export/share paths already described.
- Extended the PDF export bullets to state that page width now fits the
  song's content (clamped 300 pt–595.28 pt), with height fixed at A4,
  instead of implying a fixed full A4-width page.

## Why

A direct read of `lib/screens/song_editor_screen.dart`,
`lib/screens/import_export_screen.dart`, and
`change_log/20260729_074230_pdf-page-width-fits-song.md` turned up six
shipped features with no mention anywhere in `docs/features.md`, even after
two earlier audit passes today. All six already exist in the app; this is a
documentation-only fix, no code was touched.

## Files changed

- `docs/features.md`

No app code (`lib/`, `android/`) was touched. `flutter analyze` / `flutter
test` are unaffected.
