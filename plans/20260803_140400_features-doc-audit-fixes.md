# Fix gaps found in features.md audit

**Status:** completed

## Files to be changed

- `docs/features.md`
- `docs/feature_analysis_and_innovations.md`

## What the issue is

I audited `docs/features.md` against the real code (screens, services, providers,
native Android files, recent change logs, and `pubspec.yaml`). The doc is mostly
correct and complete, but a few small problems remain:

1. **Stale number in a sibling doc.** `docs/feature_analysis_and_innovations.md`
   still says the chord transpose range is "-12 to +12". The real range, confirmed
   in `lib/services/chord_transposer.dart`, is **-11 to +11** (a full 12-semitone
   shift just repeats the same key, so it stops one short). `features.md` already
   has this right; the roadmap doc was missed when that fix was made earlier today.

2. **Unsourced Flutter version.** `features.md` states "Flutter 3.41.9" as if it
   were a confirmed fact. No file in the repo (`pubspec.yaml`, `.metadata`) actually
   records a Flutter release number — only the Dart SDK constraint (`3.11.5`) is
   pinned. The claim may well be true, but the doc should not present it as verified
   fact when it isn't visible anywhere in the repo.

3. **Undocumented exact-pinned packages.** `pubspec.yaml` pins `file_picker` and
   `package_info_plus` to exact versions (no `^`), unlike every other dependency.
   This is probably deliberate (avoiding a known plugin regression) but `features.md`
   doesn't mention it at all.

4. **No disclaimer on the roadmap doc.** `docs/feature_analysis_and_innovations.md`
   is a list of proposed, unimplemented ideas (Swara notation, capo optimizer, etc.).
   `features.md` doesn't link to it or say anywhere that it is a separate,
   not-yet-built wish list. A reader who opens both files side by side could easily
   mistake a roadmap idea for a shipped feature.

5. **App Description narrative is thinner than the feature matrix.** Section 1 of
   `features.md` frames the app around two workflows (Creation/Editing and Live
   Performance), and only mentions Setlists and Import/Export in passing, even
   though both get full sections later (§2.5 and §2.8) and are central to how the
   app is actually used (gig-day setlist running, and getting songs in/out via
   ChordPro/PDF).

## The plan for the fix

All changes are to markdown documentation only — no app code, no behavior change.

1. In `docs/feature_analysis_and_innovations.md`, change "-12 to +12" to "-11 to
   +11" so it matches the corrected value in `features.md` and the real code.

2. In `docs/features.md` §1 ("App Description"):
   - Reframe the "two core musical workflows" list into three: (a) Creation,
     Editing & Library Management, (b) Setlist & Gig Management, (c) Live Stage
     Performance & Stage Mode.
   - Add a short mention of Import/Export (ChordPro and PDF interchange) to the
     narrative, since it's one of the biggest sections in the matrix and central
     to the "notebook" pitch.

3. In `docs/features.md` §1 (Key Architecture bullet list):
   - Soften the Flutter version line to note it is the SDK the project targets per
     its own build guidelines, since no file in this repo pins an exact Flutter
     release number (only the Dart SDK constraint is pinned in `pubspec.yaml`).
   - Add a short note that `file_picker` and `package_info_plus` are pinned to
     exact versions in `pubspec.yaml` (unlike other dependencies), to avoid known
     plugin regressions.

4. Add a short line at the top of `docs/features.md` (or a note at the end)
   pointing to `docs/feature_analysis_and_innovations.md` and stating clearly that
   it is a separate, unimplemented roadmap/ideas document, not a list of shipped
   features.

After these edits, `flutter analyze` and `flutter test` are not affected since no
`lib/` code changes — this is a docs-only change, so no test run is needed.
