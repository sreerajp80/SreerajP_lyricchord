# Krishna Nee — decoding the supplied notation

**Status:** completed

Date: 2026-08-21

Follows [plans/20260821_194500_krishna-madhyama-sruti-notation.md](20260821_194500_krishna-madhyama-sruti-notation.md)
(status `partial_completion`).

---

## Method

The user supplied the full notation, the raga details, screenshots with the
original formatting, and an explanation of the duration symbols. Rather than
reading 66 avartas by eye, the duration rules were **fitted numerically**: try
candidate values for each symbol, and count how many avartas come out as
misra chapu's 3 + 2 + 2.

## The rule set — verified on all 66 avartas

| Symbol | Duration | How it was established |
|---|---|---|
| uppercase note (`S`, `G`, `P`) | 1.0 matra — first speed | user |
| lowercase note (`s`, `g`, `p`) | 0.5 matra — second speed | user |
| **underlined** token (`dpP`, `mdpp`) | half again — third speed | fitted, see below |
| `;` | **1.0** matra | fitted |
| `,` | **0.5** matra | fitted |
| `-` | continuation, no duration | assumed |

Fit results:

```
rule                                  avartas at exactly 3+2+2
every symbol = 1 beat                        34 / 66
';'=1 beat, ',' = karvai sharing a beat      37 / 66
';'=1.0, ','=0.5, lowercase=0.5              57 / 66
  + underline = one speed faster again       66 / 66   <-- all of them
```

The `;`/`,` values are worth noting because they **differ from the user's own
summary table**, which gave `;` = 2 matras and `,` = 1. Those values fit only
0–1 avartas. The user's *worked examples* used `;` = 1, and that is what the
data supports. Their examples were right; the summary table was not.

The underline was the last piece: the 9 remaining misfits were all the tokens
shown underlined in the screenshots — `dpP` and `mdpp`. Treating underline as a
further speed doubling took the fit to 66/66.

## Our format can carry this, with one small loss

Of **397 notes, only 5 straddle a beat boundary** (1.3%), in 4 avartas:

| Avarta | Group | Note |
|---|---|---|
| P1a.2 | `, R ,` | R starts 0.5 into the beat |
| P2a.2 | `nN ,` | N starts 0.5 in |
| C3c.2 | `G r G r` and `m P ,` | G, P start mid-beat |
| C4d.2 | `G r G r` | G starts mid-beat |

Our `{melody}` format treats a beat as atomic — several notes can share a beat,
but a note cannot start halfway through one and run into the next. Those 5 notes
would shift by half a beat. Everything else converts exactly.

## Blocker: how to tell M₁ from M₂

**This corrects an earlier conclusion of mine.** I previously said lowercase `m`
is shuddha madhyamam (M₁) and uppercase `M` is prati madhyamam (M₂), reasoning
from the avarohana. **That was wrong.** The duration fit proves case marks
*speed*, not variant — if `m` and `M` were variants, the 66/66 fit would not hold.

So the notation does not mark which madhyamam is meant, and Yamunakalyani has
both:

* ARO: `S R₂ G₃ P M₂ G₃ P D₂ N₃ D₂ Ṡ`
* AVA: `Ṡ N₃ D₂ P M₂ G₃ **M₁** R₂ S`

Where the letter sits:

| | count | context |
|---|---|---|
| uppercase `M` | 5 | **always** `G → M → P` |
| lowercase `m` | 63 | many contexts: `g m G` (10), `g m d` (8), `G m R` (6), `g m P` (6), … |

The `G m R` occurrences are the avarohana's `G₃ M₁ R₂` — those are M₁. The rest
are presumably M₂. But that is a raga-grammar judgement, and making it silently
across 63 notes is exactly the kind of guess that started this thread.

**Question for the user:** is the rule "M₁ only in the descending `G → m → R`
phrase, M₂ everywhere else", or is it more subtle?

## Also: caraNam 1 has no notation

The supplied notation covers Pallavi, Anupallavi, and caraNam **2, 3 and 4**.
There is no notation block for caraNam 1 ("kaalaalandhugE gejje nIlada baavuli"),
though its lyrics are given. So caraNam 1 would ship with words and no melody
unless its notation is supplied.

## Settled

* **Sangatis: first only.** The user agreed. The source gives three sangatis for
  the pallavi and five for the anupallavi; only the first of each is transcribed.
* `;` needs **no** parser change — our `,` already means "hold one beat".
* Two-letter swara names throughout, per the user's standing rule.

## Conversion, once the M₁/M₂ rule is known

* `;` → `,`
* `X ,` → `Ga3-,`
* a clump of fast notes → hyphen-joined notes in one beat (`Sa-Ni3`)
* underlined clump → the same, one beat, with the extra notes packed in
* every swara two-letter (`Sa Ri2 Ga3 Ma1 Ma2 Pa Da2 Ni3`)

Worked and tested example — the pallavi's opening avarta, using the user's own
beat table:

```
{melody} , , Sa | Ga3-, Ma1 | Ri2 ,        (parses clean, exactly 7 beats)
```

## Files to change

None yet. Analysis only; no project file is touched until the M₁/M₂ rule is
settled.

## Checks

* Reproducible: `scratchpad/beats.py`, `beats2.py`, `beats3.py` over
  `scratchpad/notation.txt`.
* `flutter analyze` clean, `flutter test` 701 passing as of
  [change_log/20260821_201500](../change_log/20260821_201500_krishna-madhyama-sruti-strip-melody.md).
