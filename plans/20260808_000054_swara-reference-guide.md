# Plan: A Swara Reference for songs written in swaras

**Status:** completed

## The issue

The overflow menu's **Chord Reference Guide** is offered for every song that
has markers, including a song written in swaras. It then shows confident,
wrong information.

`_OverflowMenu._chordReferenceItem()` enables the item when
`chordsUsed(...)` is not empty. For a raga song that list is the swaras —
`['Sa', 'Ga', 'Pa', 'Ni']` — so the item is enabled and the dialog opens.

Both tabs then mislead:

| Tab | What it does with `Sa` | What the user sees |
|-----|------------------------|--------------------|
| Harmonium | `_parse('Sa')` fails (S is not A–G), so `harmoniumShape()` falls back to root `0` | **C major**, and the same C major again for Ma, Pa and Ni — four identical keyboards with four different labels |
| Guitar | `guitarShape('Sa')` returns `null` | "diagram not available" |

Two swaras are worse, because they parse as real chords:

| Swara | Parsed as | Drawn as |
|-------|-----------|----------|
| `Ga` | root `G`, quality `a` (unknown → major) | **G major** |
| `Dha` | root `D`, quality `ha` (unknown → major) | **D major** |

None of this is true. A swara is one note, not a chord, and it is named
relative to Sa, not to C.

## The fix, in one line

A song written in swaras gets a **Swara Reference** instead: each swara the
song uses, drawn at its own position on a harmonium keyboard, counted from Sa.
No chords, no Western note names, one tab.

---

## Files to change

### Source

| File | Change |
|------|--------|
| `lib/services/swara_notation_service.dart` | New `swaraPosition(String token)` → semitones above Sa (0–11), or `null`. Vocabulary lives here, not in a widget |
| `lib/widgets/swara_keyboard_diagram.dart` | **New.** Draws one octave of harmonium keys with Sa fixed at the left and one swara lit |
| `lib/widgets/chord_reference_dialog.dart` | A `swaraMode` flag: title becomes "Swara Reference", the TabBar disappears, and the single view is a grid of `SwaraKeyboardDiagram` |
| `lib/screens/song_performance_screen.dart` | The menu item reads "Swara Reference" for a raga song; it passes the flag and sorts the swaras low to high |

`chord_shape_service.dart` is **not** touched. It stays a Western-chord
service, which is what it is.

### Tests

| File | Change |
|------|--------|
| `test/services/swara_notation_service_test.dart` | `swaraPosition` for every name, short form, komal/tivra and Carnatic digit; `null` for a non-swara |
| `test/widgets/swara_keyboard_diagram_test.dart` | **New.** The label shows, the diagram is named for a screen reader, an unreadable token does not crash |
| `test/widgets/chord_reference_dialog_test.dart` | Swara mode shows one view and no tabs; chord mode still shows both tabs |
| `test/screens/song_performance_screen_test.dart` | A raga song's menu item reads "Swara Reference"; a Western song's still reads "Chord Reference Guide" |

---

## Step 1 — where each swara sits

Twelve positions in an octave, counted in semitones above Sa. Sa and Pa are
fixed; the other five each have two forms.

| Position | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hindustani | S | r | R | g | G | m | M | P | d | D | n | N |
| Carnatic | S | R1 | R2 | R3/G2 | G3 | M1 | M2 | P | D1 | D2/N1 | D3/N2 | N3 |

Note this is **relative**, not absolute. Position 7 means "seven semitones
above Sa, wherever Sa is". Nothing here names a Western pitch, so it does not
reopen the conversion the project removed — it is the same relative counting
the Swaram block already uses.

### How a written token is read

This is the part that needs a stated rule, because the common Hindustani
shorthand and what this app already shipped disagree.

1. **A full name is always shuddha (natural).** `Sa` `Ri`/`Re` `Ga` `Ma` `Pa`
   `Dha` `Ni` → positions 0, 2, 4, 5, 7, 9, 11.
