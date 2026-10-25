# Change log: Guideline compliance — Phase 8 (Delete all data)

Implements Phase 8 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gap G1, answer Q8 "yes"; engineering standard §15.4).

## What the user sees

- **Settings → Delete all data** — the last Settings card, in the error colour, with no
  chevron.
- Tapping it asks first: "Delete all data?" with a plain explanation ("… This cannot be
  undone. LyricChord then starts fresh, with its sample songs."), **Cancel** and a red
  **Delete everything** button (standard §6.4: a destructive confirm says what it does).
- On confirm: a short heavy haptic, a plain busy screen, then the app starts again as on
  first install (sample songs and sample setlist re-seeded, default settings), with the
  message "All data deleted". If any step failed, the app still restarts and shows "Could
  not delete all data. Some of it may still be there."
- Help → Your songbook has a new "Start fresh" section (3 points) explaining this.

## What changed

### New code (target layer in brackets)

- `lib/services/data_purge_service.dart` [services] — `DataPurgeService.deleteAllData()`:
  closes the database, deletes the database file and its `-wal`, `-shm`, `-journal` files,
  clears every `SharedPreferences` value, and empties the temporary folder. Every step runs
  even if an earlier one fails; failures are logged and end in a
  `StorageException(kind: StorageFailure.deleteAllData)`. Folders are injectable for tests.
- `lib/core/startup/app_startup.dart` [core/startup, new folder] — `AppStartup.start()` holds
  start-up steps 5–8 (moved out of `main.dart` so it stays thin, standard §3.2). It also
  provides the delete flow: show `BusyApp`, wait one frame so no screen still reads the
  database, delete, then start again with a message. It keeps one lifecycle observer
  across restarts.
- `lib/screens/busy_app.dart` [screens] — a wordless progress screen shown while deleting.
- `lib/providers/data_purge_provider.dart` [providers] — `deleteAllDataProvider`, which
  `AppStartup` overrides; the Settings screen only calls it.

### Changed code

- `lib/main.dart` — now only steps 1–2 (bindings, logger, error handlers), the font
  licences, and `AppStartup.start(app: const LyricChordApp())`.
- `lib/screens/settings_screen.dart` — now a `ConsumerWidget`; the new card and confirm
  dialog. The haptic is fired without waiting, so it can never hold up the delete.
- `lib/core/errors/app_exception.dart` — new `StorageFailure.deleteAllData`;
  `lib/l10n/l10n_labels.dart` maps it to its message.
- `lib/screens/help/help_content.dart` — "Start fresh" section in Your songbook.
- `lib/l10n/app_en.arb` (+ generated) — `titleSettingsDeleteAllData`,
  `descSettingsDeleteAllDataSubtitle`, `titleDeleteAllData`, `descDeleteAllData`,
  `actionDeleteEverything`, `bodyAllDataDeleted`, `errorStorageDeleteAllData`,
  `helpSongbookS6Heading`, `helpSongbookS6P1`–`P3`.

### Tests (7 new)

- `test/services/data_purge_service_test.dart` — with real files in temp folders: the
  database files, settings and temp files are removed after closing the database; other
  files are left alone; a failing step does not stop the rest and ends in the right
  `StorageException`; running it with nothing to delete is fine.
- `test/screens/settings_screen_test.dart` — the dialog asks first with a clear Delete
  button; Cancel deletes nothing; Delete everything runs the delete. The card-count test now
  expects seven cards.
- `test/screens/help_content_test.dart` — section and point counts updated for the new
  Help section.

### Docs

- `docs/security.md` §6.2 — the gap is closed; describes what is deleted and how.
- `PRIVACY.md` — mentions Settings → Delete all data.
- `docs/architecture.md` §4, §5 and `docs/project_structure.md` — the new `core/startup/`
  folder and where start-up steps live.
- `docs/features.md` — the Settings Hub line lists Delete all data.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1037 tests passed.
- Hardened prod build (`--obfuscate --split-debug-info=build/symbols/android-prod-2.6.13+37/
  --split-per-abi`) — built; arm64 APK 28.1 MB. `aapt2`: no `INTERNET`, no
  `ACCESS_NETWORK_STATE`.
- `android\gradlew --stop` run; no Gradle or Kotlin daemon left.

## Not tested

- The restart itself (`AppStartup` replacing the running app) is not covered by an
  automated test; the delete step and the Settings flow are. Please try it on a phone:
  Settings → Delete all data → Delete everything; the app should come back on the songbook
  with only the sample songs, default theme, and the "All data deleted" message.
