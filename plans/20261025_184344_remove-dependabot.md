# Plan: Remove Dependabot from LyricChord

**Status:** completed

## What the issue is

`.github/dependabot.yml` makes GitHub's Dependabot open a new branch and pull request every
week for each package or GitHub Action that has a newer version. The owner does not want
these automatic branches in any project. Dependabot must be removed from this project, and
the project docs must stop saying that CI uses Dependabot.

## Files to change

| File | Change |
|------|--------|
| `.github/dependabot.yml` | Delete the file. This is what turns Dependabot on. |
| `.github/workflows/ci.yml` | Line 18: drop the comment "Dependabot keeps action versions current". |
| `CLAUDE.md` | "Where things live": `.github/` comment becomes "CI checks only". Workflow rule 5: rename to "CI is checks only", remove the Dependabot sentence, and add "Dependabot is not used; dependencies are updated by hand, each with its own plan." |
| `AGENTS.md` | Same two edits as `CLAUDE.md` (it mirrors it). |
| `docs/workflow_rules.md` | §6: title "CI Is Checks Only"; replace the Dependabot sentence with the same "not used; update by hand" sentence. |
| `docs/release_process.md` | Line 184: "runs only checks and Dependabot" → "runs only checks". |
| `docs/PROJECT_PROFILE.md` | Line 134: "analyze/test and Dependabot only" → "analyze/test only (no Dependabot)". |

## Not in this plan

- **`docs/guidelines/` (shared submodule).** The engineering standard §19.2 says every
  project MUST have `.github/dependabot.yml`. This project will now differ from it. The
  submodule is read-only here, so that rule must be changed separately in the
  `Flutter_Guidelines` repository, with its own plan. Until then this project records the
  difference in `CLAUDE.md` rule 5.
- **GitHub account settings.** "Dependabot security updates" is a separate GitHub setting
  that can open branches even without `dependabot.yml`. The owner turns it off on GitHub
  (Settings → Code security). No file change is needed for that.
- **Other projects.** Each other repository needs its own plan and change.

## How to check

- `git grep -i dependabot -- ':!docs/guidelines' ':!plans' ':!change_log'` returns nothing.
- `.github/` holds only `workflows/ci.yml`.
- No Dart code changes, so `flutter analyze` / `flutter test` are not affected.

## After

Write a change log in `change_log/` and set this plan to `completed`.
