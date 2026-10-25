# Carnatic Notation — reference for LyricChord

> **What this is.** The app stores Indian classical songs as swaras, and users
> will copy notation in from published sources. Those sources use conventions
> the app does not share. This document is the bridge: what the conventions
> mean, how they map onto our `{melody}` format, and what our format cannot
> express.
>
> It exists because working this out once took a long investigation. Nobody
> should have to redo it.

Every rule below is marked with where it comes from. The distinction is not
decoration — it was checked page by page, and several things that "everyone
knows" are **not** in the introductory material at all.

* **[source]** — stated in Ramesh Mahadevan's four-part introduction, verified
  by quote (see [Sources](#sources)).
* **[lakshana]** — raga-grammar fact from the standard treatises, **not** in the
  four-part introduction. See [Sources](#sources) for which.
* **[derived]** — worked out from real notation by fitting, then checked against
  the app's parser. Reproducible; the method is given.

---

## 1. The swaras

Seven swaras — **Sa Ri Ga Ma Pa Dha Ni**, abbreviated **S R G M P D N**.
**[source]**

Sa and Pa are fixed. The others take variant forms across **twelve
svarasthanas** (semitone positions), and several names share a position:
**[source]**

| Semitones above Sa | Western (Sa = C) | Swara names |
|---|---|---|
| 0 | C | Sa |
| 1 | C♯ | Ri 1 |
| 2 | D | Ri 2, **Ga 1** |
| 3 | D♯ | Ri 3, **Ga 2** |
| 4 | E | Ga 3 |
| 5 | F | Ma 1 (shuddha) |
| 6 | F♯ | Ma 2 (prati) |
| 7 | G | Pa |
| 8 | G♯ | Dha 1 |
| 9 | A | Dha 2, **Ni 1** |
| 10 | A♯ | Dha 3, **Ni 2** |
| 11 | B | Ni 3 |

Counting the distinct names in that table gives sixteen, though the source
does not state that total itself.

The overlaps are why a swara cannot be identified by letter alone — `Ri 3` and
`Ga 2` are the same key, named differently by context.

The octave also splits into two tetrachords: **poorvaangam** (the lower four
keys, where Ri and Ga live) and **uttaraangam** (the upper four, Dha and Ni).
**[source]**

> **A caveat on "Ma has two forms".** In the twelve-svarasthana scheme above it
> does — Ma 1 and Ma 2. But Part I's 22-sruti table lists **four** Ma variants.
> The twelve-key view is the practical one for this app; the finer scheme is
> about microtonal shading, which the app does not model.

> **In our code:** `SwaraNotation._carnaticPositions` in
> [lib/services/swara_notation_service.dart](../lib/services/swara_notation_service.dart)
> encodes exactly this table. It was checked against the source and matches.

### House rule: always two letters

**Classical songs in this app always use the full two-letter name with its
variant digit** — `Sa Ri2 Ga3 Ma1 Ma2 Pa Da2 Ni3`. Never the single letter.

This is not decoration. Our parser reads a **single lowercase letter as komal**
(the Hindustani convention, which other songs in the app rely on). Published
Carnatic sources use lowercase for something else entirely — speed, see §4. Two
letter names are case-insensitive in our parser, so the clash cannot happen:

```
Ni3 -> 11    ni3 -> 11    NI3 -> 11     always right
N   -> 11    n   -> 10                  lowercase flips to komal
```

`Da`, `Dha` and `D` are all accepted and all mean the same swara.

> **Watch out — lowercase means at least three different things.** The
> introductory pages write swaras in lowercase *casually, with no meaning at
> all* — Part III has "Ma pa da sa sa ri", Part II drops to lowercase as
> shorthand. karnatik.com and shivkumar's beginner exercises use lowercase for
> the **middle octave**. The krithi notation pages use it for **second kalam**
> (§4). Three conventions, one letter case. Always establish which one a page
> uses before reading a note off it — §4a shows how.

---

## 2. Octaves (sthayi)

Three octaves. **[source]**

| Octave | Name | Written |
|---|---|---|
| lower | mandra sthayi | dot **below** the note |
| middle | madhya sthayi | **unmarked** |
| upper | tara sthayi | dot **above** the note |

Our format writes the lower octave as a **leading dot** (`.Ni3`) and the upper
as a **trailing apostrophe** (`Sa'`), because dots above and below are not
plain text.

Other written conventions you will meet:

| Convention | Lower octave | Upper octave |
|---|---|---|
| printed / Ramesh / Ramya **[source]** | dot **below** | dot **above** |
| karnatik.com **[source]** | dot to the **right** — `n.` `d.` `s.` | uppercase — `S R G` |
| ours | leading dot — `.Ni3` | trailing apostrophe — `Sa'` |

Ramya puts it plainly: *"A dot below a swara indicates a lower note and a dot
above the swara indicates higher note. 's' without the dot denotes the adhara
shadja or base shadja of our shruti."*

> **Caution.** Plain-text sources often drop the octave dots even where the
> music clearly needs them. In an ascending run like `n s r g m p`, the leading
> `n` sits *below* the Sa that follows it and is really mandra `.Ni3` — but the
> page may show a bare `n`. Transcribe what is written, then check the leaps.

---

## 3. Tala

A tala is a repeating cycle of beats (aksharas). A melody line must fill a whole
number of cycles. **[source]**

The beat counts the app actually knows are in
`SwaraNotation._carnaticTalaBeats`:

| Tala | Beats in the app | Grouping |
|---|---|---|
| Eka | 4 | |
| Khanda Chapu | 5 | 2 + 3 |
| Rupaka / Rupakam | 6 | 2 + 4 |
| **Misra Chapu** | **7** | **3 + 2 + 2** |
| Triputa | 7 | 3 + 2 + 2 |
| Adi | 8 | 4 + 2 + 2 |
| Jhampa | 10 | |
| Matya | 10 | |
| Ata / Dhruva | 14 | |

> **One discrepancy worth knowing.** Part III lists Roopakam as **3** beats;
> the app uses **6**. Both readings are in use — Rupaka is 6 aksharas in the
> standard reckoning but is often counted in 3. The app's value is 6, so write
> rupaka melody lines to 6.

**Eduppu** is where the melody starts inside the cycle. **[source]** — the
introduction gives the term but not its varieties. The name for a *delayed*
start, where the cycle opens with rest, is **anagata eduppu**. **[lakshana]**

> *Krishna Nee Begane Baaro* is misra chapu with anagata eduppu: the first two
> beats are rest and the word "Kri" lands on beat 3.

---

## 4. Speed (kalam) — and how it is written

| Kalam | Speed | Duration of one note |
|---|---|---|
| First (prathama) | base | 1 matra |
| Second (dvitiya) | double | ½ matra |
| Third | quadruple | ¼ matra |

**[source]** — Part III states first kalam is the base, second is double, third
is quadruple.

How a page *writes* this is never stated by the Ramesh introduction. It **is**
stated by Ramya's "How to read notations in Carnatic music", which documents the
convention the krithi pages use: **[source]**

> *"Upper case letters e.g. S indicates two akshara kalas."*
> *"Lower case notes — just one akshara kala or note."*
> *"Underlines indicate that the swaras should be sung together and faster
> within a particular beat."*

| Written | Duration in aksharakalas | In this document's matras |
|---|---|---|
| `S` uppercase | **2** | 1.0 |
| `s` lowercase | **1** | 0.5 |
| `s̲` underlined | packed into one beat, faster | 0.25 each for four |

### A note on units — why `;` looks contradictory but is not

Ramya and karnatik.com both count in **aksharakalas**; earlier drafts of this
document counted in **matras**, where one matra = two aksharakalas. Every value
matches once scaled:

| | Ramya (aksharakala) | this doc (matra) | ratio |
|---|---|---|---|
| uppercase note | 2 | 1.0 | 2.0 |
| lowercase note | 1 | 0.5 | 2.0 |
| `;` | 2 | 1.0 | 2.0 |
| `,` | 1 | 0.5 | 2.0 |

**The same system throughout.** A `;` described as "two aksharakalas" and a `;`
described as "one matra" are the same duration. Misra chapu is 7 matras = **14
aksharakalas**, grouped 6 + 4 + 4.

Where this convention applies, lowercase means duration — **not** octave and
**not** variant. That is the opposite of what our own parser assumes for a single
letter, which is why Classical songs here always use two-letter names (§1). But
it is not universal: see §4a.

### Duration and structure symbols **[source]**

| Symbol | Meaning | Duration |
|---|---|---|
| `,` | *"the space of one akshara kala or note"* | 1 aksharakala = 0.5 matra |
| `;` | *"two akshara kalas or space for 2 notes"* | 2 aksharakalas = 1.0 matra |
| `\|` | *"the end of an anga. Be it a laghu, dhruta or anudhruta"* | none |
| `\|\|` | *"the end of an avarta of tala"* | none |
| `-` | *"how the swaras need to be split within the tala … where to give pause"* — mostly in varnams | none |
| underline | *"swaras should be sung together and faster within a particular beat"* | packs into one beat |
| wavy line | *"the notes should have gamakas"* — rarely used | none |

Note that `|` marks the end of an **anga**, not merely a visual group — which is
why the angas of misra chapu (3 + 2 + 2 beats) are what the bar lines fall on.

### Tala marks **[source]**

Printed notation often carries a row of tala marks above the swaras:

| Mark | Meaning |
|---|---|
| `X` | a beat |
| ✔ | flipping the palm |
| `1` `2` `3` | finger counts |

The app does not model these — the `{tala}` header plus one `{melody}` line per
cycle carries the same information for our purposes.

> **These values were fitted first, then confirmed.** They were derived by
> fitting 66 avartas before any source for them was found. Ramya's page later
> gave the same values in aksharakalas — `,` = *"the space of one akshara kala"*,
> `;` = *"two akshara kalas"* — matching exactly once scaled. karnatik.com gives
> the same two figures. **All three agree on the punctuation**; they differ only
> on what letter case means (§4a).

### How the fit was done

This is recorded because the method is reusable, and because it reached the right
answer before the documenting source was found. Try candidate durations; count
how many avartas total exactly 7 matras in the shape 3 + 2 + 2:

```
rule                                       avartas at exactly 3+2+2
every symbol = 1 beat                             34 / 66
';' = 1 beat, ',' = karvai sharing a beat         37 / 66
';' = 1.0, ',' = 0.5, lowercase = 0.5             57 / 66
  + underline = third kalam (quarter)             66 / 66
```

The method is worth reusing on any new source: **if the durations are right,
every cycle lands on the tala.** A rule that leaves stragglers is wrong.

---

## 4a. Conventions differ page by page — establish them before you transcribe

**Carnatic music has no universal written notation.** There is no equivalent of
Western staff notation that every source agrees on. Books and websites each use
their own convention, and each is correct on its own terms. This is the trap that
will cost the most time, so it gets its own section.

**The single rule to remember: a symbol table belongs to the page that publishes
it, and to nothing else.**

The conventions differ **not just between sites, but between pages of the same
site.** Check the credit line on the page you are reading before you trust any
symbol table against it:

| shivkumar.org page | credits karnatik.com for | notation legend on the page |
|---|---|---|
| `basics/sarali-varisai` | **"Notation Courtesy: Rani, www.karnatic.com"** | *"Capitalized letters are in the higher octave"* |
| `krishnaneebegane` | **"Lyrics & Meanings Courtesy: Karnatik.com"** | **none at all** |

So the beginner exercises follow karnatik's system — uppercase is the upper
octave, every space-separated letter is one akshara, and `s r g m | p d | n S`
fills adi tala's 4 + 2 + 2. The krithi notation pages carry **no legend**, credit
karnatik only for the words, and do not behave that way.

**karnatik.com's symbols page** defines the same symbols *differently* from the
krithi notation this app's sample song came from:

| Symbol | karnatik.com **[source]** | shivkumar krithi pages **[derived]** |
|---|---|---|
| `,` | *"extend note to an extra aksharakala"* — lengthens the note before it | **0.5** matra (karvai) |
| `;` | *"semicolon or 2 commas"* — two aksharakalas | **1.0** matra |
| `; ,` | three aksharakalas | — |
| lowercase `srgmpdn` | **madhya sthayi** (middle octave) | **second kalam** (half duration) |
| uppercase `SRGMPDN` | **tara sthayi** (upper octave) | first kalam (full duration) |
| lower octave | dot to the **right**: `n.` `d.` `s.` | not marked at all |
| speed | one line **over** swaras = double, two lines = quadruple | **underline** = one kalam faster |
| notes sharing a beat | **no such convention** | letters written together: `snrs` |

Two things stand out. karnatik carries **all** duration in the punctuation, so it
has no need for case or clumping — which is exactly why it can spend case on the
octave. The krithi pages carry duration in case *and* clumping, which frees the
punctuation to mean something else. Both are internally consistent; they simply
cannot be mixed.

Applying each reading to the 66 avartas of *Krishna Nee Begane Baaro* as
published on shivkumar.org, all counted in aksharakalas (misra chapu = 14,
grouped 6 + 4 + 4):

```
reading                                              total=14   shape 6+4+4
case = duration (upper 2, lower 1), underlines          66          66
  the same, ignoring underlines                         57          57
case = octave (every note 1 aksharakala)                14           6
```

> **Correction.** An earlier version of this document reported the octave reading
> as fitting **0 / 66**. That figure was wrong — an artifact of testing
> `;` = 2 and `,` = 1 against a 7-**matra** target instead of a 14-**aksharakala**
> one. Measured consistently it is 14 / 66. Still decisively worse, but the
> earlier number overstated the case.

### Which convention is this page using? — a procedure

Work down the list. Stop at the first step that answers.

**1. Does the page state a legend? Use it.** The legend always beats inference.
The sarali varisai page says *"Capitalized letters are in the higher octave"*;
that settles it for that page, and no amount of arithmetic overrides it.

**2. No legend? Look for octave marks.** If swaras carry dots or apostrophes
(`.S`, `S.`, `S'`), the page has a *separate* way to write the octave — so case
is free to mean duration. If there are none at all, and case varies a lot, case
is probably carrying the octave... or the duration. Which brings you to step 3.

**3. Always confirm by fitting the tala.** Count the avartas under each candidate
reading. The right convention makes **every** cycle land on the tala. This is the
only step that cannot lie.

> **Why step 3 is not optional.** The dots test alone is a good hint but it is
> not sufficient — and our own data proves it. The krithi notation has **zero**
> octave dots and uses case for duration. But the sarali varisai line
> `s r g m | p d | n S ||` also has **zero** dots, and there case means the
> octave. Same evidence, opposite answers. Only the legend (step 1) and the
> arithmetic (step 3) separate them.

### Is the duration reading right? — settled

**Yes, and it is no longer an inference.** Ramya's page documents the convention
in words, and it matches the values fitted from the notation exactly once the
aksharakala/matra scaling is applied: 66 of 66 avartas, every one shaped
6 + 4 + 4.

The supporting evidence, in the order it arrived:

1. **The fit.** 66/66 against 14/66 for the octave reading.
2. **No octave marks anywhere.** Zero dots, zero apostrophes, zero diacritics
   across the whole krithi notation, against 168 uppercase and 229 lowercase note
   letters. A page using case for the octave would have no way left to write the
   third sthayi.
3. **The music.** Reading `; ; S | G , m | R ;` with case as octave drops one note
   an octave mid-phrase. Read in one octave it is `Sa Ga3 Ma1 Ri2` — exactly the
   raga's `G3 M1 R2` descent.
4. **A documenting source.** Ramya states it outright, and separately notes that
   *"some websites also use upper case to denote upper octave swara"* — the two
   conventions, named by one author, in one paragraph.
5. **Corroboration on the underline.** Ramya: *"underlines indicate that the
   swaras should be sung together and faster within a particular beat"*. That was
   originally inferred from residual misfits plus the screenshots; it is now
   documented.

**The open item is closed.** The sample song's octaves and rhythm do not need
redoing.

### Two karnatik symbols worth adopting

| Symbol | Meaning | Why it matters |
|---|---|---|
| `*` | **anya svara** | A source that marks the borrowed note removes the guesswork described in §5. The shivkumar notation does not use it, which is exactly why the raga's grammar had to decide Ma1 from Ma2. |
| `~` | **kampita gamaka** | Matches our own `~` shake mark. |

---

## 5. Ragas

**Melakarta** — the 72 parent scales, each with all seven swaras ascending and
descending. **Janya** — a raga derived from a melakarta, possibly dropping notes
or moving in zigzag. **[source]**

**Arohana** is the ascent, **avarohana** the descent. A **vakra** raga zigzags
rather than moving straight — "which literally means crooked". **[source]**

### Bhashanga ragas and the anya svara

A **bhashanga** raga borrows a foreign note (**anya svara**) that is not in its
parent scale. The anya svara is **not free** — it may appear only in a specific
phrase (**vishesha prayoga**). **[lakshana]**

> None of "bhashanga", "anya svara" or "vishesha prayoga" appears anywhere in
> the four-part introduction. It is a beginner's text and stops short of this.
> The rule matters anyway, because it is what decides an unmarked variant.

This matters for transcription, because notation often does not mark which
variant is meant. The raga's grammar decides.

> **Worked case — Yamunakalyani.** Janya of the 65th melakarta Mechakalyani,
> whose natural madhyamam is prati (Ma2). Its anya svara is **shuddha madhyamam
> (Ma1)**, and it appears **only** in the descending `Ga3 → Ma1 → Ri2` phrase.
> Everywhere else the madhyamam is Ma2.
>
> * ARO: `S R2 G3 P M2 G3 P D2 N3 D2 Ṡ` (vakra)
> * AVA: `Ṡ N3 D2 P M2 G3 **M1** R2 S`
>
> In the seeded sample song this rule is applied mechanically and guarded by a
> test, so a careless edit cannot spread Ma1 through the song.

### Madhyama sruti

Some ragas — Yamunakalyani, Kurinji, Nadanamakriya, Chenchurutti — are
traditionally sung in **madhyama sruti**: the tambura's Pa string is dropped to
shuddha madhyamam, and that note is taken as the base Sa. Such a krithi is
notated **starting on `Sa`**, not on `Pa`. **[lakshana]**

> Not in the four-part introduction either — it names Nadanamakriya and
> Chenchurutti only as derived ragas, and never discusses the tuning. Missing
> this is what made an earlier transcription of the sample song wrong: it was
> written from `Pa`, on an absolute scale, and had to be redone.

> **The app cannot record this yet.** There is no `{sruti:}` directive, so a
> madhyama-sruti song's notated Sa is not tied to any absolute pitch. The player
> sets their own drone. Worth adding.

---

## 6. Composition structure

| Part | What it is |
|---|---|
| **Pallavi** | the opening line, returned to as a refrain |
| **Anupallavi** | the second section |
| **Charanam** | the stanzas; a krithi may have several |
| **Sangati** | a variation of a line, composed by the composer, sung on repeats |

**[source]**

> **Sangatis and our format.** A source may give three sangatis of a pallavi and
> five of an anupallavi. Our format has no way to *label* one as "variation 2 of
> the same line".
>
> It does **not** follow that they cannot be stacked. Playback is **per line** —
> `MelodyPlayerNotifier.play()` takes a single `MelodyLine`, and `MelodyLineRow`
> draws one row with its own play button for every `{melody}` line. Several
> sangatis under one lyric line each play on their own; nothing joins them.
>
> So stacking works today. To keep them apart on screen, write a plain text
> heading between them — section headings such as `Pallavi:` are ordinary lines,
> so `Sangati 2:` reads just as well:
>
> ```
> Pallavi:
> [Sa]krishna nee bEganE baarO
> {melody} , , Sa | Ga3 Ma1 | Ri2 ,
>
> Sangati 2:
> {melody} , , Sa | Ga3 Ma1 | Ri2 ,
> ```
>
> The seeded sample carries the **first sangati only**. That is a choice about
> that song, not a limit of the format.

---

## 7. Our `{melody}` format

One `{melody}` line holds **one tala cycle**. A lyric line spanning four cycles
carries four `{melody}` lines stacked under it.

| Written | Meaning |
|---|---|
| `Ga3` | one beat, one note |
| `,` | one beat of hold or rest |
| `\|` | tala group divider (visual; not a beat) |
| `Sa-Ni3` | two notes sharing one beat |
| `Da2-Pa-Pa-,` | four slots in one beat: Da2, Pa, then Pa held for two |
| `,-Ri2` | **tie** — the first half carries the previous sound on, then Ri2 |
| `Ri2-x` | **silence** — Ri2 for half the beat, then nothing |
| `.Ni3` | lower octave |
| `Sa'` | upper octave |
| `!` | **slide (jaru)** — glides into the note, and is sounded |
| `~` | shake (kampita) — parsed and drawn, **not yet sounded** |

Our `|` matches the common meaning (a group divider inside the cycle). Note that
karnatik reserves `||` for the end of an avartanam; our format ends the cycle
with the line itself, one `{melody}` line per cycle.

### Converting published notation

Assuming the page uses the **speed** convention (§4a — check first; if it uses
case for the octave, the middle two rows do not apply):

| Source | Becomes |
|---|---|
| `;` | `,` |
| `X ,` | `X` (or `X-,` where the karvai fills its own beat) |
| lowercase clump `snrs` | `Sa-Ni3 Ri2-Sa` — two beats, two notes each |
| a note running past a beat line | a tie `,` in the next beat's first slot |
| underlined clump `mdpp` | `Ma2-Da2-Pa-Pa` — one beat, four notes |
| any swara | two-letter name with digit |

---

## 8. What the app does, and what it still cannot express

### Built

* **Reading published notation.** `CarnaticNotationImporter` converts a pasted
  block into `{melody}` lines, applying every rule in §4. Reach it from the song
  editor: **More options -> Paste Carnatic**.
* **Both gamaka marks reach the sound.** The slide `!` glides into the note over
  the first 30% of it, capped at 120 ms, interpolating in semitones — a bare `!`
  scoops in from one semitone below, `Ma2!Ga3` glides from the written note. The
  shake `~` swings the pitch **up from the written note and back**, one key deep,
  at two swings per beat (clamped to 3–8 Hz), after a short plain onset and
  ramping in over the first swing. A note under 180 ms is sung plain, and a note
  can slide and shake at once. Read the shake's limits under *Still cannot
  express* below — it is one fixed shape standing in for every kampita.
* **Swaras are tuned against the drone, not to a piano.** Each of the twelve keys
  sounds at a whole-number ratio from Sa — Pa is exactly 3/2, Ma1 exactly 4/3,
  which is where the shruti drone puts them, so a held note locks in instead of
  beating. Equal temperament would put Pa two cents flat of the drone's own Pa.
  The table is `MelodyPlayerService.justRatios`. This is the twelve-key scheme of
  §2, not the 22-sruti one; a position with two names gets one tuning.
* **Writing a melody without typing it.** The **Melody keypad** (song editor ->
  More options) offers all sixteen swaras and every mark in §7 as buttons, draws
  the beats as they are entered, and counts them against the song's tala. It
  writes only tokens the parser reads, so a keypad line always plays. With the
  cursor on an existing `{melody}` line, that line is loaded and replaced.
* **Telling the two conventions apart.** The importer converts under *both*
  readings of letter case, scores each against the tala, and shows the result —
  "1 of 1 cycles fit, read with case means note length" — plus how the other
  reading scored. A tie is reported, never silently resolved. This is the §4a
  procedure in code.
* **`;` and `*` in melody lines.** `;` is accepted as a synonym for our `,`, and
  an anya-svara `*` is ignored rather than breaking the note, so a pasted line
  does not hard-fail.
* **Notes that cross a beat line.** A beat is a list of slots, each a note, a
  **tie** to the previous sound, or **silence**. So a note can start or stop
  part-way through a beat, which Carnatic phrases do constantly — they begin off
  the beat. The importer keeps such notes where the source puts them instead of
  snapping them to the nearest beat.

  Worth knowing: in this notation `,` and `;` both **extend** a note; neither is
  a rest. So the importer only ever needs the tie. The silence mark `x` exists
  because the format had no way to write a rest inside a beat at all, not
  because the conversion needs it.
* **`{sruti: madhyama}`.** Marks a song as sung in madhyama sruti; the melody
  player then places its Sa a fourth up, where the notation means it (§5).

### Still cannot express

1. **Slots divide a beat equally.** A beat split 1/3 + 2/3 has to be written as
   three slots. Fine in practice, since Carnatic subdivision is binary. Notes
   that start or stop part-way through a beat **are** now supported — see the
   tie and silence marks in §7.
2. **Sangatis have no label.** See §6. They can be stacked and each plays on its
   own; what is missing is only a way to *mark* one as a variation of another, so
   a plain text heading is the workaround.
3. **The shake is sounded, but it is an approximation, not a gamaka model.**
   See the *Built* list above for what it does. What it is **not** is
   raga-aware: kampita's real shape, width and speed depend on the raga, the
   note and the phrase, and the app holds no raga grammar to read them from —
   decided in phase 1, and still true. One fixed shape stands in for all of
   them. It is deliberately conservative — up from the note only, metrical,
   ramped in, skipped on short notes — but read it as "there is a gamaka here",
   not as a rendering of that gamaka.
4. **Unequal subdivision within a beat is approximate.** Slots are proportional
   to the shortest note in that beat, so a 0.25 / 0.25 / 0.5 beat is written
   `A-B-C-,` and works, but stranger ratios will round.
5. **The madhyamam is not chosen for you.** The importer will apply the
   bhashanga rule (§5) only when asked, and reports where the phrase appears
   either way. It will not guess raga grammar.

---

## 9. Worked example

*Krishna Nee Begane Baaro*, pallavi, first avarta. Source notation:

```
; ; S   |  G , m  |  R ;
        Kri  shna-  nee   bE- -
```

Reading it: two beats of rest (anagata eduppu), `S` on beat 3, `G` on beat 4
with its karvai, `m` on beat 5, `R` on beat 6 held through beat 7. The `m` is
in a `G → M → R` descent, so it is **Ma1**.

In our format:

```
{melody} , , Sa | Ga3 Ma1 | Ri2 ,
```

Seven beats, grouped 3 + 2 + 2. Verified against `MelodyParser`.

---

## Sources

### [source] — Ramesh Mahadevan, *A Gentle Introduction to Carnatic Music*

Four parts, hosted at shivkumar.org. Every **[source]** rule above was verified
against these by direct quote.

* [Part I](https://www.shivkumar.org/music/basics/ramesh/gentle-intro-ramesh-mahadevan-I.htm)
  — swaras, the 12 svarasthanas table, poorvaangam/uttaraangam, octave dots,
  sruti and kattai, the 22-sruti scheme
* [Part II](https://www.shivkumar.org/music/basics/ramesh/gentle-intro-ramesh-mahadevan-II.htm)
  — the 72 melakartas, sampoorna, janya ragas, arohana/avarohana, vakra
* [Part III](https://www.shivkumar.org/music/basics/ramesh/gentle-intro-ramesh-mahadevan-III.htm)
  — kalam speeds, tala beat counts, eduppu, sangati, composition forms
* [Part IV](https://www.shivkumar.org/music/basics/ramesh/gentle-intro-ramesh-mahadevan-IV.htm)
  — raga classification, vaadhi/samvaadhi, concert structure

**What these four do NOT contain** — checked explicitly, all absent:

| Missing | Where this document gets it |
|---|---|
| bhashanga, anya svara, vishesha prayoga | **[lakshana]** |
| madhyama sruti | **[lakshana]** |
| anagata eduppu (the term) | **[lakshana]** |
| any meaning for uppercase vs lowercase | **[derived]** |
| any symbol for note duration (`;`, `,`) | **[derived]** |
| arohana/avarohana in Part I, or tala in Part II | — they are in II and III |

That last row matters: **the introduction teaches the theory but never explains
how notation is written down.** Anyone reading it and then opening a krithi
notation page will find symbols the text never mentions.

### [source] — karnatik.com notation symbols

* [karnatik.com/symbols.shtml](https://www.karnatik.com/symbols.shtml) — defines
  `,` `;` `|` `||` `-` `~` `*`, case as octave, and ruled groups as speed.
* [shivkumar.org/music/basics/sarali-varisai.htm](https://www.shivkumar.org/music/basics/sarali-varisai.htm)
  — beginner exercises in Mayamalavagowla, adi tala. Credits *"Notation
  Courtesy: Rani, www.karnatic.com"* and states *"Capitalized letters are in the
  higher octave"*. Its legend covers the seven letters and the octave rule only;
  it never defines `;` `,` `|` or `-`.

**Read §4a before using either.** These describe the *beginner exercise* pages.
They do not fit the krithi notation this app's sample song came from — the
krithi page credits karnatik for lyrics only and carries no legend.

### [source] — Ramya, "How to read notations in Carnatic music"

* [ramyasspace.wordpress.com/2011/06/24/64/](https://ramyasspace.wordpress.com/2011/06/24/64/)
  (24 June 2011). **The key citation for §4.** Defines `,` `;` `|` `||` `-`,
  underlines, wavy lines, octave dots and the tala marks `X` / ✔ / finger counts,
  and states the case-as-duration rule outright. It also names the competing
  convention — *"some websites also use upper case to denote upper octave
  swara"* — and it cites shivkumar.org as a reference, which is where the krithi
  notation used here comes from.

  Direct fetching returns **HTTP 403**; the content was read from screenshots
  supplied by the user.

### [lakshana] — raga grammar

Standard treatises, as cited by the user when these rules were established:
*Sangita Sampradaya Pradarsini* (Subbarama Dikshitar) for the madhyama-sruti
raga classification, and *South Indian Music, Book IV* (P. Sambamoorthy).

### [derived] — fitted from real notation

From the notation of *Krishna Nee Begane Baaro* (shivkumar.org, lyrics courtesy
karnatik.com), fitted against misra chapu. See
[change_log/20260822_000000_krishna-authentic-carnatic-transcription.md](../change_log/20260822_000000_krishna-authentic-carnatic-transcription.md)
for the full working.

## Related

* [features.md](features.md) §2.8 — the melody line feature as shipped
* [architecture.md](architecture.md) — where `MelodyParser` and
  `SwaraNotation` sit
* [lib/services/swara_notation_service.dart](../lib/services/swara_notation_service.dart)
* [lib/services/melody_parser_service.dart](../lib/services/melody_parser_service.dart)
