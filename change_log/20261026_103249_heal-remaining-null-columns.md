# Upgraded phones: repair the last NULL song and setlist columns

Plan: [plans/20261026_094548_heal-remaining-null-columns.md](../plans/20261026_094548_heal-remaining-null-columns.md)

## The problem

A user who upgraded from an old version saw no songs in the songbook, and every
import failed with
`Import failed: Could not search for song by title. (Null check operator used on a null value)`.

Drift (the database library) reads every non-null column with `!`. One stored
`NULL` makes reading that row throw exactly this error. Drift turns any other
bad value into a different error. The songbook and the import's duplicate-title
check both read full song rows, so one bad row breaks both.

The repair that runs when the database opens (added on 21 August) covered only
10 song columns. It skipped `title`, `timestamp` and `scroll_speed_set`, and
did not touch the setlist tables at all.

## What changed

### `lib/data/app_database.dart`

- `_songColumnDefaults` now also covers:
  - `title` → `'Untitled Song'` (the app's own name for a song with no title,
    `SongTitleWords.englishUntitled`), so the song stays visible and can be renamed;
  - `timestamp` → `0` (the song sorts to the end of the list);
  - `scroll_speed_set` → `0` (speed not set by hand, the column default).
  Only `id` is left out, because SQLite never lets the row id be NULL.
- New `_setlistColumnDefaults` for `setlists` (`name` → `'Setlist'`,
  `description` → `''`, `created_at` / `updated_at` → `0`) and `setlist_items`
  (`sort_order` → `0`).
- The repair is now one shared helper, `_healNullColumns(table, defaults)`,
  with `_columnNames(table)`. It runs plain SQL
  (`UPDATE … SET col = default WHERE col IS NULL`), so it never goes through drift's
  row reader. A table or column that does not exist yet is skipped.
- `_healNullSongColumns()` was renamed `_healNullValues()`, because it now also
  repairs the setlist tables. It still runs in the same two places: at the start
  of `onUpgrade`, and in `beforeOpen` (for phones already at the current
  version, where `onUpgrade` never runs again).
- No schema version change and no generated-file change.

### `test/data/app_database_migration_test.dart`

- New builder `buildDatabaseWithNullTitleTimeAndSetlist`: a database whose
  `title`, `timestamp`, `scroll_speed_set` and setlist columns allow NULL and
  hold NULL in some rows.
- New group "NULL title, timestamp and setlist columns". It runs at version 10
  (the upgrade path) and at version 11 (already current; only `beforeOpen` repairs it):
  - every song reads back, and the NULLs become the defaults above;
  - `findByTitle` (the import's duplicate check) finds existing songs and
    returns `null` for a new title;
  - the setlist reads back with its defaults.
- Checked: with the old `app_database.dart`, all 6 new tests fail with
  "Null check operator used on a null value"; with the fix they pass.

## Checks

- `dart format --set-exit-if-changed .`: no changes
- `flutter analyze`: no issues
- `flutter test`: all 1292 tests pass

## Not yet confirmed

We cannot read the database on the user's phone. The fix covers every column
that can still cause this error, but it is confirmed only once the user installs
the new build. If the songbook is still empty after that, the next step is a
diagnostic build that shows the exact failing code location (separate plan).
