# Carnatic notation reference document

Date: 2026-08-22

Requested directly by the user: read the four "Gentle Introduction to Carnatic
Music" pages and make the needed document in `docs/`. No separate plan file —
the change was explicitly instructed, is additive, and creates documentation
only.

---

## What was added

**[docs/carnatic_notation.md](../docs/carnatic_notation.md)** — a reference for
how Carnatic notation works and how it maps onto the app's `{melody}` format.

Nine sections:

1. **The swaras** — seven swaras, sixteen names, twelve svarasthanas, with the
   full position table. Plus the house rule that Classical songs here always use
   two-letter names, and *why* (our parser reads a single lowercase letter as
   komal, which collides with the Carnatic use of lowercase for speed).
2. **Octaves** — mandra/madhya/tara, how sources mark them, how we write them,
   and a caution that plain-text sources often drop the dots.
3. **Tala** — the beat counts the app actually knows, eduppu, anagata eduppu.
4. **Speed (kalam)** — first/second/third, how they are written, and the
   duration symbols `;` `,` `-`.
5. **Ragas** — melakarta, janya, vakra, bhashanga ragas and the anya svara,
   madhyama sruti.
6. **Composition structure** — pallavi, anupallavi, charanam, sangati.
7. **Our `{melody}` format** — the full token table and a conversion table from
   published notation.
8. **What our format cannot express** — five named limits.
9. **Worked example** — the *Krishna Nee* pallavi, source notation to our line.

## Every rule is sourced

The document marks each rule **[source]** (stated in the reference pages) or
**[derived]** (worked out by fitting the notation, with the method shown). That
distinction matters: the pages teach the theory but **do not** state how
published notation writes speed or duration. Those rules came from fitting 66
avartas of a known misra chapu krithi, and the document shows the fit table so
the reasoning can be checked or redone on a new source.

## One thing the source confirmed

Part III states first kalam is the base speed, second is double, third is
quadruple. That independently confirms the durations fitted a day earlier for
lowercase (½ matra) and underlined (¼ matra) notes. The empirical result and the
textbook agree.

## One discrepancy found and recorded

Part III lists **Roopakam as 3 beats**; the app's `_carnaticTalaBeats` uses
**6**. Both readings are in circulation — rupaka is 6 aksharas in the standard
reckoning but often counted in 3. The document records the difference and states
that the app's value is 6, so rupaka melody lines must be written to 6. No code
was changed.

## Verified against the code, not assumed

* `SwaraNotation._carnaticPositions` was checked line by line against the
  svarasthana table in Part I — it matches exactly.
* The tala table in the document was taken from
  `SwaraNotation._carnaticTalaBeats` rather than from the source, so it
  describes the app as built.
* The case-sensitivity example (`Ni3`/`ni3`/`N`/`n`) is output from a probe run
  against the real `SwaraNotation`, not from memory.

## Also changed

**`CLAUDE.md`** — one row added to the "Read these docs before working" table,
so the new document is found before anyone touches swaras, melody lines, talas
or ragas.

## Checks

* `flutter analyze` — clean (no code changed).
* `flutter test` — 703 passing (no code changed).
* Documentation only; no `lib/` or `test/` file touched.

---

# Addendum — verification pass against the four source pages

Date: 2026-08-22 (later the same day)

The user asked for the document to be checked against the four URLs. Each claim
marked **[source]** was put to the page as a direct yes/no question. The document
was wrong in several places and has been corrected.

## Confirmed correct

