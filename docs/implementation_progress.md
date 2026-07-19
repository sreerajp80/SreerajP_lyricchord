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

**Current status:** Phase 2 complete. **Phase 3 (Editor) is next.**

| Phase | Title | Status |
| --- | --- | --- |
| 0 | Project setup | ✅ Done |
| 1 | Foundation: data, theme, seeding | ✅ Done |
| 2 | Songbook (list screen) | ✅ Done |
| 3 | Editor | ⬜ Not started |
| 4 | Performance view | ⬜ Not started |
| 5 | Auto-scroll | ⬜ Not started |
| 6 | Chord reference | ⬜ Not started |
| 7 | Import / export | ⬜ Not started |
| 8 | Polish & release readiness | ⬜ Not started |

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

## 5. Phase 3 — Editor ⬜ Not started

- [ ] Can create a new song and edit an existing one; changes persist.
- [ ] Chord suggestions change with the entered key; custom chords can be added.

---

## 6. Phase 4 — Performance view ⬜ Not started

- [ ] Transpose changes all chords and the shown key correctly; reset works.
- [ ] Show-chords and font-size affect the sheet live; swiping changes songs.

---

## 7. Phase 5 — Auto-scroll ⬜ Not started

- [ ] Both modes scroll smoothly (within frame budget); Tempo Auto ends at song end.

---

## 8. Phase 6 — Chord reference ⬜ Not started

- [ ] The dialog shows correct diagrams for a song's chords in both tabs.

---

## 9. Phase 7 — Import / export ⬜ Not started

- [ ] Import creates a song from a `.chordpro` file; export produces a matching
      file and a readable PDF; round-trip tests pass.

---

## 10. Phase 8 — Polish & release readiness ⬜ Not started

- [ ] App passes analyze, tests, and a manual run of every feature.
- [ ] Signed release build produced; offline (no-INTERNET) verified on the artifact.

---

## 11. Whole-project Definition of Done ⬜ Not started

- [ ] Every feature from [lyriccord_idea.md](lyriccord_idea.md) §2 works.
- [ ] Unit tests cover transpose, ChordPro round-trip, and scroll math.
- [ ] No INTERNET permission in the release artifact.
- [ ] About screen driven by `app_config.json`; keystore rules followed.
- [ ] Runs on Android and iOS.
