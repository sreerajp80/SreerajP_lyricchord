# Plan: Add a Help section in Settings

**Status:** completed

## What the user wants

Add a "Help" entry to the Settings screen. Tapping it opens a Help hub page that
shows five cards:

- Setlists
- Metronome
- Select Songs
- Export
- Import

Tapping each card opens a detailed help page written for this app.

## The issue / gap

Right now the Settings screen has five cards (General, Themes, Chords, Fonts,
About) and no in-app help. New users have no guidance on how setlists, the
metronome, multi-select, export, and import work.

## Design (keeps to project architecture rules)

- **No new state, no services, no DB, no network.** Help is static, read-only UI.
  This fits the "fully offline" and "no business logic in widgets" rules — the
  help content is plain text data, not logic.
- **Data-driven content.** Add one file `lib/screens/help/help_content.dart`
  holding the help text as immutable Dart data (a `HelpTopic` model with a title,
  an intro, and a list of titled sections with bullet steps). This keeps the
  detail screen generic and avoids five near-duplicate screens.
- **Two thin screens** that mirror the existing card style
  (`_SettingsCard` / `_GeneralCard` pattern):
  - `HelpScreen` — the hub with the five cards.
  - `HelpDetailScreen` — renders one `HelpTopic` passed by id.
- **Routing** follows the existing nested pattern under `/settings`.

## Files to change / add

1. **Add** `lib/screens/help/help_content.dart`
   - `HelpTopic` immutable model: `id`, `title`, `icon`, `intro`,
     `List<HelpSection>`.
   - `HelpSection` immutable model: `heading`, `List<String> points`.
   - A `const` map/list `helpTopics` with the five topics and their written
     content (see "Help content" below).
   - A lookup helper `HelpTopic? helpTopicById(String id)`.

2. **Add** `lib/screens/help/help_screen.dart`
   - `HelpScreen` (StatelessWidget). AppBar title "Help". A `ListView` of five
     cards built from `helpTopics`, each `onTap` -> `context.push('/settings/help/<id>')`.
   - Reuses the same Card + ListTile look as `SettingsScreen`.

3. **Add** `lib/screens/help/help_detail_screen.dart`
   - `HelpDetailScreen({required String topicId})`.
   - Looks up the topic; if missing, shows a safe "Help topic not found" message
     (never crash — matches Hard rule 4 spirit).
   - Renders intro paragraph, then each section as a heading + bullet list.

4. **Edit** `lib/screens/settings_screen.dart`
   - Add a new `_SettingsCard` "Help" (icon `Icons.help_outline`, subtitle
     "How to use setlists, metronome, export and more") that opens
     `/settings/help`. Place it above "About".

5. **Edit** `lib/core/router/app_router.dart`
   - Import the two new screens.
   - Add nested route under `/settings`:
     - `help` -> `HelpScreen`
       - `:topicId` -> `HelpDetailScreen(topicId: ...)`

No generated files are touched. No new packages.

## Help content (plain English, matched to real app behaviour)

**Setlists** — group songs for a gig or rehearsal.
- Open Setlists from the "Setlists" tab on the home screen.
- Tap "New Setlist", give it a name and an optional description.
- Inside a setlist tap "Add Songs" to pick songs from your library.
- Drag the handle to reorder; tap the red minus to remove a song (the song stays
  in your library).
- Tap "Perform Setlist" (or a song) to play through the list in order.
- Deleting a setlist never deletes the songs in it.

**Metronome** — keep the beat at the song's tempo.
- Turn it on in Settings > General > Metronome.
- "Flash" blinks the screen on every beat (good when the sound is muted).
- "Click" plays a tick on every beat.
- The beat speed comes from each song's BPM, set in the song editor.
- Flash and Click are greyed out until the metronome is enabled.

**Select Songs** — act on several songs at once.
- On the Songs list, long-press any song to start selection.
- Tap more songs to add them; the top bar shows how many are selected.
- Use "Select all" / "Deselect all" in the top bar.
- With songs selected you can Export them (ChordPro) or Delete them.
- Tap the X (top-left) to leave selection mode.

**Export** — save your songs out of the app.
- Export all songs: Settings > General > Import, then "Export all songs
  (ChordPro)". It saves one ChordPro file of your whole songbook.
- Export some songs: select songs on the Songs list (long-press), then tap the
  export icon in the top bar.
- Export one song as PDF: open a song, use the menu > "Export as PDF". The PDF
  keeps the current transpose and font, and opens the system share sheet.
- Everything is offline; files are saved with the system file picker / share
  sheet.

**Import** — bring songs into the app.
- Go to Settings > General > Import, tap "Import ChordPro file(s)".
- Pick one or more `.cho`, `.pro`, or text files.
- Each file can hold one or many songs; all are added to your library.
- Importing one song opens it; importing many shows a count.
- Bad or unreadable files are skipped safely and never break the app.

## Testing

- `flutter analyze` must be clean.
- `flutter test` must still pass (no logic added, but run to be safe).
- Manual: Settings > Help shows five cards; each opens its detail page; back
  returns correctly.
- These are pure static widgets; a light widget smoke test can be added if
  wanted, but the testing rules target services/DAOs/repositories, so no new
  required-coverage area is introduced.

## Out of scope

- No changes to setlist/metronome/import/export behaviour — help only.
- No new packages, permissions, or network use.
