# Change log — Help section: full topic coverage and fixes

Implements [plans/20260904_151158_help-topics-coverage.md](../plans/20260904_151158_help-topics-coverage.md).

## Files changed

- `lib/screens/help/help_content.dart` — six new topics, fixes to five existing ones, and a new hub order.
- `test/screens/help_content_test.dart` — **new.** Checks the shape of the topic list.
- `test/screens/settings_screen_test.dart` — the Help hub test now checks that every topic has a card.
- `docs/features.md` — the two lines that listed the Help topics were out of date.

No screen code changed. The Help hub and every detail page build themselves from `helpTopics`, so a new topic needs nothing else.

## Errors fixed in the topics that already existed

1. **Pitch Pipe & Shruti Box.** The section "5-Tier Stage Font Scaling" said to "tap the font scale icon in Stage HUD". There is no such icon — the size is picked from five per-cent chips in the pitch sheet and in Settings. It also said the scale is for the stage, but it multiplies the sheet text size everywhere (`song_performance_screen.dart`). Replaced with a plain-English section, "Text size for the stage".
2. **Auto-scroll.** "The app uses common 4/4 time, so one bar is 4 beats" is only true for a song with no tala; `AutoScrollSettings.beatsPerMeasure` comes from the song's `{tala}`. Now says both, with misra chapu (7 beats) as the example, and adds the 1–512 bar range.
3. **Export.** There is no "Export as PDF" menu item — the item is "Export", which then asks ChordPro or PDF, and it opens the file saver, not the share sheet. Rewritten, with a new section on what a PDF looks like (content-fit page width, 9 pt auto-fit floor, chosen lyric font) and a new "Share instead of save" section.
4. **Import.** Added the preview step, where the duplicate setting lives, the file-intent route, and a pointer to AirQR.
5. **Full screen.** Added "The buttons in the bar" (Exit, Lock, Quiet, M / T, Play, pitch, stepper), plus a section each for Stage Lock and Stage Quiet Mode, which were not documented at all.
6. **Melody Lines.** Added the Melody keypad and a pointer to pasting published notation, both of which live in the editor's menu.

## New topics

| Id | Title | Covers |
|----|-------|--------|
| `songbook` | Your songbook | Search, Starred and the counts, the two tabs, the + button, copy, delete, tablet split view |
| `editor` | Write a song | `[C]word` brackets, the key-aware chord bar, custom chords, the metadata fields, undo/redo, Save as copy, the discard guard |
| `transpose` | Transpose & chord shapes | The Performance controls sheet, ±11 semitones, Reset, slash chords, Show chords, the Chord Reference Guide and Swara Reference |
| `indian-songs` | Carnatic & Hindustani songs | The notation picker, Raga and Tala, the tala note, `{tonic:}`, `{tala:}`, `{sruti: madhyama}`, Paste Carnatic notation |
| `airqr` | AirQR — songs screen to screen | Sending one song or the whole book, receiving by camera or from a photo, the 5–25 FPS slider, the repair frames |
| `appearance` | Themes, fonts & text size | System/Light/Dark, the five lyric fonts and their previews, pinch zoom (10–32), the five stage sizes |

## Hub order

Re-ordered so a new user meets the basics first: Your songbook, Write a song, Setlists, Transpose & chord shapes, Auto-scroll, Full screen, Metronome, Pitch Pipe & Shruti Box, Melody Lines, Carnatic & Hindustani songs, Select Songs, Import, Export, AirQR, Themes/fonts/text size.

No existing topic id changed, so a saved `/settings/help/<id>` link still works.

## Checks

- `flutter analyze` — no issues.
- `flutter test` — 901 tests pass.
- `dart format .` run.

Every new line was checked against the code before it was written. Two claims were corrected while writing:

- Stage Lock does not stop the sheet being dragged — it switches off the tap controls, hides the bar, and shows a "Stage Locked" chip. The help says that.
- On a phone with no screen lock set up, unlocking does not fail — it simply unlocks (`stage_mode_provider.dart`). The help says that too.
