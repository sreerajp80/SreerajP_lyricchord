# Implementation Progress — LyricCord

The live checklist of what is built and what is next. This is the running tracker
that the point-in-time [implementation_plan.md](implementation_plan.md) asks you
to keep separately. The plan file stays the source of **scope**; this file tracks
**status**. Update this checklist as each phase finishes — do not rewrite the plan.

**Date:** 2026-07-18

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — project rules and workflow.
- [implementation_plan.md](implementation_plan.md) — the phase objectives and action steps.
- [lyriccord_idea.md](lyriccord_idea.md) — the features that must exist.

---

## 1. Status overview

**Current status:** Phase 8 code work complete. **The signed release build is the
only step left — it is a manual user task (needs the keystore).**

| Phase | Title | Status |
| --- | --- | --- |
| 0 | Project setup | ✅ Done |
| 1 | Foundation: data, theme, seeding | ✅ Done |
| 2 | Songbook (list screen) | ✅ Done |
| 3 | Editor | ✅ Done |
| 4 | Performance view | ✅ Done |
| 5 | Auto-scroll | ✅ Done |
| 6 | Chord reference | ✅ Done |
| 7 | Import / export | ✅ Done |
| 8 | Polish & release readiness | 🟨 Code done; signed build pending user |

---

## 2. Phase 0 — Project setup ✅ Done

- [x] App launches to a placeholder home screen on Android and iOS.
- [x] About screen reads from `ConfigService` and renders `details` dynamically.
- [x] `flutter analyze` is clean.

---

## 3. Phase 1 — Foundation: data, theme, seeding ✅ Done

- [x] App opens the database, seeds on first run, and applies the saved theme.
- [x] Repository unit tests pass against an in-memory drift database.

---

## 4. Phase 2 — Songbook (list screen) ✅ Done

- [x] Can search, star/unstar, filter, and delete; counts update live.
- [x] Dual-pane appears on a tablet/large window; single-pane on a phone.

Built on 2026-07-19 — see
[change_log/20260719_212233_phase-2-songbook.md](../change_log/20260719_212233_phase-2-songbook.md).
Still open for later phases: Import ChordPro is shown but disabled (Phase 7),
and `lib/screens/song_detail_placeholder_screen.dart` stands in for the editor
(Phase 3) and the performance view (Phase 4) — delete it then. A manual run on a
device has not been done yet.

---

## 5. Phase 3 — Editor ✅ Done

- [x] Can create a new song and edit an existing one; changes persist.
- [x] Chord suggestions change with the entered key; custom chords can be added.

Built on 2026-07-20 — see
[change_log/20260720_073000_phase-3-editor.md](../change_log/20260720_073000_phase-3-editor.md).
`/new` and `/song/:id/edit` open the real editor. Reading a song still shows
`lib/screens/song_detail_placeholder_screen.dart`, which now carries an
**Edit song** button; Phase 4 replaces that file with the performance view.
A manual run on a device has not been done yet.

---

## 6. Phase 4 — Performance view ✅ Done

- [x] Transpose changes all chords and the shown key correctly; reset works.
- [x] Show-chords and font-size affect the sheet live; swiping changes songs.

Built on 2026-07-20 — see
[change_log/20260720_075549_phase-4-performance-view.md](../change_log/20260720_075549_phase-4-performance-view.md).
`/song/:id` now opens the real performance view (`SongPerformanceScreen`), and
the tablet detail pane uses it too. The old
`lib/screens/song_detail_placeholder_screen.dart` was deleted. Auto-scroll,
the Chord Reference dialog, and export are still to come (Phases 5–7): those
menu items are shown but disabled. A manual run on a device has not been done
yet.

---

## 7. Phase 5 — Auto-scroll ✅ Done

- [x] Both modes scroll smoothly (within frame budget); Tempo Auto ends at song end.

Built on 2026-07-21 — see
[change_log/20260721_081107_phase-5-auto-scroll.md](../change_log/20260721_081107_phase-5-auto-scroll.md).
The Performance Controls card now has an Auto-scroll section: Manual mode
(play/pause + 0.5x/1x/2x) and Tempo Auto (BPM + measures → computed duration and
px/second, ending at song end). A `Ticker` in `SongPerformanceScreen` drives the
scroll and stops at the bottom; the math lives in the pure `AutoScrollCalculator`
service. Chord Reference (Phase 6) and export (Phase 7) are still disabled menu
items. A manual run on a device has not been done yet.

