# Plan: fix remaining gaps in docs/features.md (second audit)

**Status:** completed

## Files to be changed

- `docs/features.md`

## The issue

`docs/features.md` was already audited and corrected twice earlier today
(see `plans/20260803_130629_fix-features-doc.md` and
`plans/20260803_140400_features-doc-audit-fixes.md`). I did a fresh, direct
comparison of the doc against the current code in `lib/` and found six more
real features that are built and shipped but not mentioned anywhere in the
doc:

1. **Undo / Redo in the song editor.** `song_editor_screen.dart` has Undo and
   Redo buttons in the app bar, wired to the lyrics text field's undo
   history. Not mentioned in §2.2.
2. **Unsaved-changes exit guard in the editor.** Leaving the editor with
   unsaved edits triggers a confirm-or-discard guard (`PopScope`, checks
   `isDirty`). A clean draft can leave freely. §2.2 only describes
   save-time validation ("Prevents saving empty or invalid entries"), not
   this separate exit-time guard.
3. **"Save as copy" in the editor.** For an existing song, the editor's
   overflow menu has a "Save as copy" action that saves the *current
   in-progress edits* (even unsaved ones) as a brand-new song. This is
   different from the already-documented "Song Duplication" in §2.1, which
   clones an already-saved song from the song list. Both exist; only one is
   documented.
4. **Auto-collapsing metadata fields while typing lyrics.** In the editor,
   the Title/Artist/Key/Tempo fields fold away (animated) when the lyrics
   field gets focus, replaced by a tappable compact summary, so the lyrics
   area gets more room. Not mentioned in §2.2.
5. **Settings → Import & Export screen.** `import_export_screen.dart` is a
   real screen (route `/settings/general/import`, titled "Import & Export")
   reachable from the Settings hub. It offers "Import ChordPro file(s)"
   (multi-file picker straight into import preview) and "Export all songs
   (ChordPro)" (whole library to one file) as a dedicated pair of actions.
   §2.8 already mentions that whole-library export exists as a capability,
   and §2.9 already says "Import" is one of the Settings hub entries, but
   neither says this single screen is the actual place both of those live,
   or that it is a separate access point from the per-song and
   multi-select-bulk export paths already described.
6. **PDF export page width now follows the song, not fixed A4.** Since the
   2026-07-29 change, PDF export measures the widest line and sets the page
   width to fit it (minimum 300 pt, maximum 595.28 pt / A4 width); only the
   height stays fixed at A4. §2.8 still only says "Compiles printable A4
   lead sheets," which reads as if the page is always full A4 width. This is
   a real, user-visible behavior (a song with short lines gets a narrower,
   taller page that looks bigger on a phone) and is worth calling out
   directly, alongside the already-documented smart font auto-fit.

None of these are new app features to build — the code for all six already
exists and is already covered by existing tests / change logs
(`change_log/20260729_074230_pdf-page-width-fits-song.md` for #6, and the
editor code itself for #1–#4). This is a documentation-only fix.

## The plan for the fix

Edit `docs/features.md` only:

- In **§2.2 Lyrics & Chords Editor**, add three bullets (or extend the
  existing "Form Validation & Unsaved Guard" bullet into two bullets) to
  cover: Undo/Redo, the unsaved-changes exit guard as its own point (keeping
  the existing save-validation bullet separate), "Save as copy", and the
  auto-collapsing metadata fields.
- In **§2.8 Import & Export Workflows**, add a bullet naming the Settings →
  Import & Export screen as an additional entry point for whole-library
  import/export, distinct from the per-song and multi-select-bulk paths.
- In **§2.8**, extend the existing PDF export bullet about font auto-fit (or
  add a new bullet next to it) to state that the page width itself is now
  computed from the widest line in the song (300 pt–595.28 pt range), with
  height fixed at A4.

No other section changes. No code, tests, or other docs are touched.

## Status

approval_pending — waiting for explicit approval before editing
`docs/features.md`.
