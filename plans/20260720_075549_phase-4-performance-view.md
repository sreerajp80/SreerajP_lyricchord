# Phase 4 — Performance view

**Status:** completed

Implements Phase 4 of [docs/implementation_plan.md](../docs/implementation_plan.md)
(lines 119–138) and the "Performance view" part of
[docs/lyriccord_idea.md](../docs/lyriccord_idea.md) §2 / §3.2.

---

## 1. What is missing today

Reading a song still opens `lib/screens/song_detail_placeholder_screen.dart`, a
"not built yet" card. There is no chord sheet renderer, no transpose engine, no
display controls, and no swiping between songs.

## 2. What Phase 4 must deliver

- A chord-over-lyric renderer: `[C]word` shows a chord badge above the syllable.
  Blank lines keep their spacing; long lines wrap by word.
- A collapsible **Performance Controls** card:
  - Transpose −1 / +1 semitone, live resulting key, and **Reset**.
  - **Show chords** toggle.
  - **Font size** decrease / increase, clamped to 10–32.
- Swipe left / right to move to the previous / next song in the current
  (filtered) list.
- A `ChordTransposer` service ported to pure Dart, with unit tests.

Auto-scroll is **not** in this phase (Phase 5). The Chord Reference and export
menu items are shown but disabled, the same way Phase 2 showed Import.

## 3. Files to change

### New — services (pure logic, no UI)

| File | Purpose |
|------|---------|
| `lib/services/chord_sheet_parser.dart` | Turns lyric text into lines of `(chord, text)` segments. Handles `[C]` markers, blank lines, and text with no chords. Never throws. |
| `lib/services/chord_transposer.dart` | Moves one chord, or a whole lyric body, by N semitones. Slash-chord aware (`C/E` → both halves move). Picks sharp or flat spelling from the target key. Reuses `sharpNotes` / `flatNotes` / `parseKey` from `chord_suggestion_service.dart` so spelling stays consistent. Unknown text is returned unchanged. |

### New — state

| File | Purpose |
|------|---------|
| `lib/providers/performance_provider.dart` | `PerformanceSettings` (semitones, showChords, fontSize) + a `Notifier` with `transposeUp`, `transposeDown`, `resetTranspose`, `toggleChords`, `setFontSize`. Session-only state (not saved to the database), matching architecture §11 which lists these as view state. |

### New — widgets

| File | Purpose |
|------|---------|
| `lib/widgets/chord_sheet_view.dart` | Renders the parsed sheet. Each segment is a small column: bold monospace chord badge in the theme **secondary** colour above its lyric chunk; segments sit in a `Wrap` so a long line wraps by word. Honours `showChords` and `fontSize`. |
| `lib/widgets/performance_controls.dart` | The collapsible controls card (`ExpansionTile`) holding transpose, show-chords, and font-size rows. |

### New — screen

| File | Purpose |
|------|---------|
| `lib/screens/song_performance_screen.dart` | The `/song/:id` screen. Top bar with back (phone only), title + artist, **edit** button, and an overflow menu (Chord Reference / Export items disabled until Phases 6–7, plus theme and About). Body = controls card + scrolling chord sheet inside a `PageView` over `filteredSongsProvider`, so a swipe moves to the next/previous song. |

### Modified

| File | Change |
|------|--------|
| `lib/core/router/app_router.dart` | Point `/song/:id` at `SongPerformanceScreen`; drop the placeholder import and its comment. |
| `lib/screens/home_shell.dart` | The tablet detail pane shows `SongPerformanceScreen(showAppBar: false)`. |
| `docs/implementation_progress.md` | Tick Phase 4, move "next" to Phase 5. |

### Deleted

| File | Why |
|------|-----|
| `lib/screens/song_detail_placeholder_screen.dart` | Replaced by the real performance view, as the file's own comment instructs. |

### New — tests

| File | Covers |
|------|--------|
| `test/services/chord_transposer_test.dart` | Up/down by semitone, wrap-around past B, slash chords, suffixes (`m7`, `sus4`, `maj7`, `dim`), sharp vs flat spelling, resulting key, and junk text left alone. |
| `test/services/chord_sheet_parser_test.dart` | `[C]word` splitting, chords mid-word, leading chord, blank lines, plain lyrics with no chords, and an unclosed `[` bracket. |
| `test/screens/song_performance_screen_test.dart` | Widget test: transpose up changes the shown chord and key, reset returns it, show-chords hides badges, font-size buttons clamp at 10 and 32. |

## 4. How it will be built

1. `chord_sheet_parser.dart` — a small scanner over each line, splitting on
   `[` … `]`. An unclosed bracket is treated as plain text (hard rule 4).
2. `chord_transposer.dart` — split a chord token into root, suffix, and optional
   `/bass`; look the root up in the sharp/flat tables; add the offset mod 12;
   write it back using the target key's spelling. Any token whose root does not
   parse is returned unchanged.
3. `performance_provider.dart` — plain Riverpod `Notifier`, reset when the
   opened song changes so a new song starts at its own key.
4. Widgets, then the screen, then the router and shell swap, then delete the
   placeholder.
5. Run `dart format .`, `flutter analyze`, `flutter test`.

## 5. Rules this follows

- Layer order `Widget → Provider → Service` — widgets get parsed segments, they
  never scan ChordPro text themselves.
- No new packages, so the offline rule is untouched.
- Parsing never throws; bad input degrades to plain text.
- Immutable models; `PerformanceSettings` gets `copyWith`.

## 6. Definition of Done

- [ ] Transpose changes all chords and the shown key correctly; reset works.
- [ ] Show-chords and font-size affect the sheet live; swiping changes songs.
- [ ] `flutter analyze` clean and `flutter test` green.
- [ ] Change log written to `change_log/`.
