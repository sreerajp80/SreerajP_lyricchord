# Upgraded phones: songbook empty and import fails with "Null check operator"

**Status:** completed

## The issue

A user who upgraded from an old version of LyricChord reports:

- The songbook shows no songs at all (most likely the songbook error screen,
  which has no song cards).
- Importing any file fails with
  `Import failed: Could not search for song by title. (Null check operator used on a null value)`.
  This happens for a song with a title and for an "Untitled Song".

## Why it happens

- Drift (our database library) says every `song_notes` column is "never empty".
  Its generated row reader ends each column with `!`. If one stored value is
  `NULL`, reading that row throws "Null check operator used on a null value".
  Drift turns any other bad value into a *different* error, so this error means a real `NULL`.
- A song list read and the import's duplicate-title check both read full song
  rows. So one bad row breaks the songbook *and* every import.
- Old builds created some columns without a "not NULL" rule. We already repair
  this when the database opens (`_healNullSongColumns()`, run in `onUpgrade` and in
  `beforeOpen`), but only for 10 columns: `artist`, `lyrics`, `key`, `bpm`,
  `favorite`, `scroll_speed`, `scroll_measures`, `raga`, `tala`, `tradition`.
- The repair **does not cover** `title`, `timestamp` and `scroll_speed_set`. These
  are the only non-`id` song columns left. A `NULL` in any of them still breaks
  every read. The setlist tables (`setlists.name`, `description`, `created_at`,
  `updated_at`, `setlist_items.sort_order`) have no repair at all.

We cannot read the database on the user's phone, so we do not know *which*
column holds the `NULL`. This fix repairs every remaining one, so any of them is covered.

## The fix

1. `lib/data/app_database.dart`
   - Add the missing song columns to `_songColumnDefaults`:
     - `title` → `'Untitled Song'` (the app's own title for a song with no
       name, `SongTitleWords.englishUntitled`). It is not `''`, so the song is
       still visible and can be renamed.
     - `timestamp` → `0` (the song sorts to the end of the list instead of vanishing).
     - `scroll_speed_set` → `0` ("speed not chosen by hand", the column default).
   - Add the same repair for the setlist tables (new small defaults map and a
     shared helper, so the songs and setlists code stays one loop):
     `setlists.name` → `'Setlist'`, `description` → `''`,
     `created_at` / `updated_at` → `0`, `setlist_items.sort_order` → `0`.
     Each column is checked first with `PRAGMA table_info`, as today, so a
     database that lacks the table or column is skipped safely.
   - Run it in the same two places as now (`onUpgrade` before any row read,
     and `beforeOpen`). On a healthy database the `WHERE … IS NULL` matches
     nothing, so it costs almost nothing.
2. `test/data/app_database_migration_test.dart`
   - New old-schema builder: a version 10 database whose `title`, `timestamp`
     and `scroll_speed_set` are nullable and hold `NULL` in one row.
   - Tests: the songbook reads every song back; the NULLs become the defaults
     above; `findByTitle` (the import's duplicate check) works.
   - Test: a setlist row with `NULL` name and dates reads back.

## Files to change

- `lib/data/app_database.dart`
- `test/data/app_database_migration_test.dart`

No schema version change, no generated-file change, no new strings.

## What the user must do

Install the new build over the old one. On first open the repair fixes the
data, and their songs come back. No data is deleted.

## If it is still broken after this

Then the `NULL` is not the cause, and the next step is a diagnostic build that
adds the failing code location to the error text (decoded with the release
symbol files). That would be a separate plan.