The 12-svarasthana table (including `Ri2 = Ga1` and `Dha2 = Ni1`); octave dots
below for mandra and above for tara; the 22-sruti scheme; 72 melakartas;
sampoorna; janya derivation; arohana/avarohana; vakra ("which literally means
crooked"); eduppu; sangati as composer-intended variations; and the kalam
speeds, quoted directly: *"when the baud rate is doubled it is called 'second
kaalam' and when quadrupled, it is called 'third kaalam'."*

Tala beat counts confirmed verbatim: Roopakam "three beats per cycle", Adi
"eight beat cycle", Khanda Chapu "five beat", Misra Chapu "seven beat cycle".

## Wrong, now fixed

Five things were marked **[source]** that appear **nowhere in the four pages**.
They came from the user's own explanations, which cited the standard treatises.
A third provenance marker, **[lakshana]**, was added and they were moved to it:

* bhashanga, anya svara, vishesha prayoga
* madhyama sruti
* anagata eduppu — the term *eduppu* is in Part III; the *anagata* variety is not

Two smaller corrections:

* **"sixteen names"** was presented as stated by the source. It is not — it is a
  count of the table's entries, and now says so.
* **"Ma has exactly two forms"** is true only in the twelve-key scheme. Part I's
  22-sruti table lists **four** Ma variants. A caveat was added.

## The point the user raised — case in notation

Checked directly. **None of the four pages attaches any meaning to uppercase
versus lowercase**, and none shows any duration symbol.

Worse, the pages use lowercase *casually with no meaning*: Part III writes
"Ma pa da sa sa ri" and "Sa ri ga, ri ga ma"; Part II drops to lowercase purely
as shorthand once variants are established. That is the opposite of the krithi
notation pages, where lowercase means second kalam.

This is a genuine trap, and the document now warns about it in §1. It also
confirms the **[derived]** marking on the case and duration rules was right:
those rules are ours, fitted from real notation, not taken from the text.

## Added while verifying

* **poorvaangam / uttaraangam** — the two tetrachords, in Part I and worth having.
* A "what these four do NOT contain" table in the Sources section, so the next
  reader knows where the introduction stops. The key sentence: *the introduction
  teaches the theory but never explains how notation is written down.*

## Checks

* Documentation only; no code touched. `flutter analyze` clean, 703 tests
  passing, unchanged from the previous entry.

---

# Addendum 2 — karnatik.com symbols page checked

Date: 2026-08-22

The user supplied https://www.karnatik.com/symbols.shtml, which documents the
notation symbols the Ramesh introduction never covers. It was checked against
the notation actually transcribed.

## It defines the same symbols differently

| Symbol | karnatik.com | shivkumar krithi pages (our fitted rules) |
|---|---|---|
| `,` | one aksharakala | 0.5 matra |
| `;` | two aksharakalas | 1.0 matra |
| lowercase | **madhya sthayi** — middle octave | **second kalam** — half duration |
| uppercase | **tara sthayi** — upper octave | first kalam — full duration |
| lower octave | dot to the **right** (`n.`) | not marked |
| ruled group | line over = double speed | underline used |

## Tested, not assumed

Applying karnatik's definitions to the 66 avartas of *Krishna Nee Begane Baaro*
as published on shivkumar.org:

```
karnatik.com rules  ';'=2, ','=1, case=octave        0 / 66 avartas fit
our fitted rules    ';'=1, ','=0.5, case=speed      66 / 66 avartas fit
```

Zero against sixty-six. The two sites use **different, incompatible systems**.
Part of the gap may be that karnatik's `,` and `;` entries are phrased as
*eduppu* offsets ("1/4 eDuppu", "1/2 eDuppu") rather than general note duration.

**The transcription in the app is unaffected** — it was fitted against the
notation it came from, and still fits it perfectly.

## One corroboration

karnatik states a line over the swaras means double speed, two lines quadruple.
That is the same idea as the underline found in the shivkumar screenshots, and
independently supports reading a ruled group as one kalam faster. The earlier
fitted result and this page agree on the concept.

## Two symbols worth adopting later

* `*` = **anya svara**. A source that marks the borrowed note removes the
  guesswork that forced the Ma1/Ma2 rule to be applied from raga grammar.
* `~` = **kampita gamaka**, which matches our existing `~` shake mark.

## Document changes

New section **§4a "Conventions differ between sources — check before you
transcribe"**, carrying the comparison table, the 0/66 result, and the rule of
thumb: *never assume a symbol table applies to a notation page from a different
site; fit it first and count the avartas.* karnatik.com added to Sources with a
pointer to §4a.

## Checks

* Documentation only; no code touched. `flutter analyze` clean, 703 tests
  passing.

---

# Addendum 3 — the same site uses two conventions

Date: 2026-08-22

The user pointed out that shivkumar.org's sarali varisai page credits
karnatik.com, which would imply the earlier 0/66 result was a misreading. It was
checked. The premise is right; the conclusion it suggests is not.

## The credit lines differ

| shivkumar.org page | credits karnatik.com for | legend on the page |
|---|---|---|
| `basics/sarali-varisai` | **"Notation Courtesy: Rani, www.karnatic.com"** | *"Capitalized letters are in the higher octave"* |
| `krishnaneebegane` | **"Lyrics & Meanings Courtesy: Karnatik.com"** | **none at all** |

The beginner pages take their **notation** from karnatik and follow its octave
convention: `s r g m | p d | n S` fills adi tala's 4 + 2 + 2, one akshara per
space-separated letter. The krithi page credits karnatik only for the **words**,
carries no legend, and does not behave that way.

Neither page's legend defines `;`, `,`, `|`, `||` or `-`. The sarali legend
covers the seven letters and the octave rule, nothing else.

## Re-tested with the octave convention

```
karnatik.com rules     ';'=2, ','=1, case=octave        0 / 66
octave convention      one akshara per token, ',' merges 38 / 66
our fitted rules       ';'=1, ','=0.5, case=speed       66 / 66
```

## Honest statement of confidence — added to the document

For the speed reading:

* the fit — 66/66 against 38/66 and 0/66;
* corroboration — Ramesh Part III has kalams doubling and quadrupling, karnatik
  has ruled groups meaning the same; a written speed mark is standard practice
  and only the mark differs;
* the music — reading `; ; S | G , m | R ;` with case as octave would drop one
  note an octave mid-phrase, where reading it in one octave gives `Sa Ga3 Ma1
  Ri2`, exactly the raga's `G3 M1 R2` descent.

Against it:

* the underline exception was found by inspecting the residual. After the other
  three values left nine misfits, those nine were checked against the
  screenshots and found underlined. A reasonable inference, but the residual
  pointed the way, so it is not fully independent evidence. This is now stated
  in the document rather than glossed.

**If the reading is ever shown wrong, the sample song's octaves and rhythm both
need redoing.** The document now records the transcription as fitted, not
authoritative.

## Document changes

§4a rewritten: the same-site credit-line table, the 38/66 figure, a sharpened
rule of thumb ("even one on the same site"), and a new subsection
"How confident is the speed reading? — honestly".

## Checks

* Documentation only; no code touched. `flutter analyze` clean, 703 passing.

---

# Addendum 4 — coherence pass

Date: 2026-08-22

After three rounds of patching, the document contradicted itself. A read-through
found §4 asserting the speed convention as universal while §4a said it was one
of several. Fixed:

* **§4** now scopes the case-as-speed table to "the krithi notation pages this
  app's sample song came from", with a callout to read §4a before applying it.
  The flat claim "lowercase means speed, not octave and not variant" is now
  conditional on the page using that convention.
* **§4's `;` note** names karnatik.com as the source of the two-aksharakala
  definition instead of the vague "sources sometimes describe".
* **§1's warning** now says plainly that lowercase means **three** different
  things across sources — nothing at all (Ramesh's prose), middle octave
  (karnatik, sarali varisai), second kalam (krithi pages) — and points at §4a.
* **§2** gains a comparison table of octave conventions, including karnatik's
  dot-to-the-right (`n.`) which was not previously recorded.
* **§4a** retitled "Conventions differ page by page" with the governing rule up
  front: *a symbol table belongs to the page that publishes it, and to nothing
  else.*
* **§7's conversion table** now states it assumes the speed convention and says
  which rows stop applying if the page uses case for the octave.
* **Sources** gains the sarali varisai page with its credit line and legend
  quoted, and the caveat that both karnatik entries describe the beginner pages
  rather than the krithi notation.

Provenance totals after the pass: 17 **[source]**, 8 **[lakshana]**,
7 **[derived]**, across 518 lines.

## Checks

* Documentation only; no code touched. `flutter analyze` clean, 703 passing.

---

# Addendum 5 — no universal standard; a decision procedure added

Date: 2026-08-22

The user established the framing that settles this thread: **Carnatic music has
no universal written notation.** There is no equivalent of Western staff
notation. Each book and site uses its own convention, and each is correct on its
own terms. They also proposed a litmus test and asked for karnatik.com to be
re-examined for beat/duration notation.

## karnatik.com re-read, focused on duration

Fuller and partly corrected:

| Symbol | karnatik.com |
|---|---|
| `,` | *"extend note to an extra aksharakala"* — lengthens the note before it |
| `;` | *"semicolon or 2 commas"* — two aksharakalas |
| `; ,` | three aksharakalas |
| speed | *"one line over swaras … double speed from normal"*; two lines = 4x |
| notes sharing a beat | **no such convention** |

The structural insight, now in the document: karnatik carries **all** duration in
the punctuation, so it has no need for case or clumping — which is exactly why it
can spend case on the octave. The krithi pages carry duration in case *and*
clumping, freeing the punctuation for other work. Both are internally consistent;
they cannot be mixed.

## The litmus test — adopted, with a correction

The user's test: *dots present → case is octave; no dots → case is duration.*

Run against our own data it supports the transcription. Counted across the whole
krithi notation: **zero** dots, **zero** apostrophes, zero diacritics, against
168 uppercase and 229 lowercase note letters.

**But the test alone is not sufficient, and our data shows why.** The sarali
varisai line `s r g m | p d | n S ||` also has **zero** dots — yet its stated
legend says case is the octave. Same evidence, opposite answers.

So the document adopts it as step 2 of a three-step procedure rather than as a
standalone rule:

1. **Does the page state a legend? Use it.** A legend always beats inference.
2. **No legend? Look for octave marks** — their presence frees case for duration.
3. **Always confirm by fitting the tala.** The right convention makes every cycle
   land. This is the only step that cannot lie.

## Added to the confidence section

A fourth supporting point: no octave marks appear anywhere in the krithi
notation, against 397 note letters split across both cases. A page using case for
the octave would have no way left to write the third sthayi.

## Not consulted

`ramyasspace.wordpress.com/2011/06/24/64/` returned **HTTP 403 Forbidden** and
could not be read. Nothing in the document comes from it; it is recorded in
Sources as unread so nobody assumes otherwise.

## Document changes

§4a now opens with the no-universal-standard framing; the comparison table gains
karnatik's fuller duration entries and two rows on speed and beat-sharing; new
subsection "Which convention is this page using? — a procedure"; the confidence
section gains the octave-mark count. Now 561 lines.

## Checks

* Documentation only; no code touched. `flutter analyze` clean, 703 passing.

---

# Addendum 6 — the convention is documented after all; open item closed

Date: 2026-08-22

The user supplied screenshots of
[ramyasspace.wordpress.com/2011/06/24/64/](https://ramyasspace.wordpress.com/2011/06/24/64/),
"How to read notations in Carnatic music", which had returned HTTP 403 to direct
fetching. It documents in words the convention that had until now been inferred.

## It states the rules outright

> *"Upper case letters e.g. S indicates two akshara kalas."*
> *"Lower case notes — just one akshara kala or note."*
> *"A comma indicates the space of one akshara kala or note."*
> *"A semi colon represents two akshara kalas or space for 2 notes."*
> *"Underlines indicate that the swaras should be sung together and faster
> within a particular beat."*

## It matches the fitted values exactly

Her aksharakala is half the matra this document had been counting in. Scaled:

| | Ramya | this doc | ratio |
|---|---|---|---|
| uppercase note | 2 | 1.0 | 2.0 |
| lowercase note | 1 | 0.5 | 2.0 |
| `;` | 2 | 1.0 | 2.0 |
| `,` | 1 | 0.5 | 2.0 |

Re-run in her units — misra chapu = 14 aksharakalas, grouped 6 + 4 + 4:

```
case = duration (upper 2, lower 1), underlines     66 / 66   shape 66 / 66
  the same, ignoring underlines                    57 / 66
case = octave (every note 1 aksharakala)           14 / 66   shape  6 / 66
```

The fit reached the right answer before the documenting source was found, and the
source confirms it. The **[derived]** rules in §4 are now **[source]**.

## A number I published was wrong

An earlier addendum reported the octave reading as fitting **0 / 66**. That was an
artifact of testing `;` = 2 and `,` = 1 against a 7-**matra** target instead of a
14-**aksharakala** one. Measured consistently it is **14 / 66** — still decisively
worse, but the earlier figure overstated the case. Corrected in the document with
the correction called out rather than quietly edited.

Relatedly: karnatik.com, Ramya and our fitted values **all agree on the
punctuation** (`,` = 1 aksharakala, `;` = 2). The only disagreement between
conventions is what letter case means. Ramya names both in one paragraph:
*"some websites also use upper case to denote upper octave swara."*

## The open item is closed

The document previously warned that if the duration reading were disproved, the
sample song's octaves and rhythm would both need redoing. It is not disproved —
it is now documented. **No rework needed.** That warning has been replaced with a
settled finding listing the five supports in the order they arrived.

## Newly documented symbols added

* `|` is *"the end of an anga"* — a laghu, dhruta or anudhruta — not just a
  visual divider. This is why misra chapu's bar lines fall on 3 + 2 + 2.
* `||` is *"the end of an avarta of tala"*.
* `-` marks *"where to give pause"*, mostly in varnams.
* Wavy line = the notes should have gamakas.
* Tala marks: `X` = a beat, ✔ = flipping the palm, `1` `2` `3` = finger counts.
  Recorded, though the app does not model them.

## Document state

609 lines. Provenance: 21 **[source]**, 8 **[lakshana]**, 5 **[derived]**.
Ramya's page added to Sources as the key citation for §4, with a note that it is
403 to direct fetching and was read from user-supplied screenshots.

## Checks

* Documentation only; no code touched. `flutter analyze` clean, 703 passing.
