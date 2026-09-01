# Krishna Nee Begane Baaro — markers now match the melody, one spelling throughout

Date: 2026-08-21

Implements [plans/20260821_183500_krishna-marker-melody-mismatch.md](../plans/20260821_183500_krishna-marker-melody-mismatch.md).

---

## Why

The user saw the pallavi on screen showing `Sa  Ma  Sa` above the words while
the melody player below showed `P , M2 G3 R2 S ,` — two rows for the same line
saying different things. The markers were leftover placeholder text from before
the melody lines were added, and had never been checked against them.

## What changed

### `lib/services/swara_notation_service.dart`

Taught the app the spelling `Da` for the sixth swara, so `Da2` means the same as
`Dha2` and `D2`. Three additions:

* `Da` in `_swaraAliases` — so `isSwaraToken('Da2')` is true and a swaram line
  written with `Da2` is still recognised as a swaram line.
* `'da': 'D'` in `_letterByName` — so `Da2` folds down to `D2`.
* `'da': 9` in `_shuddhaByName` — so a bare `Da` places at the right pitch.

`Dha`, `Dh` and `D` all keep working, so nothing a user has already written
changes.

### `lib/data/app_database.dart`

Rewrote `_krishnaNeeLyrics`:

* **Every marker now names the note the melody plays** at the start of that
  beat group. All ten lyric lines were wrong before, not just the pallavi.
* **One spelling everywhere.** Markers, melody lines and the swaram block all
  use full swara names with the variant digit — `Sa Ri2 Ga3 Ma2 Pa Da2 Ni3`.
  The melody lines used to use short letters (`G3`, `D2`), which disagreed with
  the markers beside them.
* **`Dha2` is now `Da2`** throughout, including the swaram block.
* The bare `Ma` in charanam 3 is now `Ma1`, so it is clear it is the plain
  madhyamam and not the `Ma2` the rest of the raga uses.

The pallavi went from

```
[Sa]Krishna nee be[Ma]gane baa[Sa]ro
{melody} P , M2 | G3 R2 | S ,
```

to

```
[Pa]Krishna [Ga3]nee be[Sa]gane baaro
{melody} Pa , Ma2 | Ga3 Ri2 | Sa ,
```

The `Ga3` marker sits on **"nee"** because a Carnatic analysis the user supplied
showed the words fall as `P , M2` = "Kri - shna", `G3` = "nee", `R2` = "be",
`S ,` = "gane baaro". That analysis confirmed the melody notes, the
swarasthanas and the 7-beat misra chapu split were already correct; only the
marker position needed moving.

### Tests

* `test/services/swara_notation_service_test.dart` — new group covering the
  `Da` spelling: `Da`/`Da2`/`Da1`/`Da3` place where the `Dha`/`D` forms do, `Da`
  is a swara token, a swaram line written with `Da2` is recognised, and the old
  spellings still work.
* `test/services/melody_parser_service_test.dart` — new group: a full-name
  melody line parses identically to the short-letter line, `Da2` matches `D2`,
  and full names keep their octave marks (`Sa'`).
* `test/repositories/song_repository_test.dart` — the v10 assertions were
  pinned to the old marker text; updated to the new text. The line count check
  now counts any line opening with a marker rather than only `[Sa]`.
* `test/helpers/fake_song_repository.dart` — the fake song's line and melody
  updated to the new spelling.

### `docs/features.md`

Recorded that the sample song uses one spelling throughout and that each marker
names the note the melody plays; noted that `Da`, `Dha` and `D` are all accepted.

## Two corrections to the plan, found while implementing

The plan's marker table had the wrong note for the last group of two lines. The
third beat group of pallavi line 2 is `Ma2 Ga3` and of charanam 1 line 2 is
`Ma2 Ga3` — both start on **Ma2**, not Ga3 as the table said. The code uses
`Ma2`, which is correct.

## No schema bump

Schema version 10 and the new song text were still uncommitted working-tree
changes from earlier the same day, so nothing had shipped with the wrong text.
This is an edit to the version 10 seed, not a new version. Version 9 devices
still upgrade correctly — `_rewriteKrishnaSample()` matches on
`_krishnaNeeLyricsV9`, which was not touched.

## An accident during this change, and the recovery

While implementing, I ran `git checkout -- lib/data/app_database.dart`
intending only to inspect the file. It is a destructive command and it reverted
the file to the last commit, **destroying the uncommitted schema-v10 work** from
earlier the same day: `schemaVersion => 10`, the `from < 10` upgrade step,
`_rewriteKrishnaSample()`, `_krishnaNeeLyricsV9`, and the new song text. The
change had never been staged, so git held no copy of it.

Recovery attempts that failed: VS Code local history (empty), `git fsck`
dangling blobs (none matched), `git stash` (empty).

It was rebuilt from surviving sources:

* `test/repositories/song_repository_test.dart` was untouched and holds the
  exact pre-v10 text as its `oldText` constant — that is where
  `_krishnaNeeLyricsV9` came back from, verbatim.
* The same test file pins the whole v10 contract: the upgrade replaces the old
  seeded text, leaves an edited song alone, does not reorder the songbook, and
  every melody line parses to exactly 7 beats.
* `_rewriteKrishnaSample()` was rebuilt from its body as quoted in the plan
  discussion, following the style of the neighbouring
  `_rewriteClassicalSongsInSwaraNotation`.

All of it is verified by the surviving tests, which pass. The lesson worth
keeping: never run `git checkout --` on a file holding uncommitted work.

## Checks

* `flutter analyze` — clean, no issues.
* `flutter test` — all 702 tests pass.
* `dart format` — applied.

## Still open — raised with the user, not acted on

A reference the user supplied (shivkumar.org) disagrees with the shipped text on
two points, both left unchanged pending a decision:

1. **Anupallavi.** That source treats "Begane baaro mukhavannu thoro" as a
   separate **Anupallavi** section. Our text keeps it as the pallavi's second
   line.
2. **Shuddha madhyamam in the descent.** The avarohana it gives is
   `S' N3 D2 P M2 G3 M1 R2 S` — with `M1` between `G3` and `R2`. Our descending
   phrases mostly go `Ga3` straight to `Ri2`. Two reads of that page gave
   contradictory answers about whether `M1` really appears in the notation body,
   so this needs a human eye on the source before anything changes.
