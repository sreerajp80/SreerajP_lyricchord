# Change log — Phase 8: Polish & release readiness

**Date:** 2026-07-21
**Plan:** [plans/20260721_110121_phase-8-polish-release.md](../plans/20260721_110121_phase-8-polish-release.md)

This implements Phase 8 from
[docs/implementation_plan.md](../docs/implementation_plan.md). Scope was agreed with
the user: release **docs + build config only** (the keystore itself is not created
here), plus all four polish items (accessibility, app-label fix, empty/error-state
review, and tests).

## What changed

### App label

- `android/app/src/main/AndroidManifest.xml`: `android:label` changed from the
  lowercase `lyriccord` to **`LyricCord`** so the launcher name matches the brand.

### Release signing config

- `android/app/build.gradle.kts`:
  - Loads `android/key.properties` when it exists.
  - Adds a `release` signing config built from that file (`keyAlias`, `keyPassword`,
    `storeFile`, `storePassword`). `storeFile` resolves with `rootProject.file(...)`,
    i.e. relative to the `android/` folder.
  - The `release` build type uses that config when `key.properties` is present, and
    falls back to the debug key when it is absent, so a fresh checkout with no
    secrets still builds.
- No `.gitignore` change needed — `android/key.properties`, `android/*.jks`, and
  `android/*.keystore` were already ignored.

### Accessibility pass

- `lib/widgets/song_card.dart`: the key/BPM badges now carry full screen-reader
  wording — "Key G" and "80 beats per minute" — instead of the bare short text. Added
  an optional `semanticLabel` to the private `_Badge` for this.
- `lib/widgets/guitar_chord_diagram.dart`: the painted fretboard is wrapped in a
  `Semantics(image: true, label: ...)` node so a screen reader announces "Guitar
  chord diagram for <chord>" (or "No guitar chord diagram for <chord>" when there is
  no fingering). The diagram is otherwise invisible to a screen reader.
- `lib/widgets/harmonium_chord_diagram.dart`: same treatment — "Harmonium chord
  diagram for <chord>".
- Reviewed touch targets and text scale: the controls all use `IconButton` /
  `IconButton.filledTonal` (48 dp minimum), and the performance sheet scales with its
  own font-size control, so no clipping fix was needed.

### Empty / error-state review

- Reviewed the empty states (`lib/widgets/empty_songbook.dart`, the tablet welcome
  pane, the "song not found" state) and the error `SnackBar`s across the list and
  performance screens. They were already consistent and context-aware from earlier
  phases, so no code change was made.

### Docs

- New `docs/release_process.md`: the app-specific release process — versioning from
  `pubspec.yaml`, keystore + `key.properties` setup (from `guideline.md` §2), the
  release build commands, and a mandatory **no-INTERNET** verification step
  (`aapt2 dump permissions ...`) on the built artifact.
- `docs/implementation_progress.md`: Phase 8 marked as code-complete with the signed
  build left as a manual user task; whole-project Definition of Done updated.

### Tests

- `test/widgets/song_card_test.dart`: added a test asserting the badges expose their
  full screen-reader labels.
- `test/widgets/chord_diagram_semantics_test.dart` (new): asserts the guitar and
  harmonium diagrams (and the guitar "no shape" case) expose a chord-name image
  label.

## Verification

- `dart format .` — clean.
- `flutter analyze` — **No issues found**.
- `flutter test` — **174 tests pass** (up from 170).
- The Android manifest has **no INTERNET permission** (hard rule 1). The build-time
  check on the release artifact is documented in `release_process.md` §6.

## Left for the user (out of scope by agreement)

- Create the keystore (`android/<name>.jks`) and `android/key.properties`.
- Produce and verify the signed release build (`flutter build apk/appbundle
  --release --obfuscate ...`) and confirm no INTERNET on the artifact.
- A manual run of every feature on a physical Android/iOS device.

All of these are written up in `docs/release_process.md`.