2. **A lowercase single letter is komal.** `r` `g` `d` `n` → 1, 3, 8, 10.
3. **An uppercase single letter is shuddha.** `R` `G` `D` `N` → 2, 4, 9, 11.
4. **A Carnatic digit wins over both.** `R1` `R2` `R3` `G1`…`N3`, `M1`, `M2`
   read straight from the table above.
5. **Anything else returns `null`** and is skipped, never guessed.

**The one deliberate deviation:** in strict Hindustani shorthand a capital `M`
means *tivra* Ma. Here `M` means **shuddha** Ma, because this app's own seeded
songs shipped `[M]` meaning shuddha and users have that text on their phones.
Reading it as tivra now would silently change songs people already have.
Tivra Ma is written `M2`, or `Ma tivra`, or `M'`.

`isSwaraToken()` keeps its current loose, case-insensitive behaviour, so
nothing that parses today stops parsing. `swaraPosition()` is the stricter,
position-aware reader and is new.

`_stripMarks()` currently deletes digits, which would destroy `R1` before it
could be read. `swaraPosition()` must read the digit **before** stripping.
`isSwaraToken()` is left as it is.

## Step 2 — the diagram

`SwaraKeyboardDiagram({required String swara, double width = 132})`.

One octave of harmonium keys — 7 white, 5 black — with **Sa always at the
leftmost white key**. The swara's position is filled in the highlight colour;
Sa is marked more faintly on every diagram so the eye has an anchor. The swara
name prints underneath.

It follows `HarmoniumChordDiagram`: a `CustomPaint` with a private painter,
colours from the theme, and a `Semantics` label ("Swara diagram for Ma") since
a painted keyboard is invisible to a screen reader.

An unreadable token draws the empty keyboard with the label and nothing lit —
never a wrong note, and never a crash (CLAUDE.md hard rule 4).

## Step 3 — the dialog

`showChordReferenceDialog(context, chords: …, swaraMode: false)`.

When `swaraMode` is true:
- the title reads **"Swara Reference"**;
- there is no `TabBar` and no `DefaultTabController` — a guitar fingering means
  nothing for a swara;
- the single view is the same `_DiagramGrid`, building `SwaraKeyboardDiagram`.

When false, everything behaves exactly as it does now.

The empty case reuses `_NoChords` with wording that suits the mode ("No swaras
in this song").

## Step 4 — the menu item

In `_chordReferenceItem()`:

```dart
final indian = song != null && _parser.parseSheet(song.lyrics).isIndianNotation;
```

- Title: `indian ? 'Swara Reference' : 'Chord Reference Guide'`.
- Icon: `Icons.piano_outlined` either way — a harmonium is what both draw.
- The swaras are sorted by position, low to high, so the reference reads like a
  scale (Sa, Ga, Pa, Ni) instead of in order of appearance.
- `enabled` stays as it is: not empty.

## Out of scope

- **Which swaras the raga actually allows.** Showing the full scale of Mishra
  Gara means a raga → swara table, which is a large data set and a research job.
  This shows only the swaras *this song uses*, which is honest and needs no new
  data.
- **Octave marks.** `S'` (upper octave) and `.P` (lower) map to the same
  position as `S` and `P`. The diagram draws one octave, so they are correct as
  drawn, just not distinguished.
- **`chord_shape_service.dart`.** Untouched.

## Risk

The rule for reading `M` is a judgement call, written down in step 1. If it is
wrong for how you write your sheets, say so now — it is one line in a table,
but it is much cheaper to change before the tests are written around it.

## Verification

- `flutter analyze` — clean.
- `flutter test` — all pass.
- `dart format lib test`.
- By eye: open "Raghupati Raghava Raja Ram", check the menu says "Swara
  Reference", and confirm Sa, Pa, Ma and Ni light **four different keys**, in
  that order of pitch. Open "Amazing Grace" and confirm the chord guide is
  unchanged, with both tabs.
