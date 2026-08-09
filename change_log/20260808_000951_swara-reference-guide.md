# Change Log: A Swara Reference for songs written in swaras

**Plan Reference:** `plans/20260808_000054_swara-reference-guide.md`

## Why

The **Chord Reference Guide** was offered for a raga song and then showed
confident, wrong information.

`harmoniumShape('Sa')` could not read `Sa` (S is not a note letter A–G), so it
fell back to root `0` and drew **C major**. It did the same for Ma, Pa and Ni —
four identical C major keyboards with four different labels. Two swaras were
worse, because they parsed as real chords: `Ga` drew **G major** and `Dha` drew
**D major**.

A swara is one note, not a chord, and it is named relative to Sa, not to C.

## What changed

A song written in swaras now gets a **Swara Reference**: each swara the song
uses, drawn at its own place on a harmonium keyboard, counted from Sa.

### Where each swara sits (`lib/services/swara_notation_service.dart`)

New `swaraPosition(String token)` → semitones above Sa, `0`–`11`, or `null`.

The count is **relative to Sa, not to C**. `7` means "seven semitones above Sa,
wherever Sa is" — the same relative counting the Swaram block already uses. No
Western pitch is named, so this does not reopen the conversion the project
removed.

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|----|----|
| S | r | R | g | G | m | M | P | d | D | n  | N  |

Reading rules, in order: a Carnatic digit (`R1`, `G3`, `M2`) wins over
everything; a full name is always shuddha; a lowercase single letter is komal;
an uppercase single letter is shuddha. Anything else returns `null` and is
skipped, never guessed.

`isSwaraToken()` was **not** changed. It keeps its loose, case-insensitive
behaviour, so nothing that parses today stopped parsing. `swaraPosition()` is
the new, stricter, position-aware reader.

### The diagram (`lib/widgets/swara_keyboard_diagram.dart` — new)

One octave of harmonium keys with Sa fixed at the leftmost white key. The
swara's key is filled strongly; Sa is filled faintly on every diagram so the
eye has something to count from. Built like `HarmoniumChordDiagram`: a
`CustomPaint` with a private painter, theme colours, and a `Semantics` label
("Swara diagram for Ma") because a painted keyboard is invisible to a screen
reader.

A token it cannot place draws the bare keyboard with nothing lit — never a
wrong note, never a crash (CLAUDE.md hard rule 4).

### The dialog (`lib/widgets/chord_reference_dialog.dart`)

New `swaraMode` flag. When true the title reads **"Swara Reference"**, there is
no `TabBar` and no `DefaultTabController`, and the single view is a grid of
`SwaraKeyboardDiagram`. A guitar fingering means nothing for one note.

The two-tab chord view moved into `_chordBody()` and is unchanged. `_NoChords`
became `_Empty` with a `message`, so the empty state can say "No swaras in this
song" or "No chords in this song".

### The menu item (`lib/screens/song_performance_screen.dart`)

Reads **"Swara Reference"** for a raga song and "Chord Reference Guide"
otherwise. The swaras are sorted by position, low to high, so the reference
reads like a scale (Sa, Ma, Pa) instead of in order of appearance. The icon and
the `enabled` rule are unchanged.

`chord_shape_service.dart` was **not** touched. It stays a Western-chord
service, which is what it is.

## Two bugs caught while writing this

Both were in the first draft of `swaraPosition`, caught before the tests were
written:

1. **`_komalOf(5)` turned a lowercase `m` into Ga.** Ma has no komal form — it
   moves the other way, to tivra. `_komalOf` now lowers only Ri, Ga, Dha and Ni;
   Sa, Ma and Pa stay where they are.
2. A tangled komal line re-tested a match it had already made. Simplified.

## The `M` rule

In strict Hindustani shorthand a capital `M` means *tivra* Ma. Here it means
**shuddha** Ma, because this app's own seeded songs shipped `[M]` meaning the
ordinary Ma and that text is on users' phones — reading it as tivra would
silently change songs people already have.

Tivra Ma is written `M2`, `Ma tivra`, or `M'`. This is written into the
doc comment on `swaraPosition` and covered by two named tests, so it is a
recorded decision rather than an accident.

## Verification

- `flutter analyze` — **No issues found.**
- `flutter test` — **419 tests, all passed** (was 394).
- `dart format lib test` — applied.

New and updated tests:

- `test/services/swara_notation_service_test.dart` — 13 new tests: shuddha
  positions, komal by lowercase, the `M` rule, tivra by three spellings, the
  `komal` suffix, all thirteen Carnatic digits, digits beating the case rule,
  two names agreeing on one key, octave marks, every position 0–11 reachable,
  and `null` for a non-swara.
- `test/widgets/swara_keyboard_diagram_test.dart` — **new.** Label, screen
  reader name, an unplaceable token drawing without an exception, a Carnatic
  numbered swara, and two different swaras painting differently.
- `test/widgets/chord_reference_dialog_test.dart` — swara mode shows one
  keyboard per swara and no tabs, never a `HarmoniumChordDiagram`, and says "No
  swaras in this song" when empty; chord mode is unaffected.
- `test/screens/song_performance_screen_test.dart` — a Western song offers
  "Chord Reference Guide", a raga song offers "Swara Reference", and the
  reference draws its swaras in pitch order.

## Still to check by hand

**Not done: looking at the dialog in the running app.** The tests confirm the
right widgets with the right labels in the right order, but they cannot judge
whether the filled key is easy to see against the Sa anchor at real size, or
whether four keyboards wrap well on a phone. This needs one look on a device.

## Out of scope, as planned

- **Which swaras the raga actually allows.** Showing the full scale of Mishra
  Gara needs a raga → swara table, which is a large data set and a research job.
  This shows only the swaras *this song uses*, which is honest and needs no new
  data.
- **Octave marks.** `S'` and `.P` map to the same position as `S` and `P`. The
  diagram draws one octave, so they are correct as drawn, just not
  distinguished.
