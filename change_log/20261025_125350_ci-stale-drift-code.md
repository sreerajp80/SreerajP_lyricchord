# Fix CI: stale generated drift code

Plan: [plans/20261025_123328_ci-stale-drift-code.md](../plans/20261025_123328_ci-stale-drift-code.md)

## What was wrong

CI failed at the generated-file check. The last commit updated `pubspec.lock`
(newer `drift_dev`, `analyzer`, `build_runner`), but `lib/data/app_database.g.dart`
was not rebuilt with the new versions.

## What changed

- `lib/data/app_database.g.dart` — rebuilt with
  `dart run build_runner build --delete-conflicting-outputs`. No hand edits.
  Only three lines changed: `e.readTable(table)` now has explicit type
  arguments for `$SongNotesTable`, `$SetlistsTable` and `$SetlistItemsTable`.

No change to the CI workflow, `pubspec.yaml` or `pubspec.lock`.

## Checks

- `dart format --output=none --set-exit-if-changed .` — 0 files changed
- `flutter analyze` — no issues
- `flutter test` — all 1270 tests passed
- `bash tool/check_sanskrit_hindi_markers.sh` — passed

## Tip

After any `pubspec.lock` update, run `build_runner` again before committing.
