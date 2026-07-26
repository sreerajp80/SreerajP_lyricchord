# Change log: Add a Help section in Settings

**Implements plan:** `plans/20260724_071132_settings-help-section.md`

## What changed

Added an in-app Help section reachable from Settings. Tapping "Help" opens a hub
page with five topic cards — Setlists, Metronome, Select Songs, Export, Import —
and each card opens a detailed help page written for this app.

## Files added

- `lib/screens/help/help_content.dart`
  - Immutable data models `HelpTopic` and `HelpSection`.
  - `const helpTopics` list holding the five topics and their written content.
  - `helpTopicById(id)` lookup that returns null for unknown ids (no crash).
- `lib/screens/help/help_screen.dart`
  - `HelpScreen` — the Help hub. Builds one card per topic from `helpTopics`,
    each opening `/settings/help/<id>`. Uses the same Card + ListTile look as the
    Settings screen.
- `lib/screens/help/help_detail_screen.dart`
  - `HelpDetailScreen(topicId)` — renders a topic's intro plus its sections as
    headings with bullet points. Shows a safe "Help topic not found" message if
    the id is unknown.

## Files edited

- `lib/screens/settings_screen.dart`
  - Added a "Help" card (icon `help_outline`) above "About", opening
    `/settings/help`.
- `lib/core/router/app_router.dart`
  - Imported the two new screens.
  - Added nested routes under `/settings`: `help` -> `HelpScreen`, and
    `help/:topicId` -> `HelpDetailScreen`.
- `test/screens/settings_screen_test.dart`
  - Registered the new help routes in the test router.
  - Updated the card-count test from five to six cards and added a check for the
    "Help" card.
  - Added two tests: the Help card opens the hub with all five topic cards, and a
    topic card opens its detail page.

## Design notes

- Help is static, read-only UI: no new state, services, database, packages, or
  network. This keeps to the app's "fully offline" and "no logic in widgets"
  rules. The help text lives as plain immutable data, not logic.
- Content matches real app behaviour, taken from the setlist, metronome,
  song-list (long-press select + export/delete), import/export, and performance
  (PDF export) code.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 255 tests pass (including the updated settings tests).
