# Change log — smaller, tighter swaram lines

**Plan:** [plans/20260808_232819_compact-swaram-lines.md](../plans/20260808_232819_compact-swaram-lines.md)

## Why

In songs with a `Swaram:` block, the swaram rows were drawn at the full lyric
size with extra letter spacing. A long phrase like
`Sa - Sa - Pa - Pa - | Ma - Ma - Sa - Sa -` ran off the right edge of the phone
screen and the two rows sat far apart.

## What changed

**`lib/widgets/chord_sheet_view.dart`**

The swaram text style is now compact:

- font size: full lyric size → `fontSize * 0.8`, the same scale as the chord
  badges, so the sheet keeps one visual scale.
- letter spacing: `1.2` → removed. The ` - ` beat dashes already separate the
  swaras, so the extra tracking only added width.
- line height: `1.4` → `1.15`, so the two swaram rows sit closer together.

The behaviour is unchanged otherwise: a swaram row still never wraps and still
scrolls sideways on its own, so the beat grid stays intact.

**`test/widgets/chord_sheet_view_test.dart`**

Added a test that the swaram style is smaller than the lyrics, has no letter
spacing, and uses a tight line height.

## Not changed

The seed song "Raghupati Raghava Raja Ram" has `[S] [M] [P]` marks on its lyric
lines and a separate `Swaram:` phrase that starts `Sa - Sa - Pa - Pa -`. The two
do not match each other. The app never derives one from the other, so this is a
content mismatch in the seed text, not a rendering problem. It was left alone
because fixing it means deciding which of the two is musically correct.

## Checks

- `flutter analyze` — no issues found.
- `flutter test` — all 381 tests passed.
- `dart format` — clean.
