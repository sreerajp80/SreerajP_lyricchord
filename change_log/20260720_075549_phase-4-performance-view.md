# Change log — Phase 4: Performance view

**Date:** 2026-07-20

Implements [plans/20260720_075549_phase-4-performance-view.md](../plans/20260720_075549_phase-4-performance-view.md),
which covers Phase 4 of [docs/implementation_plan.md](../docs/implementation_plan.md).

## What changed

The read/perform screen is now real. Opening a song (`/song/:id`, and the
tablet detail pane) shows the chord sheet with transpose and display controls,
and swiping moves between songs.

### New files

- `lib/services/chord_sheet_parser.dart` — turns lyric text with `[C]word`
  markers into lines of chord/lyric segments. Pure logic; never throws. An
  unclosed or empty bracket is kept as plain text. Also lists the chords used.
- `lib/services/chord_transposer.dart` — moves a chord, a whole lyric body, or
  a key by N semitones. Slash-chord aware (`C/E` → `D/F#`). Picks sharp or flat
  spelling to match the resulting key. Reuses the note tables and key parser in
  `chord_suggestion_service.dart`. Non-chord text is returned unchanged.
- `lib/providers/performance_provider.dart` — `PerformanceSettings` (transpose
  amount, show-chords, font size) with a `Notifier`. Session-only view state,
  reset when a swipe opens another song.
- `lib/widgets/chord_sheet_view.dart` — draws the sheet: bold monospace chord
  badge (theme secondary colour) above each lyric chunk, wrapping by word.
  Honours show-chords and font size; blank lines keep their spacing.
- `lib/widgets/performance_controls.dart` — the collapsible Performance Controls
  card: transpose −/+ with live key and Reset, show-chords switch, font-size
  −/+.
- `lib/screens/song_performance_screen.dart` — the performance screen. Top bar
  with title/artist, edit button, and an overflow menu (Chord Reference and
  export items shown but disabled until Phases 6–7, plus theme and About). Body
  is a `PageView` over `filteredSongsProvider`, so swiping changes songs.

### Modified

- `lib/core/router/app_router.dart` — `/song/:id` now opens
  `SongPerformanceScreen`; dropped the placeholder import.
- `lib/screens/home_shell.dart` — the tablet detail pane shows
  `SongPerformanceScreen(embedded: true)`.
- `docs/implementation_progress.md` — Phase 4 marked done; next is Phase 5.
- `test/screens/song_list_screen_test.dart` — the dual-pane test now expects the
  real performance view instead of the old placeholder label.

### Deleted

- `lib/screens/song_detail_placeholder_screen.dart` — replaced by the real
  performance view.

### New tests

- `test/services/chord_transposer_test.dart` — up/down, wrap-around, slash
  chords, suffixes, sharp/flat spelling, key transpose, and junk text left
  alone.
- `test/services/chord_sheet_parser_test.dart` — chord splitting, mid-word
  chords, end-of-line chords, blank lines, plain lyrics, and broken brackets.
- `test/screens/song_performance_screen_test.dart` — transpose up/down, reset,
  show-chords toggle, font-size clamping, and the missing-song state.

## Verification

- `flutter analyze` — clean (no issues).
- Phase 4 tests — all pass: `chord_transposer_test.dart`,
  `chord_sheet_parser_test.dart`, `song_performance_screen_test.dart` (38 tests),
  and the edited `song_list_screen_test.dart` (12 tests).

## Notes / out of scope

- Auto-scroll (Phase 5), the Chord Reference dialog (Phase 6), and export
  (Phase 7) are not built; their menu items are shown but disabled.
- No new packages were added, so the fully-offline rule is untouched.
- A pre-existing, unrelated issue: `test/screens/song_editor_screen_test.dart`
  has a hanging/failing test on this machine. It stems from uncommitted changes
  to `song_editor_provider.dart` / `song_repository.dart` / `app_database.dart`
  that were already present before Phase 4 began; Phase 4 does not touch any of
  those files. It should be looked at separately.
- A manual run on a device has not been done yet.
