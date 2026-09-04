# Pitch Pipe & Shruti Box — group settings into clear sections

**Status:** completed

## The issue

On the **Pitch Pipe & Shruti Box** screen all nine settings sit in one flat list,
separated only by thin dividers. Nothing on screen says which setting affects
which. The user changed **Pitch naming** (Western / Carnatic / Hindustani), saw
only the **Your Sa** row re-label itself, and reasonably asked why **Default
drone mode** did not change too.

The truth is more interesting than "they are unrelated", and the screen hides it:

- `pitchNaming` sets the labels **and** decides, for a song that names no raga or
  tala, whether the song is treated as Indian or Western
  (`PitchNamingService.detect`, used in [pitch_drone_controls.dart:76-80](../lib/widgets/pitch_drone_controls.dart#L76-L80)).
- For an **Indian** song the drone is always the Classical shruti drone and it
  sits on **your Sa** — `settings.droneMode` and `settings.selectedKey` are
  ignored ([pitch_drone_controls.dart:84-121](../lib/widgets/pitch_drone_controls.dart#L84-L121)).
- For a **Western** song the drone uses `droneMode`, `chordQuality`, and the song
  key or `selectedKey`.
- `volume` and `fontScaleIndex` apply to everything.

So `Default drone mode` really is a Western-songs setting, and `Your Sa` and
`Drone interval` really are Indian-songs settings. The screen just never says so.

## Files to change

| File | Change |
|------|--------|
| `lib/screens/pitch_drone_settings_screen.dart` | Rewrite the body as five labelled sections; add a private `_SettingsSection` widget |
| `test/screens/pitch_drone_settings_screen_test.dart` | **New** — widget tests for the section headings and the conditional rows |

No provider, model, or service changes. No behaviour change to audio.

## The plan

### 1. Five sections, each a `Card` with a heading and a one-line "what this affects" caption

**Section 1 — Pitch naming** *(caption: "Sets how pitches are named, and how a
song is treated when it names no raga or tala.")*
- Pitch naming segmented button (unchanged)
- A short line under it that changes with the choice, so the link is visible:
  - Western → "Songs with no raga or tala use the Western songs settings below."
  - Carnatic / Hindustani → "Songs with no raga or tala use the Indian songs settings below."

**Section 2 — Indian songs (Carnatic / Hindustani)** *(caption: "Used for songs
with a raga or tala. These always play the Classical shruti drone.")*
- Your Sa (Shruti)
- Drone Interval (Pa / Ma) — **now always visible**, not hidden behind
  `droneMode == classical`, because it is always used for Indian songs

**Section 3 — Western songs** *(caption: "Used for songs with no raga or tala
when naming is Western.")*
- Default key (Western songs)
- Default drone mode (Classical / Western)
- Default chord quality — **now always visible**, with a subtitle that says it is
  used only while the drone mode above is Western. When drone mode is Classical
  it stays on screen but is disabled (greyed), so the user can see it exists and
  see why it is not in play. This replaces the current show/hide, which is what
  made the screen feel like it was "not changing".

**Section 4 — Applies to everything** *(caption: "These affect both traditions.")*
- Volume
- Stage Font Scale

**Section 5 — Try it out**
- Test Cue / Test Drone buttons
- The existing explanation line
- Plus a line naming exactly what the test will play, e.g.
  "Test plays: Western chord drone on C" or "Test plays: Classical drone on Sa
  (1 kattai) + Pa", so the buttons stop feeling disconnected from the settings.

### 2. Make the test buttons follow the naming choice

Today `playPitchCue()` and `toggleDrone()` with no arguments always use
`selectedKey` and `droneMode`, even when naming is Carnatic. That does **not**
match what the performance sheet does, and it is part of why the screen feels
inconsistent.

The screen will pass explicit arguments instead:
- naming is Carnatic or Hindustani → `key: saKey`, `mode: DroneMode.classical`
- naming is Western → `key: selectedKey`, `mode: droneMode`, `quality: chordQuality`

This is a small behaviour change, and it makes the test buttons agree with the
performance sheet and with the new "Test plays: …" line.

### 3. The `_SettingsSection` helper

A private widget in the same file: `Card` → `Column` → heading `Text`
(`titleSmall`, primary colour) + caption `Text` (`bodySmall`, muted) + the
children. Matches the `Card` look already used on the General settings screen.

### 4. What is *not* changed

- Pitch naming still does **not** force `droneMode` in settings. Forcing it would
  throw away the user's Western default whenever they glance at a Carnatic song.
  The sections make the relationship clear instead of hiding it behind a
  surprise state change.
- No changes to the provider, the audio service, or saved preference keys.

## Tests

New `test/screens/pitch_drone_settings_screen_test.dart`:
1. All five section headings render.
2. With naming = Carnatic, the "Indian songs" note is shown, and the
   "Test plays" line names the Sa and the Classical drone.
3. With naming = Western and drone mode = Classical, the chord-quality row is
   present but disabled.
4. Changing drone mode to Western enables the chord-quality row.
5. Drone Interval is visible in both drone modes (the old screen hid it).

Then `flutter analyze` (must be clean), `flutter test`, and `dart format .`.

## Change log

On completion, write `change_log/<timestamp>_pitch-drone-settings-sections.md`
referring back to this plan.
