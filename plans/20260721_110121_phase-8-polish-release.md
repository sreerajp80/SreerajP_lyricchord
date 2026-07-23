# Phase 8 — Polish & release readiness

**Status:** completed

## What this phase is

Phase 8 from [docs/implementation_plan.md](../docs/implementation_plan.md): the final
quality pass and getting the app ready to ship. Earlier phases already built the
empty states, error `SnackBar`s, and the tablet dual-pane layout, so this phase is
about **refining** what exists, an **accessibility pass**, **verification**, and
writing the **release config + docs** (not creating the keystore itself).

Scope was confirmed with the user:

- **Release:** docs + build config only. I wire the signing config and write a local
  `docs/release_process.md`. The user creates the keystore and runs the signed build.
- **Polish:** all four items — accessibility pass, app-label fix, empty/error state
  review, and add tests.

## The issues to fix

1. **App label is wrong.** `android/app/src/main/AndroidManifest.xml` line 3 sets
   `android:label="lyriccord"` (lowercase). The launcher name should read
   **`LyricCord`** to match the brand.
2. **No release signing config.** `android/app/build.gradle.kts` signs the release
   build with the **debug** key (the Flutter default `TODO`). A real release must be
   signed with the app's own keystore, read from `android/key.properties`.
3. **No local release doc.** `guideline.md` §2 and the plan ask for a local
   `docs/release_process.md`. There is only the shared template in
   `docs/guidelines/`.
4. **Accessibility gaps.** The screens use tooltips well, but a few things are worth
   a pass: icon-only badges and chord diagrams have no semantic labels; the chord
   sheet and diagrams should be checked against large text scale; touch targets on
   the small controls should be confirmed at 48 dp.
5. **Verification.** Confirm `flutter analyze` is clean, all tests pass, and the
   built artifact has **no INTERNET permission** (CLAUDE.md hard rule 1).

## Files to change

### Code / config

- `android/app/src/main/AndroidManifest.xml` — set `android:label="LyricCord"`.
- `android/app/build.gradle.kts` — load `android/key.properties` if present and add a
  `release` signing config that uses it; fall back to the debug key only when the
  file is missing (so `flutter run --release` still works for anyone without the
  keystore). Keeps the app buildable without secrets.
- `lib/widgets/song_card.dart` — add `Semantics` labels to the key/BPM badges (e.g.
  "Key G", "120 beats per minute") so a screen reader announces them, and give the
  whole card a combined semantic label. Confirm the star/delete `IconButton`s meet
  the 48 dp target (they already use `IconButton`, which does).
- `lib/widgets/guitar_chord_diagram.dart` and
  `lib/widgets/harmonium_chord_diagram.dart` — wrap each `CustomPaint` in a
  `Semantics` node with a text label naming the chord, since a painted diagram is
  invisible to screen readers.
- `lib/widgets/chord_sheet_view.dart` — quick check for text-scale safety (no fixed
  heights that clip at large scale); adjust only if a real clip is found.
- Small empty/error-state consistency pass across `lib/screens/song_list_screen.dart`,
  `lib/screens/song_performance_screen.dart`, and `lib/widgets/empty_songbook.dart`
  — only cosmetic/label tweaks if a gap is found; no behaviour change.

### Docs

- `docs/release_process.md` (new) — the app-specific release process filled in from
  the shared template: versioning from `pubspec.yaml`, the exact release build
  commands from `CLAUDE.md`, the keystore + `key.properties` steps from
  `guideline.md` §2, and the no-INTERNET verification step
  (`aapt2 dump permissions ...`). No secrets in the file.
- `docs/implementation_progress.md` — mark Phase 8 progress: the code polish,
  accessibility, and verification done; the signed-build step left as a manual user
  task (needs the keystore).

### Tests

- `test/widgets/song_card_test.dart` (new or extended) — assert the new semantic
  labels for the badges are present.
- `test/widgets/chord_diagram_semantics_test.dart` (new) — assert the guitar and
  harmonium diagrams expose a chord-name semantic label.
- Keep the existing suite green; re-run `flutter analyze` and `flutter test`.

## The plan for the fix (order of work)

1. Fix the manifest app label.
2. Add the signing config to `build.gradle.kts` (reads `key.properties`, debug
   fallback). Confirm `.gitignore` already ignores the keystore files (it does).
3. Accessibility pass: add `Semantics` to the badges and the two chord diagrams;
   check text scale on the chord sheet; confirm touch targets.
4. Empty/error-state consistency review — apply only real gaps.
5. Write `docs/release_process.md` from the template.
6. Add/extend the tests above.
7. Run `dart format .`, `flutter analyze` (must be zero), `flutter test` (all green).
8. Update `docs/implementation_progress.md` and write the change log.

## Out of scope (needs the user, per the agreed release scope)

- Creating the keystore (`android/<name>.jks`) and `android/key.properties`.
- Producing and verifying the actual signed release artifact.

These stay as documented manual steps in `docs/release_process.md`.

## Definition of done for this phase

- `flutter analyze` clean; `flutter test` all pass.
- App label reads `LyricCord`; release signing wired to `key.properties` with a safe
  debug fallback.
- Accessibility labels added and covered by tests.
- `docs/release_process.md` exists and is app-specific.
- No-INTERNET verification step documented (manifest already has no INTERNET
  permission).
