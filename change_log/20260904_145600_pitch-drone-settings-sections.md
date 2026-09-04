# Pitch Pipe & Shruti Box — settings grouped into clear sections

Implements [plans/20260904_144701_pitch-drone-settings-sections.md](../plans/20260904_144701_pitch-drone-settings-sections.md).

## Why

All nine settings sat in one flat list split only by dividers. Nothing said
which setting affected which. Changing **Pitch naming** only re-labelled the
**Your Sa** row, so it looked as if the screen was broken — the user asked why
**Default drone mode** did not change too.

The real relationships were hidden, not absent:

- Pitch naming decides how a song with no raga or tala is treated.
- An Indian song always plays the Classical shruti drone, on the singer's Sa.
  It ignores `droneMode` and `selectedKey`.
- A Western song uses `droneMode`, `chordQuality`, and the song key or the
  default key.
- Volume and stage font scale apply to everything.

## What changed

### `lib/screens/pitch_drone_settings_screen.dart` (rewritten body)

The list is now five `Card` sections. Each has a heading and a one-line caption
saying what it affects:

1. **Pitch naming** — the naming buttons, plus a line that changes with the
   choice: "Songs with no raga or tala use the Indian songs settings below."
   (or "the Western songs settings below").
2. **Indian songs (Carnatic / Hindustani)** — Your Sa, Drone Interval.
3. **Western songs** — Default key, Default drone mode, Default chord quality.
4. **Applies to everything** — Volume, Stage Font Scale.
5. **Try it out** — the test buttons and the explaining lines.

Whichever of sections 2 and 3 the current naming will actually use is drawn with
a primary-colour border, so the link between naming and the rest is visible at a
glance. The other section stays fully readable and editable.

Other changes inside that rewrite:

- **Drone Interval is always shown.** It used to disappear whenever the drone
  mode was Western. An Indian song ignores the drone mode and always uses this
  interval, so hiding it was wrong.
- **Default chord quality is always shown.** It used to swap places with the
  interval row. Now it stays put and is greyed out while the drone mode is
  Classical, with the subtitle "Used only when the drone mode above is Western".
  This show/hide swap was a large part of why the screen felt unresponsive.
- **The test buttons now follow the naming choice** (a behaviour change,
  approved in the plan). They previously always used the Western default key and
  drone mode, even under Carnatic naming, which disagreed with the performance
  sheet. They now pass an explicit key, mode, and quality:
  - Carnatic or Hindustani → the Sa, in Classical mode.
  - Western → the default key, in the saved drone mode and quality.
- A new "Test plays: …" line above the buttons names exactly what will sound,
  e.g. "Test plays: Classical drone on 5 kattai + Pa".
- "Default key (Western songs)" is now just "Default key" — the section heading
  already says Western.
- Two new private widgets in the same file: `_SettingsSection` (card, heading,
  caption, optional highlight border) and `_SectionNote` (small italic line).

### `test/screens/pitch_drone_settings_screen_test.dart` (new, 9 tests)

- All five section headings render.
- Carnatic naming shows the Indian-songs pointer line; Western naming shows the
  Western one.
- With Carnatic naming, the "Test plays" line names the Sa and the Classical
  drone even when the saved drone mode is Western.
- Tapping the cue button under Carnatic naming plays the Sa as a plain cue, not
  a chord on the Western default key.
- Tapping it under Western naming plays a chord on the Western default key.
- Drone Interval is visible in both drone modes.
- Chord quality is present but disabled under Classical mode, and enabled under
  Western mode.

## Not changed

- Pitch naming still does **not** force `droneMode` in Settings. Forcing it would
  throw away the user's Western default whenever they glanced at a Carnatic song.
  The sections make the relationship visible instead.
- No changes to the provider, model, audio service, or saved preference keys.

## Checks

- `flutter analyze` — clean.
- `flutter test` — 895 tests pass (9 of them new).
- `dart format` — applied to both changed files.
