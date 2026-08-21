# Fixed: Setlists showed "Null check operator used on a null value"

Implements [plans/20260821_161507_setlists-null-check-crash.md](../plans/20260821_161507_setlists-null-check-crash.md).

## What was wrong

Opening **Setlists** showed `Error loading setlists: Null check operator used
on a null value`.

The setlist code was fine. The failure was in the **database upgrade to schema
version 9** — the step that added `raga`, `tala` and `tradition` to
`song_notes`.

On some devices those three columns were already on disk, but created
**nullable** by an earlier build, so the rows held `NULL`. The upgrade skips
`addColumn` for a column that already exists, so the `NULL`s stayed. It then
called `_backfillSongTraditions()`, which read every song through
`getAllSongs()`. Drift declares those columns non-null, and its generated row
mapper ends each one with `!`:

```dart
raga: attachedDatabase.typeMapping.read(DriftSqlType.string, data['raga'])!,
```

`NULL` plus `!` threw. The upgrade failed, so the database never finished
opening and every screen that reads it reported the error. Setlists was simply
where it was noticed.

## What changed

### `lib/data/app_database.dart`

- Added `_healNullSongTextColumns()`. It runs plain SQL —
  `UPDATE song_notes SET raga = '' WHERE raga IS NULL`, and the same for `tala`
  and `tradition` — so it never goes through drift's typed row mapper. It first
  checks the column exists, so it is safe on an older database, and it matches
  no rows once the data is clean.
- The version 9 upgrade step now calls it **before** `_backfillSongTraditions()`.
- `beforeOpen` calls it too, as a safety net. A device already stamped at
  version 9 with `NULL`s will never run `onUpgrade` again, so without this it
  would stay broken.
- `_backfillSongTraditions()` no longer calls `getAllSongs()`. It now reads only
  the two columns it needs:
  `customSelect('SELECT id, lyrics FROM song_notes')`. A migration must not
  depend on being able to read columns it is in the middle of filling in.

### `lib/repositories/setlist_repository.dart`

Fixed a second bug found while reading the code. `_toSongModel` built each
`SongNote` without `scrollSpeed`, `scrollMeasures`, `raga`, `tala` or
`tradition`. So a song opened from a setlist lost the scroll speed it was last
performed at, and an Indian song read as Western — which would let the
transposer shift its `[Sa]` and `[Ma]` markers like chord letters. It now maps
every field, the same way `SongRepository` does.

### `pubspec.yaml`

Added `sqlite3: ^3.4.0` to **dev_dependencies** only. The migration test needs
it to build an old-schema database file directly, without drift running its own
migration over it first. It was already pulled in by drift; naming it makes the
test's import a declared dependency. Local SQLite bindings — no network, so the
offline rule still holds.

## Tests

### New: `test/data/app_database_migration_test.dart`

Builds a schema version 8 database by hand with raw sqlite3, then re-opens it
with the app database:

- loads setlists from a plain version 8 database;
- **loads setlists when `raga`/`tala`/`tradition` already exist holding `NULL`**
  — this is the reported crash, and it fails without the fix;
- backfills an old Indian song's raga, tala and tradition from its header lines;
- leaves the songbook order alone (`timestamp` untouched).

### Updated: `test/repositories/setlist_repository_test.dart`

Added "setlist songs keep their scroll and tradition fields" — a song reached
through a setlist must be the same song as one reached through the songbook.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 680 tests, all passing.
- `dart format` run over `lib/` and `test/`.

## Note for the user

No reinstall or data loss. The repair runs by itself the next time the app
opens, and your songs, setlists and scroll settings are left as they are.
