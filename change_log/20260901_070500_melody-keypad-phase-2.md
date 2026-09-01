# Melody phase 2 — the keypad

Date: 2026-09-01
Implements [../plans/20260901_064116_melody-keypad-phase-2.md](../plans/20260901_064116_melody-keypad-phase-2.md),
which is phase 2 of
[../plans/20260820_212252_melody-line-and-player.md](../plans/20260820_212252_melody-line-and-player.md).

---

## What changed

A melody line no longer has to be typed by hand. The song editor's **More
options** menu has a new **Melody keypad**: a bottom sheet where swaras and
marks are tapped, the beats draw themselves, and a running count checks the
line against the song's tala.

## New files

- **`lib/services/melody_entry_service.dart`** — `MelodyEntry`, the pure logic
  behind the buttons. It holds the tokens entered so far and answers `addNote`,
  `hold`, `barLine`, `share`, `tie`, `silence`, `toggle`, `backspace` and
  `clear`. Immutable: every operation returns a new value, which is what makes
  the keypad's state handling trivial. Also `MelodyMark`, the four marks that
  sit on the last note (octave up, octave down, slide, shake), all of them
  toggles — tapping twice takes the mark off rather than stacking a second one,
  because `S''` is not something the parser reads.

  Marks are written in the order the parser reads them: `!` then `.` then the
  swara then `'` then `~`. The two octave marks are exclusive.

- **`lib/widgets/melody_keypad_sheet.dart`** — `MelodyKeypadSheet`. All sixteen
  swaras in pitch order, the five beat marks, the four note marks, backspace and
  clear. Above the buttons, pinned so they never scroll away: the beat count and
  a live preview drawn by the existing `MelodyBeatGrid` **from a real parse** of
  what has been entered — so the preview cannot drift from what the player will
  sing. Cancel asks before discarding tapped work.

- **`test/services/melody_entry_service_test.dart`** — 29 tests: token building,
  every mark on and off again, backspace down to empty, reading an existing line
  back in, and a sweep proving every one of the sixteen swaras with each of the
  four marks parses with no problems and counts as exactly one beat.

- **`test/widgets/melody_keypad_sheet_test.dart`** — 14 tests: the grid appears,
  the beat count with and without a tala, the fits-tala state, bar lines adding
  no beat, Insert returning the finished line, loading an existing line, the
  mark buttons being dead with no note to mark, and the discard prompt.

## Changed files

- **`lib/screens/song_editor_screen.dart`** — the new menu item and
  `_openMelodyKeypad`. With the caret already on a `{melody}` line
  (`_melodyLineAtCaret`), that line is loaded into the keypad and **replaced**
  on insert; anywhere else a new line is added at the caret. The block-insert
  code the Carnatic paste already had is now the shared `_insertLines` helper.

  Unlike the notation paste, a missing tala does **not** block the keypad. The
  tala is only used to count beats, and a tune can be tapped out without one.

- **`test/screens/song_editor_screen_test.dart`** — five tests for the menu
  item, opening without a tala, inserting at the caret, replacing the melody
  line under the caret, and adding a new line when the caret is on lyrics.

- **`docs/features.md`** — §2.8 is now "Melody Lines (Phases 1-2)" and describes
  the keypad.

- **`docs/carnatic_notation.md`** — §8 "Built" records that melody lines can be
  entered from a keypad, not only typed.

- **`plans/20260820_212252_melody-line-and-player.md`** — progress table: phase
  2 is done.

## Decisions worth keeping

- **A sheet, not an inline bar.** Sixteen swaras plus eight marks is four or
  five rows; it would not fit beside the lyrics, it would fight the software
  keyboard, and the preview and beat count — the parts that stop a wrong-length
  line being written — need the room.
- **No raga filtering.** All sixteen swaras are always offered. The app keeps no
  raga → swara table (melody plan §3.4), so hiding a swara would mean guessing,
  and a wrong guess is worse than a longer pad.
- **The shake is still written even though it is silent.** Phase 1's rule holds:
  marks are stored from day one so files written now stay correct once phase 3
  sounds them.

## What was not built

Phase 3 is untouched: the shake is still not sounded, and the tone table still
uses equal steps rather than true ratios against the drone.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 801 tests pass.
- `dart format .` — run.
