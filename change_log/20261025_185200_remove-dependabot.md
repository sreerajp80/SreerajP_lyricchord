# Change log: Remove Dependabot from LyricChord

Implements plan: `plans/20261025_184344_remove-dependabot.md`

## Why

The owner does not want Dependabot's automatic weekly update branches and pull requests in
any project.

## What changed

- `.github/dependabot.yml` — deleted. Dependabot no longer opens version-update branches for
  this repository.
- `.github/workflows/ci.yml` — removed the "Dependabot keeps action versions current" comment.
  No change to what CI runs.
- `CLAUDE.md` and `AGENTS.md` — `.github/` is now described as "CI checks only". Workflow
  rule 5 is now "CI is checks only" and says Dependabot is not used, even though engineering
  standard §19.2 asks for it; dependencies are updated by hand, each with its own plan.
- `docs/workflow_rules.md` — §6 renamed to "CI Is Checks Only"; the Dependabot sentence is
  replaced with the "not used; update by hand" rule.
- `docs/release_process.md` — "runs only checks and Dependabot" → "runs only checks".
- `docs/PROJECT_PROFILE.md` — CI checks row now reads "analyze/test only (no Dependabot)".

## Checks

- `.github/` now holds only `workflows/ci.yml`.
- Outside `docs/guidelines/`, `plans/` and `change_log/`, the only mentions of Dependabot left
  are the new notes that say it is not used.
- No Dart code changed, so `flutter analyze` and `flutter test` are not affected.

## Not done here

- The shared guidelines submodule (`docs/guidelines/`) still says Dependabot is a MUST
  (engineering standard §19.2). That needs its own change in the guidelines repository.
- GitHub's "Dependabot security updates" account setting is separate from this file and is
  turned off by the owner on GitHub.
