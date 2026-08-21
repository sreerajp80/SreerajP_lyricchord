# Release build shows an empty, slow song list

**Status:** completed

## What you reported

In the release build the songs page is empty, and it takes a long time to appear.
The same page works in the dev/debug build.

## What I checked on the connected phone (moto g54, Android 15)

I built and installed the real release APK three ways and launched it each time:

| Test | Result |
|------|--------|
| Fresh install, `--release` | Works. 6 seed songs. Screen up in 979 ms |
| Fresh install, `--release --obfuscate --split-debug-info` | Works. 6 seed songs. Screen up in 1.3 s |
| Old build (HEAD, schema v8) installed first, then upgraded to the new build (schema v9) | Works. All songs kept. Screen up in 1.0 s |

So the current source is **not** broken for a clean phone or for a normal v8 → v9
upgrade. Nothing failed in `logcat` in any of the three runs. That means the
problem is tied to the **data already on your phone**, not to release mode itself.

## The real issue

The code has no way to tell us what went wrong, and three weak spots can produce
exactly "empty and slow".

### Issue 1 — a database error is silently drawn as "no songs"

[lib/screens/song_list_screen.dart:138](../lib/screens/song_list_screen.dart#L138)

```dart
error: (_, _) => const EmptySongbook(),
```

If the database fails to open, or a row cannot be read, the stream sends an
error. The screen throws that error away and draws the normal empty songbook.
The user sees a blank page with no reason and no retry. This is why the fault
is invisible — and why we cannot tell from your phone what actually broke.

### Issue 2 — the version 9 backfill can throw on real data, and then it retries forever

`_backfillSongTraditions()` in [lib/data/app_database.dart](../lib/data/app_database.dart)
reads every song:

```dart
final songId = row.read<int>('id');
final sheet = parser.parseSheet(row.read<String>('lyrics'));
```

`read<String>` throws if the column holds NULL. An older build could have left
NULL in `lyrics` (the same kind of fault the code already fixes for `raga`,
`tala` and `tradition`), and an imported song can also leave odd text there.

Drift runs the whole migration inside one transaction. If this throws:

1. the migration rolls back, so the version stamp stays at 8;
2. the open fails, so the song stream errors — the page draws empty (Issue 1);
3. the **next** launch tries the whole migration again, fails again.

That is "empty forever, and slow every single launch". It matches your report
exactly.

### Issue 3 — the heal only covers three columns, and the backfill is one write per song

- `_healNullSongTextColumns()` repairs NULLs in `raga`, `tala` and `tradition`
  only. If `artist`, `lyrics` or `key` hold NULL on an old phone, drift's row
  reader still hits `Null check operator used on a null value` on **every**
  song read. The list is then permanently empty, and Issue 1 hides it.
- `_backfillSongTraditions()` does one `UPDATE` per song, each its own implicit
  write. On a phone with a large songbook this is slow on first upgrade.

## Plan for the fix

### 1. Show the error instead of hiding it

**File:** `lib/screens/song_list_screen.dart`

Replace the `error:` branch with a real error view: a short plain-English
message ("Could not open your songbook"), the error text in small print, and a
**Retry** button that invalidates `songsStreamProvider`. Keep `EmptySongbook`
only for the genuine "you have no songs" case.

### 2. Make the version 9 backfill unable to break the migration

**File:** `lib/data/app_database.dart`

- Read the lyrics defensively: `row.readNullable<String>('lyrics') ?? ''`.
- Wrap each song's classify-and-write in `try`/`catch`, so one bad row is left
  with empty raga/tala and a Carnatic-or-Western default rather than killing the
  whole upgrade.
- Run the whole loop inside one `batch(...)` so the upgrade does a single write
  pass instead of one per song.

### 3. Widen the NULL repair to every column drift declares non-null

**File:** `lib/data/app_database.dart`

Extend `_healNullSongTextColumns()` (rename to `_healNullSongColumns()`) to also
reset NULLs in `artist`, `lyrics`, `key`, `bpm`, `favorite`, `scroll_speed` and
`scroll_measures` to their declared defaults. Same shape as now: check
`PRAGMA table_info` first, so it is safe on any schema and touches no rows on a
healthy database.

### 4. Tests

**File:** `test/data/app_database_migration_test.dart`

Add to the existing `schema version 9 upgrade` group:

- a version 8 database whose `song_notes.lyrics` is NULL → the upgrade
  completes and both songs are readable;
- a version 8 database with NULL `artist` and NULL `key` → songs are readable
  after the upgrade;
- a song whose lyrics are junk (unbalanced braces, very long line) → the
  upgrade still completes.

**File:** `test/screens/song_list_screen_test.dart` (new, or added to existing
screen tests)

- when `songsStreamProvider` is overridden with an error stream, the screen
  shows the error view and a Retry button, **not** `EmptySongbook`.

### 5. Verify

- `flutter analyze` clean, `flutter test` green.
- Rebuild the release APK and re-run the three device scenarios above.

## Files to change

| File | Change |
|------|--------|
| `lib/screens/song_list_screen.dart` | Show a real error view with Retry instead of `EmptySongbook` |
| `lib/data/app_database.dart` | Defensive + batched `_backfillSongTraditions`; widen the NULL heal |
| `test/data/app_database_migration_test.dart` | NULL-column and junk-lyrics upgrade tests |
| `test/screens/song_list_screen_test.dart` | Error-view test |

## What this will not do

It will not, on its own, tell us what is wrong on your phone right now — but
after change 1 the app will **print the reason on screen**, so one launch of the
new release build will name the fault. If you can also tell me which app version
was installed on that phone before, I can aim the fix more precisely.

## Note

I created a scratch git worktree at `D:/Temp/claude/lc-head` to build the old
version for the upgrade test. I will remove it when this is done. No file in the
project was changed during the investigation.
