# Change log: file-open import no longer fails with "Could not search for song by title"

Implements [plans/20260903_212005_fix-file-intent-import-storage-error.md](../plans/20260903_212005_fix-file-intent-import-storage-error.md).

## The problem

Double tapping a `.chordpro` file in a file manager (reported on Android 15) opened
the Import Preview correctly, but **Import Selected** failed with:

> Import failed: StorageException: Could not search for song by title.

Importing the same file from inside the app worked.

The query itself was fine — it was checked against a real SQLite database with the
same Malayalam title and it works. The database *access* was failing, because the app
was running **two copies of itself**:

`AndroidManifest.xml` had `android:taskAffinity=""`, so a file intent did not reuse
the running activity — Android started a second `MainActivity`. Each `FlutterActivity`
builds its own `FlutterEngine`, each engine runs its own Dart isolate, and each isolate
runs `main()`, which opens its own SQLite connection. The database is never closed, so
two connections ended up on one file, and SQLite's default settings made the second one
fail instantly instead of waiting for the lock.

## What changed

### 1. One activity instance only — the actual fix

`android/app/src/main/AndroidManifest.xml`

- Removed `android:taskAffinity=""`.
- `android:launchMode` changed from `singleTop` to `singleTask`.
- Added `android:documentLaunchMode="never"`.

`singleTask` allows only one `MainActivity` in the app. `documentLaunchMode="never"`
is needed as well because file managers hand a document over with
`FLAG_ACTIVITY_NEW_DOCUMENT`, which asks for a fresh task per document — `never`
overrides that. The file intent now reaches the running app through `onNewIntent()`,
which `MainActivity.kt` already forwards to Dart. A comment above the activity records
why, so `taskAffinity=""` does not come back.

**Behaviour change to know about:** pressing Back after opening a file now goes to the
home screen instead of back to the file manager. That is normal for an app that owns a
file type.

### 2. The database survives a second connection anyway

`lib/data/app_database.dart` — new top-level `applyPragmas()`, passed as the `setup:`
callback of `NativeDatabase.createInBackground`:

- `PRAGMA journal_mode = WAL` — readers and the writer stop blocking each other.
- `PRAGMA busy_timeout = 5000` — wait up to 5 seconds for a lock instead of failing at once.
- `PRAGMA foreign_keys = ON` — stated openly, so the `ON DELETE CASCADE` on
  `setlist_items` is always honoured instead of relying on the default.

### 3. The real reason is no longer hidden

- `lib/core/errors/app_exception.dart` — new `debugDetails` getter: the friendly
  message plus the underlying cause. `toString()` is unchanged.
- `lib/screens/import_preview_screen.dart`
  - The Import Preview SnackBar now shows the reason underneath the friendly message,
    e.g. `Import failed: Could not search for song by title. (…database is locked)`.
    This bug only appeared in a release build on a phone, where a debug log is no help,
    so the reason had to travel with the report. Only error text is shown — never song
    content — so the logging rule in `docs/security.md` still holds.
  - `_checkDuplicates()` no longer swallows its error in an empty `catch (_)`. It logs
    in debug builds and keeps the screen usable. That silent catch is why the first
    failed database read gave no sign at all.

### 4. Supporting change

`pubspec.yaml` — `sqlite3` moved from `dev_dependencies` to `dependencies`, because
`applyPragmas()` in `lib/` now names its `Database` type. It is local SQLite bindings
only, no network, and drift already pulled it in at runtime.

## Files changed

- `android/app/src/main/AndroidManifest.xml`
- `lib/data/app_database.dart`
- `lib/core/errors/app_exception.dart`
- `lib/screens/import_preview_screen.dart`
- `pubspec.yaml`, `pubspec.lock`
- `test/data/app_database_connection_test.dart` (new)

## Tests

New `test/data/app_database_connection_test.dart`:

- `turns on WAL, a busy timeout, and foreign keys` — reads the three pragmas back.
- `a second connection can still read and write the same file` — the regression test.
  It opens the database file twice (leaving the first open, as the app does), then reads
  and writes through the second connection, using the same Malayalam title from the bug
  report.

Results:

- `flutter analyze` — no issues.
- `flutter test` — 854 tests, all passing.
- The merged Android manifest was checked with
  `./gradlew :app:processDevDebugMainManifest`: it comes out with `singleTask`,
  `documentLaunchMode="never"`, and no `taskAffinity`.

## Still to confirm on a device

No Android device was attached, so the fix could not be tried on the phone. Please
install and check: open the app, then double tap the `.chordpro` file in a file manager.
The Import Preview should show the **In Songbook** badge when the song already exists,
and **Import Selected** should succeed. If it still fails, the SnackBar will now name the
real reason — send that text.
