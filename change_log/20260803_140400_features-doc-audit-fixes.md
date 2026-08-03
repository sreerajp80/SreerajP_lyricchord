# Change log: fix gaps found in features.md audit

Implements: `plans/20260803_140400_features-doc-audit-fixes.md`

## What changed

**`docs/feature_analysis_and_innovations.md`**
- Fixed a stale number: the transpose range table said "-12 to +12". The real
  range (checked in `lib/services/chord_transposer.dart`) is **-11 to +11**. This
  now matches `docs/features.md`, which already had the correct value.

**`docs/features.md`**
- Added a short note at the top pointing to `feature_analysis_and_innovations.md`
  and stating clearly that it is a separate list of *proposed, unimplemented*
  ideas, not a list of things the app currently does.
- Reframed the "App Description" from two workflows to three: Creation/Editing,
  **Setlist & Gig Management** (new, its own pillar), and Live Performance/Stage
  Mode. Setlists were previously only mentioned deep in the feature matrix
  (§2.5), not in the top-level description.
- Added a sentence about ChordPro/PDF import and export to the App Description,
  since it wasn't mentioned in the narrative at all before, only in §2.8.
- Softened the "Flutter 3.41.9" claim so it no longer reads as a fact confirmed
  by a file in this repo. No file here (`pubspec.yaml`, `.metadata`) actually
  pins a Flutter release number — only the Dart SDK constraint (`3.11.5`) is
  pinned. The doc now says this is the version targeted per the project's build
  guidelines, and explains what is and isn't actually pinned in the repo.
- Added a note that `file_picker` and `package_info_plus` are pinned to exact
  versions in `pubspec.yaml`, unlike every other dependency (likely to avoid
  known plugin regressions).

## Why

A code-vs-doc audit found that `docs/features.md` was mostly accurate and
complete (it had already been corrected once earlier today), but a few small
problems were left: a stale number in a sibling doc, an unsourced version claim,
an undocumented pinning choice, no disclaimer separating the roadmap doc from the
shipped-features doc, and an App Description narrower than the feature matrix it
introduces (Setlists and Import/Export were both under-represented in the
opening description).

## Files changed

- `docs/features.md`
- `docs/feature_analysis_and_innovations.md`

No app code (`lib/`, `android/`) was touched. `flutter analyze` / `flutter test`
are unaffected.
