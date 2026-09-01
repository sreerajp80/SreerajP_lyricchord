# Notes that start or stop inside a beat

**Status:** completed

Date: 2026-08-22

---

## The issue

Our `{melody}` format cannot write a note that **starts** part-way through a
beat or **stops** part-way through one. Carnatic phrases very often do both,
because they begin off the beat.

In the seeded sample this affects **5 notes out of 397** (1.3%), which the
importer snapped to the nearest beat — a shift of half a beat each:

| Cycle | Source | What is wrong |
|---|---|---|
| Pallavi 1, second avarta | `, R ,` | `R` starts half a beat late |
| Pallavi 2, second avarta | `nN ,` | `N` starts half a beat late |
| caraNam 3, line 2 | `G r G r` | `G` starts mid-beat |
| caraNam 3, line 2 | `m P ,` | `P` starts mid-beat |
| caraNam 4, line 2 | `G r G r` | `G` starts mid-beat |

The count is small, but the *shape* is common, so every future song imported
from a published page will hit it.

## What already works — and what does not

Reading the code rather than assuming:

**Sustaining across a beat boundary already works.** A whole-beat `,` stretches
the previous sound rather than re-striking it —
`MelodyPlayerService`: *"Stretching the last span rather than adding a new one is
what stops the note being struck again."* Ties are not the problem.

**Two things are missing.**

1. **No silent slot.** Inside a beat, `-` splits it into equal slots
   (`Ga3-Ma1`). There is no way to say a slot is *empty*, so a note cannot stop
   part-way through a beat.
2. **A leading `,` inside a beat is thrown away.** `MelodyParser._beat`:
   *"A comma with nothing before it has nothing to extend, so it is dropped
   rather than guessed at."* So `,-Ri2` collapses to `Ri2` filling the beat, and
   a note cannot start part-way through one.

Both halves of `, R ,` need one of these:

```
what it means:   0.5 silence │ 1.0 Ri2 │ 0.5 silence
beats:           ├──── beat 1 ────┼──── beat 2 ────┤
                 [silent][Ri2 ...]  [... Ri2][silent]
                     ↑                           ↑
              needs a silent slot        needs to stop mid-beat
```

## The fix

### A beat becomes a list of slots

Today a beat holds `List<MelodyNote> notes` plus a parallel `List<int> slots`.
That cannot say "slot 1 is silent" — a silent slot has no note to list.

A slot needs **three** states, not two:

| Slot | Meaning |
|---|---|
| a note | strike it |
| **silence** | nothing sounds |
| **tie** | the previous sound continues |

Silence and tie are different: a tie keeps a note ringing, silence stops it. So
`MelodyNote?` is not enough and a small slot type is added to
`lib/models/melody_beat.dart`.

### Two marks in the text

| Written | Meaning | Example |
|---|---|---|
| `x` | a silent slot | `Ri2-x` — Ri2 for half a beat, then silence |
| `,` **in the first slot** | continue the previous sound | `,-Ri2` — hold for half a beat, then Ri2 |

`x` is chosen because it is not a swara letter, is not already a mark, and reads
clearly as "nothing here". `.` would also be unambiguous to the parser, but it is
the lower-octave prefix (`.Ni3`) and would be easy to misread.

A `,` in the first slot changing meaning is the one behaviour change: today it is
silently dropped. Nothing in the app or the seeded songs writes it, so no
existing song changes — but it is a change and is called out here.

### `, R ,` then writes exactly

```
{melody} ... ,-Ri2  Ri2-x ...
```

## Files to change

| File | Change |
|---|---|
| `lib/models/melody_beat.dart` | A slot type with note / silence / tie. Keep `notes` and `slots` working for everything that already uses them. |
| `lib/services/melody_parser_service.dart` | Read `x` as a silent slot; read a first-slot `,` as a tie instead of dropping it. |
| `lib/services/melody_player_service.dart` | Schedule a silent slot as silence taking its time, and a tie slot by stretching the previous span — the same trick the whole-beat hold already uses. |
| `lib/services/carnatic_notation_import_service.dart` | Stop snapping. Emit the exact slots, so the 5 notes land where the source puts them. |
| `test/services/melody_parser_service_test.dart` | The two new marks, and that old text still reads the same. |
| `test/services/melody_player_service_test.dart` | A silent slot makes silence of the right length; a tie does not re-strike. |
| `test/services/carnatic_notation_import_service_test.dart` | `, R ,` converts exactly, with no snapping. |
| `lib/data/app_database.dart` | Regenerate the sample song's 32 lines so the 5 notes are right. |
| `docs/carnatic_notation.md` | §7 gains the two marks; §8 drops the atomic-beat limit. |

## Scope check — the ripple is small

`beat.notes` has one real consumer: the player's scheduler
(`melody_player_service.dart`). The beat grid draws `beat.text`, the raw written
token, so **the display needs no change at all**. That is what keeps this
contained.

## What this does not fix

* Slots stay **equal divisions of a beat**. A beat split 1/3 + 2/3 still has to
  be written as three slots. Fine for everything seen so far, since Carnatic
  subdivision is binary in practice.
* Gamakas are still marks only — `!` and `~` remain unsounded (phase 3).

## Risks

* **A behaviour change, however small.** A first-slot `,` means something now.
  Nothing writes it today, and the tests will pin that old text reads unchanged.
* **The sample song's melody changes again.** Five notes move by half a beat —
  to where the source actually puts them. The round-trip test keeps the song and
  the importer in step.
* **`x` beside a swara.** `x` is not a swara letter and cannot be confused with
  one, but it is a new character in the format and needs the doc entry.

## Checks after the change

* `flutter analyze` clean, `flutter test` green.
* The importer converts `, R ,` with **no** snapping warning.
* Every one of the sample song's 32 lines still parses at exactly 7 beats.
* On a phone: the 5 changed spots play, and the beat grid still reads clearly
  with an `x` in it.