**Fixed after Phase 5:** the three `test/screens/song_editor_screen_test.dart`
tests that used to hang for 10 minutes each now pass — see
[change_log/20260721_093356_editor-test-hang.md](../change_log/20260721_093356_editor-test-hang.md).
The full suite (135 tests) runs in ~5 seconds.

---

## 8. Phase 6 — Chord reference ✅ Done

- [x] The dialog shows correct diagrams for a song's chords in both tabs.

Built on 2026-07-21 — see
[change_log/20260721_100622_phase-6-chord-reference.md](../change_log/20260721_100622_phase-6-chord-reference.md).
The performance view's **Chord Reference Guide** menu item now opens a dialog
with **Guitar** and **Harmonium** tabs, listing the song's chords transposed to
the current key. The pure `ChordShapeService` works out each guitar fingering
(curated open chords plus a movable barre fallback for all twelve roots) and the
harmonium keys (chord tones from the root and quality); the `GuitarChordDiagram`
and `HarmoniumChordDiagram` `CustomPainter`s draw them. No new packages — the
app stays fully offline. Import/export (Phase 7) is still a disabled menu item.
A manual run on a device has not been done yet.

---

## 9. Phase 7 — Import / export ✅ Done

- [x] Import creates a song from a `.chordpro` file; export produces a matching
      file and a readable PDF; round-trip tests pass.

Built on 2026-07-21 — see
[change_log/20260721_103433_phase-7-import-export.md](../change_log/20260721_103433_phase-7-import-export.md).
Two new pure services carry the logic: `ChordProService` reads/writes the
`{title|t}`, `{artist|a}`, `{key|k}`, `{bpm|tempo}`, and `{comment|c}` directives
(chorus/verse markers and unknown directives are dropped), and `PdfExportService`
builds an A4 multi-page sheet with a header, guitar diagrams for the chords used,
and the chorded lyrics. The list menu's **Import ChordPro** now picks a file,
parses it, saves the song, and opens it; the performance menu's **Export as PDF**
(share sheet via `printing`) and **Export as ChordPro** (save dialog via
`file_picker`) both apply the live transpose. No new packages — the app stays fully
offline. ChordPro round-trip and PDF tests pass (170 tests total). A manual run on
a device has not been done yet.

---

## 10. Phase 8 — Polish & release readiness 🟨 Code done; signed build pending

- [x] App passes analyze (clean) and tests (174 pass). Manual device run still pending.
- [ ] Signed release build produced; offline (no-INTERNET) verified on the artifact.
      **Manual user task** — needs the keystore + `android/key.properties`.

Built on 2026-07-21 — see
[change_log/20260721_110121_phase-8-polish-release.md](../change_log/20260721_110121_phase-8-polish-release.md).
Scope this phase (agreed with the user): release **docs + build config only** (I do
not create the keystore), plus all four polish items. Done:

- **App label** fixed from `lyriccord` to **`LyricCord`** in the Android manifest.
- **Release signing** wired in `android/app/build.gradle.kts`: it reads
  `android/key.properties` when present and signs with the release key, and falls
  back to the debug key when the file is absent (so a fresh checkout still builds).
  The keystore files are already git-ignored.
- **Accessibility pass:** screen-reader labels on the key/BPM badges ("Key G",
  "80 beats per minute") and on the guitar/harmonium chord diagrams (the painted
  diagrams are otherwise invisible to a screen reader). Touch targets on the
  controls are all `IconButton`s (48 dp); the performance sheet scales with its own
  font-size control.
- **Empty/error-state review:** the empty states and error `SnackBar`s were already
  consistent and context-aware from earlier phases — no changes needed.
- **Docs:** new app-specific [release_process.md](release_process.md) with the
  keystore steps, build commands, and the no-INTERNET verification.
- **Tests:** +4 widget tests for the new semantic labels (174 total).

**Still a manual step (needs the user):** create the keystore + `key.properties`,
run the signed `flutter build`, and verify no INTERNET on the artifact — all
documented in [release_process.md](release_process.md). A manual run on a device
has not been done yet.

---

## 11. Whole-project Definition of Done 🟨 Almost — signed build pending

- [x] Every feature from [lyriccord_idea.md](lyriccord_idea.md) §2 works (built
      across Phases 2–7; not yet run on a physical device).
- [x] Unit tests cover transpose, ChordPro round-trip, and scroll math.
- [x] No INTERNET permission in the manifest (verify on the release artifact at
      build time — see [release_process.md](release_process.md) §6).
- [x] About screen driven by `app_config.json`; keystore rules followed (signing
      config + ignore rules in place; keystore itself created by the user).
- [ ] Runs on Android and iOS (not yet run on a device).
