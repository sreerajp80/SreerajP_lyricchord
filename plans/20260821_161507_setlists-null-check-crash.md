# Setlists screen fails with "Null check operator used on a null value"

**Status:** completed

## The issue

Opening **Setlists** shows:

```
Error loading setlists: Null check operator used on a null value
```

### What is really happening

The failure is not in the setlist code. It is in the **database upgrade to
schema version 9** (the change that added the `raga`, `tala` and `tradition`
columns to `song_notes`).

On some devices the `song_notes` table on disk already has those three columns,
but they were created as **nullable** columns by an earlier development build,
so the existing rows hold `NULL`.

The version 9 upgrade step in `lib/data/app_database.dart` does this:

1. Read the column names the table already has (`_songColumnNames`).
2. Skip `addColumn` for any column that is already there. — So the three
   columns are skipped, and the `NULL` values stay.
3. Call `_backfillSongTraditions()`, which calls `getAllSongs()`.

Step 3 is where it blows up. `getAllSongs()` maps each row into a
`SongNoteRow`, and drift's generated mapper ends every non-null column with
`!`:

```dart
raga: attachedDatabase.typeMapping.read(DriftSqlType.string, data['raga'])!,
```

`NULL` in, `!` on null, crash. The upgrade throws, so drift never marks the
database as opened, and **every** screen that reads the database reports the
error. Setlists is simply the screen where the user noticed it.

### Reproduced

A throwaway test built a version 8 database two ways and re-opened it with the
current code:

| `song_notes` on disk | Result |
|---|---|
| no `raga` / `tala` / `tradition` columns | passes |
| `raga TEXT, tala TEXT, tradition TEXT` (nullable, values `NULL`) | **"Null check operator used on a null value"** |

The second row is exactly the reported error.

## Files to change

| File | Change |
|---|---|
| `lib/data/app_database.dart` | Repair `NULL`s before the backfill; stop the backfill from reading whole typed rows |
| `lib/repositories/setlist_repository.dart` | Carry the missing song fields through when building setlist songs |
| `test/data/app_database_migration_test.dart` (new) | Test that a version 8 database with nullable `raga`/`tala`/`tradition` upgrades and loads |
| `test/repositories/setlist_repository_test.dart` | Test that a setlist's songs keep their scroll and tradition fields |

## The fix

### 1. Heal the `NULL` values before anything reads them

In the `from < 9` upgrade step, after the `addColumn` loop and **before**
`_backfillSongTraditions()`, run plain SQL that does not go through drift's
typed mapper:

```dart
await customStatement(
  "UPDATE song_notes SET raga = '' WHERE raga IS NULL",
);
await customStatement(
  "UPDATE song_notes SET tala = '' WHERE tala IS NULL",
);
await customStatement(
  "UPDATE song_notes SET tradition = '' WHERE tradition IS NULL",
);
```

This is safe on a table where the columns are already `NOT NULL` — the
`WHERE` simply matches nothing.

### 2. Stop the backfill from mapping whole rows

`_backfillSongTraditions()` currently calls `getAllSongs()`, which builds a
full `SongNoteRow` for every song just to read `id` and `lyrics`. Any future
column added the same way would break it again. Replace that read with a
`customSelect` that asks for only the two columns it needs:

```dart
final rows = await customSelect(
  'SELECT id, lyrics FROM song_notes',
).get();
for (final row in rows) {
  final id = row.read<int>('id');
  final lyrics = row.read<String>('lyrics');
  ...
}
```

The rest of the method (parse the sheet, detect the tradition, write only the
three columns) stays exactly as it is.

### 3. Also run the repair on open, as a safety net

Some devices may already be stamped at version 9 with `NULL`s in place — for
them `onUpgrade` never runs again, so the repair in step 1 would never fire and
the app would stay broken. Add the same three `UPDATE` statements to
`beforeOpen`, next to the existing `PRAGMA foreign_keys` line, guarded so they
only run when the columns exist. They are cheap and touch no rows once the data
is clean.

### 4. Fix the setlist song mapping (a real bug found on the way)

`SetlistRepository._toSongModel` builds each `SongNote` without
`scrollSpeed`, `scrollMeasures`, `raga`, `tala` or `tradition`. So a song
opened from a setlist silently loses its saved scroll speed and, worse, an
Indian song looks Western — which is exactly the case the tradition column was
added to protect. Map all the fields, the same way
`SongRepository` already does.

## Not doing

- Not bumping the schema version. The data repair is idempotent and belongs
  with version 9, not behind a new number.
- Not changing the Setlists screen. Its error display is correct; it was
  reporting a real failure from lower down.

## Checks after the change

- `flutter analyze` clean.
- `flutter test` all green, including the new migration test.
