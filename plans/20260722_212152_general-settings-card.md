# Plan — Add a "General" settings card (Import + Metronome)

**Status:** completed

## The issue / what is asked

Right now the Settings screen shows five flat cards: Import, Themes, Chords,
Fonts, About. The user wants to group some items under a new **General** card:

1. Add a new card named **General** on the Settings screen.
2. Inside General, show two sub-cards: **Import** and **Metronome**.
3. **Move** the existing Import card off the top-level Settings screen into
   General (Import must no longer sit at the top level).
4. **Metronome** is an enable / disable toggle (on/off). Its state is saved so it
   survives an app restart.

Note: this plan only adds the **setting and its on/off toggle**. It does not build
the actual metronome beat/flash behaviour — that was not asked for and would be a
separate change. The toggle simply stores a saved "metronome enabled" flag.

## Design decisions (my recommendation)

- **General** is a normal settings card (same look as the others) that opens a new
  `GeneralSettingsScreen` at route `/settings/general`.
- Inside General, **Import** is a card that opens the existing
  `ImportExportScreen`, and **Metronome** is a card that opens a new
  `MetronomeSettingsScreen`.
- **Metronome** opens its own small screen holding one `SwitchListTile`
  (Enable metronome — on/off). This matches the existing "each card opens a
  screen" pattern and the wording "inside metronome make it enable/disable".
- The Import route moves from `/settings/import-export` to
  `/settings/general/import` (nested under general), so the URL matches the new
  place. Metronome is `/settings/general/metronome`.

## Files to change

**New files**
- `lib/screens/general_settings_screen.dart` — the General screen with the
  Import and Metronome cards (reuses a small card widget like the current one).
- `lib/screens/metronome_settings_screen.dart` — one enable/disable switch,
  wired to the new provider.
- `lib/providers/metronome_provider.dart` — a `Notifier<bool>` that loads and
  saves the "metronome enabled" flag via `shared_preferences` (mirrors
  `LyricFontNotifier` / `ThemeModeNotifier`). Default: **off (false)**.

**Edited files**
- `lib/screens/settings_screen.dart` — remove the top-level **Import** card; add
  a **General** card (icon `Icons.tune`) that pushes `/settings/general`. Update
  the class doc comment (it currently says "four cards" / lists Import).
- `lib/core/router/app_router.dart` — add a `general` route under `/settings`
  with two child routes: `import` → `ImportExportScreen`, `metronome` →
  `MetronomeSettingsScreen`. Remove the old top-level `import-export` child.
- `lib/core/constants/app_constants.dart` — add
  `static const String prefMetronomeEnabled = 'metronome_enabled';`.

**Tests**
- `test/screens/settings_screen_test.dart` — update: top level now shows
  General (not Import); the "Import opens its screen" flow now goes
  Settings → General → Import. Update the route table in the test helper to match
  the new nested routes and the "five cards" expectation (top level becomes
  General, Themes, Chords, Fonts, About — still five).
- New `test/providers/metronome_provider_test.dart` — default is off; toggling
  on saves `true` to `shared_preferences` and toggling off saves `false`.
- New `test/screens/metronome_settings_screen_test.dart` — the switch reflects
  the saved value and flipping it saves the new value.

## After implementing

- Run `flutter analyze` (must be clean) and `flutter test` (all pass).
- Run `dart format .`.
- Write a change log to `change_log/` referencing this plan.
