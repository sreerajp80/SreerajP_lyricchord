# Melody phase 2 — the keypad (make melodies enterable)

**Status:** completed

Date: 2026-09-01
Slug: `melody-keypad-phase-2`

Implements **phase 2** of
[20260820_212252_melody-line-and-player.md](20260820_212252_melody-line-and-player.md).

---

## 1. The issue

Phase 1 gave the app everything it needs to *read and play* a `{melody}` line.
It gave it nothing to *write* one. Today the only way to add a tune is to type
the raw line into the plain lyrics box:

```
{melody} , , Sa | Ga3 Ma1 | Ri2 ,
```

That means typing spaces, commas, hyphens and bar lines by hand, in the right
order, and counting the beats in your head against the tala. One extra space is
harmless, one missing comma silently shifts every later beat, and nothing tells
you the line is one beat short until you play it and it sounds wrong.

The phase plan already made the call: phase 3 makes tunes that exist sound
better, phase 2 decides whether tunes exist at all. This is the one that matters.

There is a second, smaller problem. `{melody}` lines and the Carnatic paste sheet
both write the same format, but the paste sheet only helps someone who already
has published notation in front of them. Someone working out a tune by ear has
no help at all.

---

## 2. What this adds

A **melody keypad**: a panel where you tap swaras and marks, see the beats draw
themselves as you go, see a running beat count against the song's tala, and then
drop the finished line into the lyrics at the cursor.

- Tap `Ga3` — a beat appears holding Ga3.
- Tap **hold** — a `,` beat is added; the note before it rings on.
- Tap **share** then another swara — the two notes share the last beat
  (`Ga3-Ma1`).
- Tap **bar** — a `|` group divider.
- **Octave up / down**, **slide**, **shake** apply to the note just entered.
- **Silence** writes `x`.
- **Backspace** removes the last thing entered.
- A live line reads **"6 of 8 beats"** and turns green when the line fills the
  tala exactly.
- **Insert** puts `{melody} ...` into the lyrics.

Nothing here invents a new format. Every button writes a token the existing
`MelodyParser` already reads, and the preview is drawn by the existing
`MelodyBeatGrid` from a real parse — so what you see in the keypad is exactly
what the player will sing.

---

## 3. Where the keypad lives, and why

**Decision: a full-height modal bottom sheet**, opened from the editor's
**More options** menu as **Melody keypad**, next to the existing **Paste
Carnatic notation**.

The obvious alternative was an inline bar above the lyrics field, like
`ChordInserterBar`. Rejected, for three reasons:

1. **There is no room.** A usable swara pad is 16 swara buttons plus 8 mark
   buttons. On a phone that is four or five rows. The inline chord bar is one
   row, and it already shares the screen with the meta block and the lyrics.
2. **It would fight the software keyboard.** The lyrics field wants the system
   keyboard up; the keypad wants the space that keyboard occupies.
3. **The preview needs the room too.** The beat grid and the beat count are the
   whole point — they are what stops a wrong-length line being written. A one-row
   bar cannot carry them.

The sheet is also the pattern already used for the Carnatic paste, so the editor
gains no new kind of surface.

### Editing a line that already exists

If the caret sits on a `{melody}` line when the keypad opens, that line is loaded
into the keypad and **Insert** replaces it. Otherwise the keypad starts empty and
**Insert** adds a new line at the caret. This is the only sensible reading of
"open the keypad while my cursor is on a melody line", and it makes fixing a
typed line possible without deleting it first.

---

## 4. The buttons

### Swaras

All sixteen named Carnatic swaras, laid out in pitch order across two rows:

```
S    R1  R2  R3   G1  G2  G3   M1  M2
P    D1  D2  D3   N1  N2  N3
```

**No raga filtering.** The parent plan §3.4 already decided the app does not
carry a raga → swara table, and the song's `{raga: ...}` line is free text. A
keypad that hid `N2` because it guessed the raga wrong would be worse than one
that shows everything. This is unchanged here.

The button label is what gets written, so `Ga3` in, `Ga3` out — the note keeps
the writer's own spelling, which is what `MelodyNote.text` is for.

### Marks

| Button | Writes | Applies to |
|---|---|---|
| **Hold** `,` | a `,` beat | the sound before it, rings one more beat |
| **Bar** `\|` | a `\|` beat | nothing — a group divider, takes no time |
| **Share** `-` | joins the next note into the current beat | the beat being built |
| **Silence** `x` | an `x` slot | stops the sound part-way through a beat |
| **Tie** `,` in slot 1 | a `,` as the first slot of a new beat | lets a note start part-way through a beat |
| **Octave ↑** | `'` on the last note | the last note |
| **Octave ↓** | `.` before the last note | the last note |
| **Slide** `!` | `!` before the last note | the last note |
| **Shake** `~` | `~` after the last note | the last note |
| **Backspace** | removes the last token or mark | — |

Octave, slide and shake are **toggles** on the last note — tapping octave up
twice does not stack to a third octave, it turns the mark off again. Stacking
would produce `S''`, which the parser does not read.

Shake is written even though phase 3 has not sounded it yet. That was already the
rule in phase 1: marks are stored from day one so files written now stay correct
later.

