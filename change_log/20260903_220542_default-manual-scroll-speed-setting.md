# Setting for the starting manual scroll speed

Implements [plans/20260903_214953_default-manual-scroll-speed-setting.md](../plans/20260903_214953_default-manual-scroll-speed-setting.md).

## What changed

- **`lib/core/constants/app_constants.dart`** — new key
  `prefDefaultScrollSpeed`.
- **`lib/providers/scroll_speed_settings_provider.dart`** *(new)* —
  `defaultScrollSpeedProvider` holds the starting speed in
  `shared_preferences`. Values are clamped to 0.10x–2.00x and snapped to the
  0.05 grid in whole hundredths, so repeated steps can never drift; a missing or
  broken value falls back to 1.00x. Has `increase`, `decrease` and `reset`.
- **`lib/data/app_database.dart`** — new `scrollSpeedSet` column (schema
  10 → 11). `scrollSpeed` alone could not answer "did anyone pick this?",
  because its column default (1.0) looks the same as a hand-set 1.00x.
  - The column is added at the **top** of `onUpgrade`, before any step that
    reads a song row — otherwise the version 10 sample rewrite would read a
    missing column and throw a null check error.
  - `_markSongsWithAChosenSpeed` then sets the flag for every song whose speed
    is not 1.0. Those songs keep their speed; a song still at 1.0 counts as
    "never set".
  - `updateScrollSettings` now also writes `scrollSpeedSet: true`.
- **`lib/models/song_note.dart`**, **`lib/repositories/song_repository.dart`**,
  **`lib/repositories/setlist_repository.dart`**,
  **`lib/providers/song_editor_provider.dart`** — the new field is carried
  through the model, the row mapping, inserts, updates and the editor draft, so
  an ordinary edit never drops it.
- **`lib/screens/song_performance_screen.dart`** — a song is loaded with
  `song.scrollSpeedSet ? song.scrollSpeed : <setting>`.
- **`lib/screens/scroll_settings_screen.dart`** *(new)* — Settings → General →
  **Auto-scroll**: a −/value/+ stepper for the starting speed and a
  "Reset to 1.00x" button.
- **`lib/screens/general_settings_screen.dart`** and
  **`lib/core/router/app_router.dart`** — the new card and the
  `/settings/general/auto-scroll` route.
- **`lib/screens/help/help_content.dart`** — the Auto-scroll topic says where
  the starting speed lives.
- Drift code regenerated with `build_runner`.

## Behaviour note

Songs that had a speed other than 1.00x keep it. Songs sitting at exactly 1.00x
are treated as "never set", so from now on they follow the new setting.

## Tests

- `test/providers/scroll_speed_settings_provider_test.dart` *(new)* — default,
  loading, saving, stepping, clamping, snapping and reset.
- `test/data/app_database_migration_test.dart` — a hand-built version 10
  database upgrades: the hand-set song is marked and keeps 0.40x, the untouched
  one is not marked.
- `test/repositories/song_repository_test.dart` — a fresh song has no speed of
  its own; `saveScrollSettings` marks it.
- `test/screens/song_performance_screen_test.dart` — a song with no speed of its
  own opens at the set speed; a song with its own speed ignores the setting.
- `test/helpers/fake_song_repository.dart` — the fake now sets the flag on save,
  matching the real repository.

`flutter analyze` is clean and the whole suite passes (873 tests).
