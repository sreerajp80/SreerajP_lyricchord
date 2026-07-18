# Implementation Plan — SreerajP_lyriccord

The phase-by-phase build plan for the LyricCord Flutter app. Read it to know
what to build next and when a phase is "done". Each phase should end with
something you can run.

**Date:** 2026-07-18

**Read first**

- [lyriccord_idea.md](lyriccord_idea.md) — the product concept and features.
- [architecture.md](architecture.md) — the technical decisions these phases follow.
- [guidelines/guideline.md](guidelines/guideline.md) — About config + keystore + `lib/` layout.

This is a **point-in-time** document. Track live progress in a separate
`implementation_progress.md` (checklist) rather than rewriting this plan.

---

## Phase 0. Project setup

### Objective

A running, empty LyricCord Flutter app with the fixed conventions in place.

### Action steps

- Create the Flutter app with application id / namespace `in.sreerajp.lyriccord`
  (Flutter 3.41.9, Dart 3.11.5).
- Add the baseline `lib/` folders from [architecture.md](architecture.md) §4.
- Add the About-screen config exactly as
  [guidelines/guideline.md](guidelines/guideline.md) §1 requires:
  `assets/config/app_config.json`, `lib/core/config/app_config.dart` (`AppConfig`),
  `lib/core/config/config_service.dart` (`ConfigService`); register
  `assets/config/` in `pubspec.yaml`.
- Add `lib/core/constants/app_constants.dart` (db name, pref keys).
- Add core dependencies: `flutter_riverpod`, `drift` (+ `sqlite3_flutter_libs`,
  `drift_dev`, `build_runner`), `shared_preferences`, `go_router`, `pdf`,
  `printing`, a file-picker package.

### Definition of Done

- App launches to a placeholder home screen on Android and iOS.
- About screen reads from `ConfigService` and renders `details` dynamically.
- `flutter analyze` is clean.

---

## Phase 1. Foundation: data, theme, seeding

### Objective

Local storage, the theme, and seeded songs — the base every screen needs.

### Action steps

- Define the `SongNote` model (fields per [architecture.md](architecture.md) §11).
- Build the drift database and `song_notes` table (schema version 1) and the DAO.
- Build `SongRepository` exposing reactive streams (all songs, one song by id)
  and insert/update/delete.
- Seed the three classic songs on first run (Amazing Grace, House of the Rising
  Sun, Jingle Bells) with the same lyrics/keys/BPM as the Android app.
- Build the Material 3 theme in `lib/theme/` from the violet palette (primary
  `#6750A4` light / `#D0BCFF` dark), light + dark.
- Store theme mode in `shared_preferences`; wire it through a Riverpod provider.

### Definition of Done

- App opens the database, seeds on first run, and applies the saved theme.
- Repository unit tests pass against an in-memory drift database.

---

## Phase 2. Songbook (list screen)

### Objective

Browse, search, favorite, and delete songs; responsive layout.

### Action steps

- Song list with cards (title, artist, key badge, BPM badge).
- Search across title, artist, and lyrics (in-memory filter).
- All / Starred filter row with live counts.
- Favorite toggle and delete per card; empty state.
- Floating **+** to start a new song.
- Responsive: single-pane on phone (< 600 dp), dual-pane on tablet (≥ 600 dp).
- Overflow menu: Import ChordPro (wired in Phase 7) and theme choices.

### Definition of Done

- Can search, star/unstar, filter, and delete; counts update live.
- Dual-pane appears on a tablet/large window; single-pane on a phone.

---

## Phase 3. Editor

### Objective

Create and edit songs with the quick chord inserter.

### Action steps

- Editor screen: Title, Artist, Original Key, Tempo (BPM) fields.
- Distraction-free lyrics text area.
- Quick Chord Inserter toolbar with **key-aware** suggestions (major/minor key
  chords) and a **custom chord** dialog.
- Insert `[Chord]` at the cursor position.
- Save (create or update) and cancel.

### Definition of Done

- Can create a new song and edit an existing one; changes persist.
- Chord suggestions change with the entered key; custom chords can be added.

---

## Phase 4. Performance view

### Objective

The read/perform screen with transpose and display controls.

### Action steps

- Chord-over-lyric renderer (`[C]word` → chord badge above the syllable),
  including blank-line spacing and word wrap.
- Collapsible Performance Controls: transpose ±semitone (slash-chord aware,
  sensible sharp/flat spelling) with live key + reset; show-chords toggle;
  font-size control (10–32).
- Swipe left/right to move between songs in the current list (pager).
- Port `ChordTransposer` logic to a Dart service with unit tests.

### Definition of Done

- Transpose changes all chords and the shown key correctly; reset works.
- Show-chords and font-size affect the sheet live; swiping changes songs.

---

## Phase 5. Auto-scroll

### Objective

Hands-free scrolling in both modes.

### Action steps

- Manual Speed mode: play/pause and 0.5x / 1x / 2x.
- Tempo Auto mode: BPM + length (measures) → compute duration and scroll speed
  so the sheet ends exactly at song end; show duration and px/s.
- Stop auto-scroll when the bottom is reached.

### Definition of Done

- Both modes scroll smoothly (within frame budget); Tempo Auto ends at song end.

---

## Phase 6. Chord reference

### Objective

Guitar and harmonium chord diagrams.

### Action steps

- Port the guitar fret-data map and diagram drawing (open/muted strings, base
  fret) to a Flutter `CustomPainter`.
- Port the harmonium keyboard diagram.
- Chord Reference dialog with Guitar | Harmonium tabs, listing the song's chords
  transposed to the current key.

### Definition of Done

- The dialog shows correct diagrams for a song's chords in both tabs.

---

## Phase 7. Import / export

### Objective

ChordPro import/export and PDF export.

### Action steps

- `ChordProService`: parse `{title|t}`, `{artist|a}`, `{key|k}`, `{bpm|tempo}`,
  `{comment|c}`, and chorus/verse markers; format back out (with transpose when
  active). Round-trip unit tests.
- Wire Import ChordPro (file picker) into the list menu.
- `PdfExportService` using `pdf` + `printing`: title/artist/key/BPM, guitar
  diagrams for chords used, and chorded lyrics; multi-page; A4.
- Wire Export as PDF and Export as ChordPro into the detail menu.

### Definition of Done

- Import creates a song from a `.chordpro` file; export produces a matching file
  and a readable PDF; round-trip tests pass.

---

## Phase 8. Polish & release readiness

### Objective

Final quality pass and prepare to ship.

### Action steps

- Empty states, error `SnackBar`s, and tablet dual-pane refinements.
- Accessibility pass (touch targets, contrast, text scale, screen readers).
- Confirm no INTERNET permission in the built artifact (see
  [architecture.md](architecture.md) §7 and [security.md](security.md)).
- Set up the release keystore per [guidelines/guideline.md](guidelines/guideline.md)
  §2 and follow [guidelines/release_process.md](guidelines/release_process.md);
  create the local `release_process.md` when doing so.

### Definition of Done

- App passes analyze, tests, and a manual run of every feature.
- Signed release build produced; offline (no-INTERNET) verified on the artifact.

---

## Verification / Definition of Done (whole project)

- [ ] Every feature from [lyriccord_idea.md](lyriccord_idea.md) §2 works.
- [ ] Unit tests cover transpose, ChordPro round-trip, and scroll math.
- [ ] No INTERNET permission in the release artifact.
- [ ] About screen driven by `app_config.json`; keystore rules followed.
- [ ] Runs on Android and iOS.
