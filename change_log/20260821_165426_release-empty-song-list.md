# Fix: songbook could open empty and slow, with no reason shown

Implements [plans/20260821_162443_release-empty-song-list.md](../plans/20260821_162443_release-empty-song-list.md).

## Why

The release build showed an empty songs page that took a long time to appear.
On the test phone the release build was **not** broken — a fresh install, an
obfuscated install, and a version 8 → 9 upgrade all worked and opened in about
one second. The fault had to be in the data already on the user's phone, and the
app had no way to say so: any database error was drawn as a normal "your
songbook is empty" page.

Three weak spots could produce exactly that symptom, and all three are fixed.

## What changed

### `lib/widgets/songbook_error.dart` (new)

A real error view for the songbook: an error icon, "Could not open your
songbook", a line saying the songs are still saved, the raw error text in small
selectable print, and a **Try again** button.

### `lib/screens/song_list_screen.dart`

The `error:` branch of the song stream drew `EmptySongbook`, which told the user
their songs were gone and gave no clue why. It now draws `SongbookError` and
retries by invalidating `songsStreamProvider`. `EmptySongbook` is kept for the
genuine "you have no songs" case.

### `lib/data/app_database.dart`

**1. The version 9 backfill can no longer break the migration.**

`_backfillSongTraditions()` read every song with `row.read<String>('lyrics')`,
which throws when that column holds NULL. Drift runs the whole upgrade in one
transaction, so one bad song rolled the migration back, left the version stamp
behind, and made every later launch repeat — and fail — the same work. That is
"slow to open, then empty, forever".

It now:

- reads the lyrics with `readNullable<String>('lyrics') ?? ''`;
- wraps each song's classify step in `try`/`catch`, so a song that cannot be
  read is left with empty raga and tala instead of killing the upgrade;
- skips a row whose `id` cannot be read, since there is nothing to update;
- does the whole thing in one `batch(...)` instead of one `UPDATE` per song, so
  a large songbook does not make the first launch after the upgrade crawl.

**2. The NULL repair now covers every non-null column.**

`_healNullSongTextColumns()` only repaired `raga`, `tala` and `tradition`. If an
old build left NULL in `artist`, `lyrics`, `key`, `bpm`, `favorite`,
`scroll_speed` or `scroll_measures`, drift's row mapper still hit
`Null check operator used on a null value` on **every** song read — a
permanently empty list, hidden by the old error handling.

Renamed to `_healNullSongColumns()`, driven by a new `_songColumnDefaults` map
of column name to its declared default. It still checks `PRAGMA table_info`
first, so it is safe on any schema and touches no rows on a healthy database.
`id`, `title` and `timestamp` are deliberately left out — they have been NOT
NULL in every schema this app has written.

## Tests

### `test/data/app_database_migration_test.dart`

New helper `buildVersion8DatabaseWithNullCoreColumns()` builds a version 8
database whose core song columns are nullable and hold NULL, plus a new group of
four tests:

- the upgrade completes and every song reads back;
- the NULLs are replaced with the declared defaults;
- the songs that *can* be read are still backfilled;
- the upgrade completes even when a song holds junk lyrics.

**Verified these tests catch the bug:** with only the two code fixes undone,
exactly those four fail; with the fixes in place all eight pass.

### `test/screens/song_list_screen_test.dart`

New group with three tests, using an erroring `songsStreamProvider` override:

- shows `SongbookError`, not `EmptySongbook`;
- names the fault on screen so the user can report it;
- offers a working **Try again** button.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 687 tests, all pass.
- Release APK (`--flavor prod --release --obfuscate --split-debug-info`) rebuilt
  and re-checked on the moto g54 (Android 15):
  - fresh install → 6 seed songs, screen up in 1.313 s;
  - version 8 build installed first, then upgraded → all songs kept, 1.086 s.

## Note

The scratch git worktree at `D:/Temp/claude/lc-head`, used to build the old
version for the upgrade test, has been removed.
