# Plan: Fix "StorageException: Could not search for song by title" when opening a file by double tap

**Status:** completed

## What the user sees

Double tapping a `.chordpro` file in a file manager opens LyricChord and shows the
Import Preview screen. The song is parsed and listed correctly (title, 120 BPM,
Preview). Pressing **Import Selected** fails with:

> Import failed: StorageException: Could not search for song by title.

The same file imports fine from inside the app (Settings → Import/Export).
Reported on **Android 15**.

## What is going on

`StorageException('Could not search for song by title.')` is thrown by
[song_repository.dart:62](lib/repositories/song_repository.dart#L62) when the drift
query in [app_database.dart:197](lib/data/app_database.dart#L197) throws. I checked
the query itself: it is not the problem. I ran it against a real SQLite database with
the exact Malayalam title from the screenshot and it works (returns `null`, then finds
the row after insert). So the query is fine — the **database access itself is failing**
on this launch path.

Two things in the Android manifest make that happen:

```xml
android:launchMode="singleTop"
android:taskAffinity=""
```

`taskAffinity=""` means the activity belongs to no task of its own. When a file
manager fires the `VIEW` intent, Android does not reuse the already running
LyricChord activity — it starts a **second `MainActivity` instance**. In Flutter,
every `FlutterActivity` builds its **own `FlutterEngine`**, and every engine runs its
**own Dart isolate**, which runs `main()` again. `main()` does:

```dart
final database = AppDatabase();   // lib/main.dart:22
```

So the app now has **two SQLite connections open on the same database file**, and the
first one is never closed (nothing calls `close()` anywhere). The second connection
hits SQLite locking. Because drift's default `busy_timeout` is 0 and the default
journal mode is `delete` (readers and writers block each other), the query fails
immediately instead of waiting — and that surfaces as this `StorageException`.

Two supporting signs from the screenshot:

- The song card shows no **In Songbook** duplicate badge. `_checkDuplicates()` in
  [import_preview_screen.dart:54](lib/screens/import_preview_screen.dart#L54)
  calls `getAllSongs()` inside a `try` with an empty `catch (_)`, so its failure is
  swallowed silently. The very first database read on this screen already failed.
- Import from inside the app always works, because there only one engine exists.

The error message also hides the real reason: `AppException.toString()` prints only
the message, never `cause`, so there is nothing to debug from.

## The fix

Three parts: stop the second instance (root cause), make SQLite tolerant of
concurrent access anyway (defence in depth), and stop hiding failures.

### 1. One app instance only (root cause)

`android/app/src/main/AndroidManifest.xml`

- Remove `android:taskAffinity=""`.
- Change `android:launchMode="singleTop"` to `android:launchMode="singleTask"`.
- Add `android:documentLaunchMode="never"`.

`documentLaunchMode="never"` is added because modern file managers (including the
Files app on Android 15) open a document with `FLAG_ACTIVITY_NEW_DOCUMENT`, which asks
Android for a **fresh task per document**. `never` overrides that flag and forces the
intent into the existing task. Together with `singleTask` this closes both routes to a
second instance.

`singleTask` guarantees at most one `MainActivity` in the whole app. A file intent is
then delivered to the running instance through `onNewIntent()` — which
`MainActivity.kt` already handles and forwards to Dart as `onFileOpened`. One
activity means one Flutter engine, one Dart isolate, one `AppDatabase`.

Trade-off to be aware of: with `singleTask`, pressing Back from the app after opening
a file goes to the home screen instead of back to the file manager. This is the normal
behaviour for an app that owns a document type, and it is the price of not running two
copies of the app at once.

### 2. Make the database tolerant of a second connection

`lib/data/app_database.dart` — in `_openConnection()`, pass a `setup:` callback to
`NativeDatabase.createInBackground` that runs:

- `PRAGMA journal_mode = WAL;` — readers no longer block writers.
- `PRAGMA busy_timeout = 5000;` — if a lock is held, wait up to 5 seconds instead of
  failing at once.
- `PRAGMA foreign_keys = ON;` — keep the existing cascade delete behaviour working
  (it is currently relying on the default; setting it explicitly here is safe and
  matches the `ON DELETE CASCADE` constraints on `setlist_items`).

This alone would probably have avoided the crash, and it protects any future path
where a second connection appears.

### 3. Stop hiding the real error

- `lib/core/errors/app_exception.dart`: keep the user-facing `message` as it is, but
  add a `debugDetails` getter (message + cause) used only for debug logging.
- `lib/screens/import_preview_screen.dart`:
  - `_checkDuplicates()` — no longer swallow the error silently. Log it in debug and
    keep the screen usable (the duplicate badge is only a hint).
  - `_performImport()` — log the full error and cause with `debugPrint` when
    `kDebugMode`, so the next problem of this kind is diagnosable from `flutter run`
    or `adb logcat`.
  - Because this bug only shows up on a real phone running a **release** build, a debug
    log alone would not have helped here. So the SnackBar will also show the underlying
    reason (for example `database is locked`) after the friendly message. This is a
    deliberate, small step away from the "cause is never shown to users" note in
    `app_exception.dart`: it turns an unfixable report into a fixable one. Say the word
    if you would rather keep the SnackBar text exactly as it is today.

No song content is logged — only the exception text — so the "never log song content"
security rule still holds.

## Note on Android 15

Nothing in Android 15 changes the diagnosis — `taskAffinity=""` allows a second
activity instance on every Android version. But Android 15 makes it **more likely to
be hit**, because document-opening apps there routinely use `FLAG_ACTIVITY_NEW_DOCUMENT`
when handing a file to a viewer, which creates a new task unless the target activity
forbids it. That is exactly what step 1 now forbids.

Being honest about the limit of this diagnosis: I could not attach a device
(`adb devices` is empty), so I could not read the real underlying SQLite error — it is
hidden by `AppException.toString()`. Step 3 below fixes that, so if this somehow is not
the cause, the next attempt will show the actual message instead of a dead end.

One Android 15 possibility I checked and ruled out: 16 KB memory page devices can fail
to load an unaligned native `sqlite3` library. That would break **every** database read,
so the songbook list would be empty too — but the app works normally otherwise, so this
is not it.

## Files to change

| File | Change |
|------|--------|
| `android/app/src/main/AndroidManifest.xml` | `singleTask`, `documentLaunchMode="never"`, drop `taskAffinity=""` |
| `lib/data/app_database.dart` | `setup:` pragmas — WAL, busy_timeout, foreign_keys |
| `lib/core/errors/app_exception.dart` | add `debugDetails` |
| `lib/screens/import_preview_screen.dart` | log real cause; do not swallow duplicate-check failure |
| `test/data/app_database_test.dart` (new or existing) | regression test: two `AppDatabase` connections on one file can both read and write |

## How it will be checked

- `flutter analyze` — must stay clean.
- `flutter test` — all tests pass, including the new two-connection test.
- Manual on device: install, open the app, then double tap the `.chordpro` file in a
  file manager. Expect the Import Preview to show the **In Songbook** badge when the
  song already exists, and **Import Selected** to succeed.

## Risk

Low. The manifest change alters task behaviour (Back button as noted above). The
pragma change makes the database file use WAL — this is a normal SQLite mode, is
backward compatible, and creates `-wal` / `-shm` side files next to the database.
