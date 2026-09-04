# Setting for the starting manual scroll speed

**Status:** completed

## Issue

Manual auto-scroll always starts at `1.00x` for a song that has never had its
speed changed (`AutoScrollSettings.defaultSpeed`). There is no way to say "start
every new song at 0.20x". A user who performs slowly has to step the speed down
by hand for every song.

We want a setting: **Starting scroll speed**. A song that has its own saved
speed still opens at that speed; the setting is used only for a song that has
never had a speed saved.

## Why a database change is needed

Today `scrollSpeed` is a non-null column with a default of `1.0`, so a song that
was never touched and a song deliberately set to `1.00x` look exactly the same.
To use the setting "only when nothing was saved" we must be able to tell them
apart.

Fix: a new column `scrollSpeedSet` (boolean, default `false`), set to `true` the
first time the speed is saved for that song.

**Upgrade of existing songs:** the migration sets `scrollSpeedSet = 1` for every
song whose `scrollSpeed` is not `1.0`. Those songs clearly had their speed set
by hand, so they keep it. A song still sitting at `1.0` counts as "never set"
and will follow the new setting. This is stated plainly because it is a real
behaviour change for songs left at `1.00x`.

## Files to change

| File | Change |
|------|--------|
| `lib/core/constants/app_constants.dart` | New key `prefDefaultScrollSpeed = 'default_scroll_speed'`. |
| `lib/providers/scroll_speed_settings_provider.dart` *(new)* | `Notifier<double>` reading/writing the key in `shared_preferences`, same shape as `import_settings_provider.dart`. Value is clamped and snapped to the same grid as the performance stepper (0.10–2.00, step 0.05); a missing or bad value falls back to `1.00`. |
| `lib/data/app_database.dart` | Add `scrollSpeedSet` column; bump `schemaVersion` 10 → 11; add the `from < 11` migration step (add the column if missing, then backfill as described above). |
| `lib/models/song_note.dart` | New `scrollSpeedSet` field (default `false`) — constructor, `copyWith`, `==`, `hashCode`. |
| `lib/repositories/song_repository.dart` | Map the new column when reading; write `scrollSpeedSet: true` in `saveScrollSettings`; carry the field on insert/update. |
| `lib/repositories/setlist_repository.dart` | Carry the new field where the full song row is copied (it already copies `scrollSpeed`). |
| `lib/providers/song_editor_provider.dart` | Carry the field through the editor draft so saving an edit does not drop it. |
| `lib/screens/song_performance_screen.dart` | When loading a song, pass `song.scrollSpeedSet ? song.scrollSpeed : <setting value>` to `loadForSong`. |
| `lib/screens/scroll_settings_screen.dart` *(new)* | Small settings screen with a stepper (−/value/+, same 0.05 steps and 0.10–2.00 range as the performance control) and a short line of help text. |
| `lib/screens/general_settings_screen.dart` | New card: **Auto-scroll** — "Starting speed for manual scrolling", opening the new screen. |
| `lib/core/router/app_router.dart` | New route `/settings/general/auto-scroll`. |
| `lib/screens/help/help_content.dart` | One short paragraph telling the user where the starting speed lives. |
| `test/providers/scroll_speed_settings_provider_test.dart` *(new)* | Default value, saving, clamping and snapping of bad values. |
| `test/data/app_database_test.dart` *(or the existing migration test file)* | The v10 → v11 upgrade adds the column and backfills correctly. |
| `test/repositories/song_repository_test.dart` | `saveScrollSettings` marks the song as "speed set". |
| `test/screens/song_performance_screen_test.dart` | A song with no saved speed opens at the setting's speed; a song with a saved speed keeps its own. |
| `change_log/2026...._default-manual-scroll-speed-setting.md` | New change log after the work. |

(Exact test file names will match whatever already exists in the repo.)

## Plan for the fix

1. **Setting store.** A new Riverpod notifier holds the starting speed as a
   `double` in `shared_preferences`. It reuses the existing snapping rule so the
   saved value can never sit off the stepper grid.
2. **Database.** Add `scrollSpeedSet`, bump the schema version, and write the
   migration so a re-run is harmless (check the column list first, the way the
   v9 step already does).
3. **Marking a song.** `saveScrollSettings` — the debounced write that already
   runs when the user changes the speed — also sets `scrollSpeedSet` to true.
   From then on that song opens at its own speed and ignores the setting.
4. **Opening a song.** The performance screen picks the song's own speed when
   `scrollSpeedSet` is true, otherwise the setting. Tempo-Auto measures are not
   touched.
5. **UI.** A new **Auto-scroll** card under Settings → General, with a stepper
   for the starting speed and a "Reset to 1.00x" button.
6. **Checks.** `flutter analyze` clean, `flutter test` passing,
   `dart run build_runner build --delete-conflicting-outputs` re-run for the
   drift change, and `dart format .` before finishing.

## Not doing

- No change to Tempo-Auto (BPM/measures) — only the Manual speed.
- The setting does not change songs that already have a speed of their own.