---

## 5. The beat count

The header of the sheet shows the running count:

- With a tala the app knows (`SwaraNotation.talaBeats`):
  **"6 of 8 beats"**, and **"8 of 8 beats — fits Adi"** in the theme's success
  colour when `MelodyLine.fitsTala` is true. A full multiple of the cycle counts
  as fitting, because a melody line often runs two cycles.
- With no tala, or one the app does not know: **"6 beats"** only. It says nothing
  about fit rather than guessing, exactly as `fitsTala` returns `null`.

Bar lines are not counted — `MelodyLine.beatCount` already skips them.

Anything the parser could not read is shown as a plain-English problem line under
the grid, straight from `MelodyLine.problems`. In practice the keypad cannot
produce an unreadable token, but a line *loaded from the text field* can contain
one, and it must not be hidden.

---

## 6. Layers

The keypad is a widget, so the rule is that it must not know the format. The
token-building logic goes in a pure service:

```
MelodyKeypadSheet (widget)
      ↓ calls
MelodyEntry (service — immutable, pure Dart, no Flutter)
      ↓ produces a line, read back by
MelodyParser → MelodyLine → MelodyBeatGrid (widget)
```

`MelodyEntry` holds the tokens entered so far and answers the button taps. It is
immutable — every operation returns a new `MelodyEntry` — which matches the model
rule and makes undo inside the sheet trivial (keep the previous value).

The widget never builds a token string by hand and never parses one. It calls
`MelodyEntry`, then hands `entry.line` to `MelodyParser` for the preview.

---

## 7. Files

### New

| File | What it holds |
|---|---|
| `lib/services/melody_entry_service.dart` | `MelodyEntry`: the token list plus `addNote`, `hold`, `barLine`, `share`, `silence`, `tie`, `toggleOctaveUp/Down`, `toggleSlide`, `toggleShake`, `backspace`, `clear`, and `text` (the line without the `{melody}` prefix). Pure logic, no Flutter import. |
| `lib/widgets/melody_keypad_sheet.dart` | `MelodyKeypadSheet`: the sheet. Takes the tala and an optional starting line, returns the finished `{melody}` line or `null`. |
| `test/services/melody_entry_service_test.dart` | Token building, every toggle on and off again, backspace down to empty, share-beat, and a round trip: every produced line parses with no problems. |
| `test/widgets/melody_keypad_sheet_test.dart` | Tapping swaras draws beats, the beat count text, the fits-tala state, insert returns the line, cancel returns null. |

### Modified

| File | Change |
|---|---|
| `lib/screens/song_editor_screen.dart` | New **Melody keypad** menu item; find the `{melody}` line under the caret; open the sheet; insert or replace the line. The insert path reuses the block-insert code already written for the Carnatic sheet — that code moves to a small private helper so both callers share it. |
| `test/screens/song_editor_screen_test.dart` | The menu item opens the sheet; inserting adds the line at the caret; opening on an existing melody line replaces it rather than adding a second one. |
| `docs/features.md` | Describe the keypad under the melody feature. |
| `docs/carnatic_notation.md` | §8 "Built" gains a line: melody lines can be entered from a keypad, not only typed. |
| `plans/20260820_212252_melody-line-and-player.md` | Progress table: phase 2 → **done**, with a link to the new change log. |

Nothing in `lib/data/`, no schema change, no new package. The stored format does
not change at all — this only makes the existing format easier to write.

---

## 8. Risks

1. **Sheet height on a small phone.** Sixteen swara buttons plus eight marks plus
   the preview may not fit a short screen in landscape. Handled by making the
   button block itself scroll, with the preview and beat count pinned at the top
   where they stay visible.
2. **Replacing the wrong line.** The caret line is found by counting newlines
   before the selection offset. An invalid selection (the field never focused)
   must fall back to "no line", i.e. insert rather than replace. Covered by a
   test.
3. **Losing work by tapping outside the sheet.** The sheet asks before closing
   when something has been entered, the same way the editor asks before leaving a
   dirty draft.
4. **Toggle marks on a beat that has no note** (the last token is `,` or `|`).
   The buttons are disabled in that state rather than writing a mark with nothing
   to attach it to.

---

## 9. Out of scope

- **Sounding the shake, and true-ratio tuning.** That is phase 3, unchanged.
- **A raga → allowed-swara table.** Decided against in the parent plan §3.4.
- **Playing back from inside the keypad.** Tempting, but the player is driven by
  the song's tonic and BPM, and a draft line in a sheet has neither until the
  song is saved. The line plays from the sheet view straight after inserting.
- **Editing lyrics from the keypad.** It writes one melody line and nothing else.

---

## 10. Definition of done

- A tune can be entered end to end with no typing: open the keypad, tap swaras
  and marks, watch the beat count reach the tala, insert.
- Opening the keypad with the caret on an existing `{melody}` line loads that
  line and replaces it on insert.
- Every line the keypad can produce parses with `problems` empty.
- `flutter analyze` clean, `flutter test` green, `dart format .` run.
- Change log written to `change_log/`, and the parent plan's progress table
  updated.
