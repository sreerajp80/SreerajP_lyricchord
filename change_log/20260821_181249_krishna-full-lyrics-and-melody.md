# Krishna Nee Begane Baro — full lyrics and melody lines

Date: 2026-08-21
Implements: [plans/20260821_172211_krishna-full-lyrics-and-melody.md](../plans/20260821_172211_krishna-full-lyrics-and-melody.md)

---

## What changed

The seeded sample song *Krishna Nee Begane Baro (Raga Yamunakalyani)* was a
stub, and part of it was wrong:

* the pallavi said `mukhathanaye baro` instead of `mukhavannu thoro`,
* the "Charanam" (`Jalakaara kaalinali nartana maadidha …`) was **not from this
  song at all**,
* only one charanam was present; the song has four,
* there was no tala and no melody, so the sample song showed nothing of the
  melody feature added on 2026-08-20.

It now carries the published words — pallavi plus all four charanams — a
`{tala: Misra Chapu}` header, and a `{melody}` line under every lyric line.

## The new text

```
{raga: Yamunakalyani}
{tala: Misra Chapu}

Pallavi:
[Sa]Krishna nee be[Ma]gane baa[Sa]ro
{melody} P , M2 | G3 R2 | S ,
[Sa]Begane baaro mukha[Pa]vannu tho[Sa]ro
{melody} G3 M2 P | D2 P | M2 G3

Charanam 1:
[Sa]Kaalalanduge gejje [Pa]neelada baa[Sa]vuli
{melody} P , D2 | N3 D2 | P ,
[Sa]Neelavarnane naatya [Pa]vaadutha baa[Sa]ro
{melody} S' , N3 | D2 P | M2 G3

Charanam 2:
[Sa]Udiyalli udugejje [Pa]beralalli un[Sa]gura
{melody} G3 , M2 | P D2 | P ,
[Sa]Koralalli haakida [Pa]vaijayanti maa[Sa]le
{melody} M2 G3 R2 | S .N3 | S ,

Charanam 3:
[Sa]Kaashi peethaambara [Pa]kaiyalli ko[Sa]lalu
{melody} P , M2 | G3 Ma | G3 R2
[Sa]Poosida shreegandha [Pa]maiyola[Sa]gamma
{melody} S , R2 | G3 R2 | S ,

Charanam 4:
[Sa]Taayige baayalli [Pa]jagavannu tho[Sa]rida
{melody} P D2 N3 | S' , | N3 D2
[Sa]Jagadoddhaaraka namma [Pa]Udupi Shri Krish[Sa]na
{melody} P M2 G3 | R2 S | , ,

Swaram:
Sa - Ri2 - Ga3 - Ma2 - Pa - Dha2 - Ni3 - Sa -
Sa - Ni3 - Dha2 - Pa - Ma2 - Ga3 - Ri2 - Sa -
```

* Misra chapu is 7 beats (3 + 2 + 2). Every melody line is exactly 7 beats, so
  each one fills one cycle and the beat grid draws three tidy groups.
* Yamunakalyani is Sa Ri2 Ga3 Ma2 Pa Dha2 Ni3, with the plain Ma used on the
  way down (charanam 3, line 1). `S'` is upper Sa; `.N3` is lower Ni.
* The Swaram block used to say plain `Ma`, which is wrong for this raga. It now
  names the exact variants.
* **The words are verified; the tune is not a transcription.** The melody is a
  plain singable outline written as a worked example of the `{melody}` feature.
  A trained singer will want to change it. This is stated in the code comment
  and in `docs/features.md` so nobody mistakes it for authoritative notation.

## Files changed

| File | Change |
|---|---|
| `lib/data/app_database.dart` | `_krishnaNeeLyrics` rewritten. New `_krishnaNeeLyricsV9` holding the old text. `schemaVersion` 9 → 10 with a new `from < 10` step calling the new `_rewriteKrishnaSample()`. |
| `test/repositories/song_repository_test.dart` | New `schema v10` group: the seed carries the full words, ten lyric lines each with a melody line, every melody line parses with no problems and is 7 beats, the upgrade replaces the old text and sets the tala, an edited song is left alone, and the songbook order does not change. |
| `test/helpers/fake_song_repository.dart` | The fake seeded Krishna song now carries a tala and a melody line, matching what ships. Its `tala` field changed from `Adi` to `Misra Chapu`. |
| `docs/features.md` | One bullet under §2.8 recording that a sample song now ships with melody lines, and that the tune is an outline. |

## How existing phones get it

`schemaVersion` is 10, and the new step rewrites the song **only if its lyrics
still match the old seeded text exactly**. A song the user edited, or wrote
themselves, is never overwritten — even with the same title. This is stricter
than the older `_rewriteClassicalSongsInSwaraNotation` step, which matched by
title alone and would have thrown away the user's edits.

The write is targeted (`lyrics`, `raga`, `tala` only), not a `replace()`, so
`timestamp` is untouched and the fix does not push the song to the top of the
songbook as if it had just been edited.

Fresh installs get the new text straight from the seed.

## Checks

* `flutter analyze` — no issues.
* `flutter test` — 693 tests, all passed. This includes the existing v8 and v9
  migration tests and the hand-built v8 database file test.

## Sources for the lyrics

* https://dasapada.in/krishna-nee-begane-baaro-kannada-english-lyrics-meaning/
* https://shrilahari.com/krishna-nee-begane-baro-lyrics/
* http://translationsofsomesongsofcarnticmusic.blogspot.com/2010/04/krishna-nee-begane-baro.html
