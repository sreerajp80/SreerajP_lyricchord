# Krishna Nee Begane Baro — full lyrics and melody lines

**Status:** completed

Date: 2026-08-21

---

## The issue

The seeded sample song `Krishna Nee Begane Baro (Raga Yamunakalyani)` in
[lib/data/app_database.dart](../lib/data/app_database.dart) is only a stub:

* The Pallavi is right, but the second line is written `mukhathanaye baro`,
  which is not the real word. It should be `mukhavannu thoro`.
* The "Charanam" text (`Jalakaara kaalinali nartana maadidha …`) is **not from
  this song at all**. It is invented filler.
* Only one charanam is present. The song has four.
* There is no `{tala}` line and no `{melody}` line, so the new melody player
  (added on 2026-08-20) has nothing to play in the sample song. A user who
  opens the sample song cannot see what a melody line looks like.

So: yes, we can add a melody. The `{melody}` format already works end to end
(parser, beat grid, play button, humming over the drone). Nothing new has to be
built — the song text just needs to use it.

## What the new song text will be

Lyrics checked against several published sources (see "Sources" below); all of
them agree on the same four charanams.

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

Notes on the choices:

* **Tala.** Misra chapu, 7 beats (3 + 2 + 2). Every melody line above is
  exactly 7 beats, so `fitsTala` is happy and the beat grid draws three neat
  groups per line.
* **Melody notes.** Yamunakalyani is `S R2 G3 M2 P D2 N3`, with the plain `Ma`
  used on the way down (charanam 3 line 1 uses it). `S'` is upper Sa, `.N3` is
  lower Ni.
* **Honesty about the tune.** The lyrics are verified. The melody is a **simple
  singable outline** of the well-known tune written by me — it is not a
  transcription of any published notation, and a trained singer will want to
  change it. It is meant as a working example of the `{melody}` feature. If you
  would rather ship no melody than an approximate one, say so and I will drop
  the `{melody}` lines and keep only the corrected lyrics.
* **Swaram block.** The old block said plain `Ma`, which is wrong for this
  raga. It now names the exact variants.

## Files to change

| File | Change |
|---|---|
| `lib/data/app_database.dart` | Rewrite `_krishnaNeeLyrics` with the text above. Bump `schemaVersion` 9 → 10. Add a `from < 10` upgrade step that rewrites this one song. |
| `test/repositories/song_repository_test.dart` | Add a test for the v10 upgrade: the seeded song gets the new lyrics and a melody line; a song the user wrote or edited is left alone. |
| `test/helpers/fake_song_repository.dart` | Optional: give the fake song a melody line so widget tests see one. Only if it does not break existing expectations. |
| `docs/features.md` | One line: the sample classical song now ships with melody lines. |
| `change_log/…md` | Written after the change. |

## How existing phones get the new text

`schemaVersion` goes to 10 and a new upgrade step runs
`_rewriteKrishnaSample()`.

**It only rewrites the song if its lyrics still match the old seeded text
exactly.** This is stricter than the old `_rewriteClassicalSongsInSwaraNotation`
step, which matched by title alone and would happily throw away a user's own
edits. If the user has touched the song, or renamed it, or written their own
song with that title, we leave it alone.

Fresh installs get the new text straight from the seed.

## Risks

* Bumping the schema version runs the migration path on every existing phone.
  The step is a single guarded `UPDATE`, no table changes, so it is low risk.
* `test/data/app_database_migration_test.dart` builds a v8 file by hand and
  upgrades it. It should still pass, but it will be run to confirm.

## Checks after the change

* `flutter analyze` — clean.
* `flutter test` — all green.

## Sources for the lyrics

* https://dasapada.in/krishna-nee-begane-baaro-kannada-english-lyrics-meaning/
* https://shrilahari.com/krishna-nee-begane-baro-lyrics/
* http://translationsofsomesongsofcarnticmusic.blogspot.com/2010/04/krishna-nee-begane-baro.html
