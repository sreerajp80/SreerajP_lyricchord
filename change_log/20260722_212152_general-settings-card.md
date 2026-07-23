# Change log — Add a "General" settings card (Import + Metronome)

Implements plan `plans/20260722_212152_general-settings-card.md`.

## What changed

- **Settings screen** now shows a **General** card (icon `Icons.tune`) in place
  of the old top-level Import card. General, Themes, Chords, Fonts, About —
  still five cards. Doc comment updated.
- **New General screen** (`lib/screens/general_settings_screen.dart`) with two
  cards: **Import** (opens the existing import screen) and **Metronome**
  (opens the new metronome screen).
- **New Metronome screen** (`lib/screens/metronome_settings_screen.dart`) with a
  single on/off `SwitchListTile` to enable or disable the metronome.
- **New provider** (`lib/providers/metronome_provider.dart`) —
  `metronomeEnabledProvider`, a `Notifier<bool>` that loads and saves the flag
  via `shared_preferences`. Default is **off**.
- **New constant** `AppConstants.prefMetronomeEnabled = 'metronome_enabled'`.
- **Routes** (`lib/core/router/app_router.dart`): added `general` under
  `/settings`, with children `import` and `metronome`. The old
  `/settings/import-export` route was removed; Import now lives at
  `/settings/general/import` and Metronome at `/settings/general/metronome`.

## Scope note

This adds the **setting and its on/off toggle only**. The actual metronome
beat/flash behaviour is not built yet — that would be a separate change. The
toggle just stores a saved "metronome enabled" flag.

## Tests

- Updated `test/screens/settings_screen_test.dart`: top level shows General; new
  flows for General → Import and General → Metronome; route table matches the
  new nesting.
- Added `test/providers/metronome_provider_test.dart`: default off, reads saved
  value, saves true/false.
- Added `test/screens/metronome_settings_screen_test.dart`: switch reflects the
  saved value and flipping it saves the new value.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 229 tests pass.
- `dart format .` — applied.
