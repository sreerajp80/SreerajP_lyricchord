# Krishna Nee Begane Baaro — Anupallavi split, and the melody lines removed

Date: 2026-08-21

Partly implements
[plans/20260821_194500_krishna-madhyama-sruti-notation.md](../plans/20260821_194500_krishna-madhyama-sruti-notation.md).
That plan is **not finished** — see "What is still open".

---

## Why

The user established that Yamunakalyani is traditionally sung in **madhyama
sruti**: the tambura's Pa string drops to shuddha madhyamam (M1), and that note
is taken as the base Sa. So the krithi is notated **starting on `S`**, not on
`P`.

The melody lines this song shipped with (`Pa , Ma2 | Ga3 Ri2 | Sa ,` and the
rest) were written on an absolute scale. They are what you would play reading
one line on a keyboard without changing the sruti — internally consistent, and
fine to the ear in isolation, which is why an earlier check passed them. They
are not the form taught in the gurukula sampradaya or sung in kacheri.

## What changed

### `lib/data/app_database.dart`

* **Anupallavi split out.** "Begane baaro mukhavannu thoro" is a separate
  **Anupallavi** section, not the pallavi's second line. The song now reads
  Pallavi / Anupallavi / Charanam 1-4.
* **All ten `{melody}` lines removed.** The user chose this over leaving notes
  in the wrong base or labelling them as approximate: a music app showing a
  melody in the wrong sruti is worse than showing none. The words, the section
  headings and the swaram block stay.

### `test/repositories/song_repository_test.dart`

* The test that asserted a melody line under every lyric line now asserts the
  opposite — no `{melody}` in the seeded song — with a comment explaining why
  and pointing at the plan. It still checks the ten lyric lines and the new
  `Anupallavi:` heading.
* The "every melody line is readable and fills one misra chapu cycle" test was
  removed: it had nothing left to read in this song. That behaviour is still
  covered by `test/services/melody_parser_service_test.dart`.
* Two other assertions keyed off `{melody}` were repointed at `Anupallavi:` and
  `Charanam 4:`.
* The now-unused `melody_parser_service.dart` import was dropped.

### `docs/features.md`

* Records that the sample song deliberately carries no melody, and why.
* Records three measured gaps in the `{melody}` format (see below), so nobody
  assumes it is a complete Carnatic notation.

## Three gaps in the melody format, measured not guessed

Each was checked by running the parser, not by reading the code:

| Gap | What happens |
|---|---|
| **`;` not understood** | Published notation uses `;` for a two-unit extension. We only have the one-unit `,`. Parsing `; ; Sa \| Ga3 , Ma1 \| Ri2 ;` gives 8 beats and three "Could not read" problems. |
| **lowercase means komal, not lower octave** | Carnatic sources write fast gamaka runs lowercase to mean the mandra sthayi. We read lowercase as komal, so `n d r` sound N2 D1 R1 where Yamunakalyani wants N3 D2 R2. Three of five letters wrong. Source notation must be rewritten with explicit octave dots (`.Ni3`), not pasted. |
| **multi-avarta lines untested on screen** | A lyric line spanning three avartas needs three stacked `{melody}` lines. The parser handles this — `, , Sa \| Ga3-, Ma1 \| Ri2 ,` parses clean at exactly 7 beats — but the stacked grid layout has never been looked at on a phone. |

The middle column above is why the shivkumar.org notation cannot simply be
pasted in.

## What is still open

1. **The pallavi's beat arithmetic.** The notation given is
   `; ; S | G , m | R ;`. Misra chapu is 3 + 2 + 2 = 7, but that is 8 symbols,
   and group 2 (`G , m`) has three symbols in a two-beat group. Reading `;` as
   the usual two-unit extension overflows group 1 instead. Awaiting the user's
   reading. If `G` and `m` share a beat, our form is `Ga3-, Ma1`, which parses
   at exactly 7.
2. **Anupallavi and Charanam 1-4 notation** — not yet supplied.
3. **The inline `[...]` markers.** These were derived from the same
   absolute-scale reading as the deleted melody lines, so they carry the same
   wrong base. They were **left in place** — removing them was not what the user
   authorised, and it would leave the sample song with no notation at all. This
   needs a decision.
4. **Sruti representation.** The app has no way to say a song is in madhyama
   sruti. Options were listed in the plan (`{sruti: madhyama}` header, a
   madhyama `{tonic:}`, or documentation only); none chosen yet.

## Checks

* `flutter analyze` — clean, no issues.
* `flutter test` — all 701 tests pass (one fewer than before: the melody
  readability test in this group was removed as described above).
* `dart format` — applied.
