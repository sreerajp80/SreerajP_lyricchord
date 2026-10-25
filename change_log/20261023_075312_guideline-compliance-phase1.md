# Change log: Guideline compliance — Phase 1 (docs and repository hygiene)

Implements Phase 1 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)

The user approved Phase 1 but gave no answers to questions Q1–Q8. Every value that depends on
them is written as `TODO — needed before <gate>`; nothing was guessed. Gap B2 (email address in
two old files) is left unchanged until Q4 is answered.

## What changed

### New files

- `docs/PROJECT_PROFILE.md` — filled in from the template. Values read from the code are marked
  "(from code — please confirm)". Stores, publisher, support contact, website, privacy policy
  URL, copyright, licence and the About badge are `TODO`.
- `.github/workflows/ci.yml` — checks only: `pub get`, `build_runner`, a generated-file
  staleness check, format check, `flutter analyze`, `flutter test`. Flutter pinned to 3.47.6.
  `permissions: contents: read`, no secrets, no release builds.
- `.github/dependabot.yml` — weekly `pub` and `github-actions` updates.
- `PRIVACY.md` — a draft privacy policy based on the offline design. The contact line is `TODO`.

### Rewritten or updated docs

- `docs/GUIDELINES_MANIFEST.md` — replaced with an exact copy of the submodule file.
- `README.md` — replaced the default Flutter text with prerequisites, setup (with the
  submodule), run, checks, code generation and the "generated files are committed" policy, how
  to add a migration, and release build commands.
- `docs/release_process.md` — restructured to the template's numbered sections (§1 scope …
  §8 checklist, §9 Android, §10 iOS, §12–§15). All existing project content kept (keystore
  steps, `aapt2` checks, the ML Kit permission note).
- `docs/security.md` — new §6 "Data Retention And Purge Policy" (retention table, purge,
  backup). The missing in-app "Delete all data" action is recorded as a gap (Phase 7). The
  checklist became §7.
- `docs/architecture.md` — schema version corrected from 9 to 11, with versions 10 and 11
  added to the migration table.
- `docs/workflow_rules.md` — new §5 (submodule is read-only) and §6 (CI is checks +
  Dependabot only); Communication became §7.
- `CLAUDE.md` and `AGENTS.md` — Stores and Languages rows; Flutter 3.47.6 / Dart 3.13.5 from
  `flutter --version`; `PROJECT_PROFILE.md` and `platform_store_readiness.md` in the docs
  table; versioned symbol folders and the iOS build command; a Build flavors section; sections
  put in the guideline's order; localization rules for tooltips, short labels, `material_ui`,
  `supportedLocales` and the About screen; workflow rules 4 and 5. `AGENTS.md` mirrors
  `CLAUDE.md` with only the agent-name wording changed.

### Plans and change logs

- `change_log/20260808_214800_swara_notation_engine.md` — absolute `file:///` links changed to
  relative `../` links.
- Renamed 8 files that had no time in their name to `20260822_000000_<slug>.md` (the original
  time is unknown, so `000000` is used): 3 in `plans/`, 5 in `change_log/`. Links to them in
  those files, in `docs/carnatic_notation.md` and in
  `plans/20260901_070119_melody-phase-3-gamaka-and-tuning.md` were updated.
- `plans/20260903_072500_pitch-drone-playback-fixes.md`: `Proposed` → `completed` (its change
  log exists). `plans/20260903_202800_fix_text_import_line_breaks.md`: `complete` →
  `completed`.
- `plans/20260724_214500_pdf-save-dialog-filename.md` still says `approval_pending`; left for
  the user to decide (no change log exists for it).

### Repository hygiene

- `.gitignore` — added `*.apk`, `*.aab`, `*.ipa`, `*.p12`, `*.pfx`, `*.p8`, `*.mobileprovision`,
  `*.provisionprofile`, `.flutter-plugins`.
- `analysis_options.yaml` — added `prefer_const_declarations`, `avoid_redundant_argument_values`,
  `noop_primitive_operations`, `use_enums`. The 90 new hits were fixed with `dart fix --apply`
  (91 fixes in 34 files: redundant default arguments removed, 3 `final` → `const`, one no-op
  `.toInt()` removed, one unused import removed, and `_BarreTemplate` in
  `lib/services/chord_shape_service.dart` turned into an enum — its comment was put back by
  hand). No generated file was touched.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 985 tests passed.
- `build_runner` and `flutter gen-l10n` re-run: `lib/data/app_database.g.dart` and the
  generated l10n files did not change, so the CI staleness check will pass once the current
  work is committed.
- No Android build was run, so no Gradle daemons were started.

## Follow-up: the user's answers (same day)

The user then answered Q1–Q8. The answers were written into the Phase 1 docs:

- `docs/PROJECT_PROFILE.md` — Android ships on Google Play and as a direct APK; iOS is not
  decided yet. Declared languages are English, Malayalam and Sanskrit, with the
  `sanskrit_malayalam` language pack, the language picker, the Sanskrit fallback delegate and
  the Play listing languages (English and Malayalam). The About badge is on; its wording is
  still `TODO`. The support contact is the public address the user confirmed. `Production App
  Extension` confirmed. Privacy policy URL, publisher, website, copyright and licence stay
  `TODO`.
- `CLAUDE.md` / `AGENTS.md` — Platforms, Stores and Languages rows; localization rules for
  three languages, the language pack, the picker, the `sa` fallback delegate,
  `formattingLocale(...)`, the 22-character budget for Malayalam and Sanskrit, and the badge.
- `docs/release_process.md` — release profile `public`; channels Google Play and direct APK;
  store gates §1 and §2; a three-language localization checklist; iOS section marked "not
  decided".
- `PRIVACY.md` — the contact line now holds the public support address.
- `docs/security.md` — the "Delete all data" gap now points to Phase 8.
- Gap B2 is closed: Q4 confirmed the address is public, so the two old files stay as they are.
- The plan was revised (new Phases 5, 9 and 10; old Phases 5–7 renumbered) and set back to
  `approval_pending`.

No Dart code changed in this follow-up, so the checks above still hold.

## Not done (later phases or waiting for the user)

- `TODO` values still open: privacy policy URL, publisher, website, copyright line, licence,
  badge wording, native-reader reviewers, and anything iOS.
- Phases 2–10 of the plan.
- The `docs/guidelines` submodule pointer change from the earlier update is still not
  committed; that is for the user to do.
