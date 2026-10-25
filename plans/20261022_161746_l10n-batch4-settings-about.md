# Plan: Localization batch 4 — settings and About

**Status:** completed

## The issue

`CLAUDE.md` says every user-visible text must come from `lib/l10n/*.arb`
through `AppLocalizations`. Batches 1–3 did the songbook, setlists, editor and
performance view. This batch does every settings screen and the About screen,
plus the model labels those screens show.

About 125 texts in 10 screen files and 3 model files.

## What changes

The English the user sees stays the same.

### Rules (same as earlier batches)

- Reuse existing keys only where the words and meaning are exactly the
  same, for example `settings`, `about`, `add`, `stageSlower`,
  `stageFaster`, `droneTitle`, `droneStop`, `chordInserterChordHint` and
  `droneCouldNotPlay`.
- New keys are named by screen: `settingsMenu…`, `generalSettings…`,
  `themeSettings…`, `fontSettings…`, `scrollSettings…`, `chordSettings…`,
  `importSettings…`, `metronomeSettings…`, `droneSettings…`, `about…`.
- Names and numbers are placeholders. Every key gets an `@key` description.
- Not moved (allowed literals): route paths, the `1.00x` speed format and
  `%` values, `'Pa'` / `'Ma'` segment values, the `mailto` scheme, and the
  `email` key check.

### Model labels moved to `lib/l10n/l10n_labels.dart`

Same pattern as batch 2 (`PitchTradition.label(l10n)`):

- `ImportDuplicateStrategy.label` and `.description` (8 texts) →
  `label(l10n)` / `description(l10n)` extensions. Used only by
  `import_settings_screen.dart`. The model getters are removed.
- `ChordQuality.displayName` → `label(l10n)`. Used only by the pitch drone
  settings screen. `DroneMode.displayName` is not used anywhere, so it is
  removed.
- `LyricFont`: only the "System default" choice is app text; the other four
  labels are font names (Noto Sans Malayalam, Manjari, …) and stay as they
  are. The font settings screen shows the translated "System default" for
  that one choice.

### The "Test plays: …" line

`pitch_drone_settings_screen.dart` builds "Test plays: Western major chord on
G" by lower-casing the quality name inside the sentence. That cannot be
translated well, so it becomes two whole sentences
(`droneSettingsTestWesternMajor`, `droneSettingsTestWesternMinor`) plus one
for the Classical drone, each with the key as a placeholder.

### What stays as data (not translated)

The About screen shows `app_config.json`: app name, description and the
details list (Author, Email, …). That file is the project's config source by
design (guideline §1), so its values stay as data. Only the screen's own
words move: "About", "Version {version}", "(build {build})", "Build date",
"Open source licenses".

### Texts by file

- **`settings_screen.dart`** (13): title and the six cards (title +
  subtitle).
- **`general_settings_screen.dart`** (11): title and the five cards.
- **`theme_settings_screen.dart`** (4): title, System / Light / Dark theme.
- **`font_settings_screen.dart`** (2 + "System default"): title, the note
  about Malayalam in PDFs.
- **`scroll_settings_screen.dart`** (6): title, "Starting speed", its note,
  Slower / Faster, "Reset to {speed}".
- **`chord_settings_screen.dart`** (9): title, intro, field label and hint,
  Add, "No custom chords yet.", "Remove {chord}", "Removed \"{chord}\".",
  "Could not add that chord. Use at most {max} characters and no repeats."
- **`import_settings_screen.dart`** (2 + 8 model texts): title, the
  question, the four choices and their descriptions.
- **`metronome_settings_screen.dart`** (~16): title, the switches and their
  subtitles, Click volume, "Bar", "Beats in a bar", Accent beat 1, "Test the
  sound" and "Plays one bar at {bpm} BPM…".
- **`pitch_drone_settings_screen.dart`** (~45): title, section titles and
  captions, Pitch naming and its two notes, Your Sa, Drone Interval and its
  two notes, Default key, Default drone mode and notes, Default chord quality
  and notes, Volume, Stage Font Scale, the Try it out buttons, the drone
  notes, the "Test plays" lines, and the error fallback.
- **`about_screen.dart`** (5): as listed above.

## Tests

Tests that pump these screens in a bare `MaterialApp` get the localization
delegates: `settings_screen_test`, `chord_settings_screen_test`,
`font_settings_screen_test`, `import_settings_screen_test`,
`metronome_settings_screen_test`, `about_screen_test`
(`pitch_drone_settings_screen_test` already has them). Their English text
checks stay the same.

- `test/l10n/l10n_labels_test.dart`: every `ImportDuplicateStrategy` has a
  label and a description; both `ChordQuality` values have a label.
- `test/l10n/app_localizations_plural_test.dart`: the "Test plays" lines, the
  chord-length error, and "Version {version} (build {build})".

## Files to change

- `lib/l10n/app_en.arb` (+ regenerated `app_localizations*.dart`)
- `lib/l10n/l10n_labels.dart`
- `lib/screens/settings_screen.dart`, `general_settings_screen.dart`,
  `theme_settings_screen.dart`, `font_settings_screen.dart`,
  `scroll_settings_screen.dart`, `chord_settings_screen.dart`,
  `import_settings_screen.dart`, `metronome_settings_screen.dart`,
  `pitch_drone_settings_screen.dart`, `about_screen.dart`
- `lib/models/import_settings.dart` (remove `label` / `description`)
- `lib/models/pitch_drone_settings.dart` (remove both `displayName`)
- The 6 tests listed above and the 2 `test/l10n/` files

No files in the `docs/guidelines/` submodule are touched. No database, Android
or iOS change.

## Checks after the change

- `flutter gen-l10n`, `dart format .`, `flutter analyze` (zero issues),
  `flutter test` (all pass).
- A search of the 10 screens finds no user-visible string literal left,
  except the allowed ones and the config data noted above.

## Change log

`change_log/<timestamp>_l10n-batch4-settings-about.md` after the work.
