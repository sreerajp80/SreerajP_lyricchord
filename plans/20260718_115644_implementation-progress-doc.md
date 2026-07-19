# Plan — Create implementation_progress.md

**Status:** completed

## Issue

The build plan [docs/implementation_plan.md](../docs/implementation_plan.md) is a
point-in-time document. It says (lines 15–16) that live progress should be
tracked in a **separate `implementation_progress.md` checklist**, but that file
does not exist yet. There is no single place to see what is done and what is next.

## Files to change

- **Create** `docs/implementation_progress.md` (new file only). No other files change.

## The plan for the fix

Create `docs/implementation_progress.md` as a live checklist that mirrors the 8
phases (0–8) plus the whole-project Definition of Done from
`implementation_plan.md`.

Structure:
- Short header explaining this is the live tracker; the plan file stays the
  source of scope.
- A "Current status" line: **Phase 0 complete; Phase 1 next** (from the latest
  git commit `99d94a8 Phase 0 is completed`).
- One section per phase (0–8) with:
  - a phase status marker (Done / In progress / Not started),
  - the phase's "Definition of Done" items as `- [ ]` checkboxes.
- Phase 0 marked **Done** with its boxes checked `- [x]` (git says it is done).
- Phases 1–8 marked **Not started** with unchecked boxes.
- The whole-project Definition of Done checklist at the end (all unchecked).

Rule to record in the file: update this checklist as each phase finishes; do not
rewrite `implementation_plan.md`.

## Out of scope

- No code changes.
- No edits to `implementation_plan.md` itself.
