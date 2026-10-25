# Update the guidelines submodule

**Status:** completed

## Issue

The shared guidelines submodule (`docs/guidelines/`) is pinned to commit `34dfd4a`.
Its upstream `master` now has one newer commit, `41fa45b` ("Updates"). That commit
removes Dependabot from the guidelines: engineering standard §19.2 now says
"Dependencies are updated by hand, not by a bot" and forbids `.github/dependabot.yml`.

Files changed upstream (12): `AGENTS_MD_GUIDELINE.md`, `AI_AGENT_START_HERE.md`,
`CLAUDE_MD_GUIDELINE.md`, `PROJECT_PROFILE_TEMPLATE.md`,
`flutter_project_engineering_standard.md` and its README, `flutter_build_flavors_guide.md`,
`guideline.md`, `release_process.md`, `profiles/example_en_ml_sa_profile.md`, plus the
submodule's own plan and change log.

Our `CLAUDE.md` and `AGENTS.md` say Dependabot is not used "even though engineering
standard §19.2 asks for it". After the update that note is no longer true.

Note: the project rule says the submodule is read-only (never pull or change its version).
The user has asked for this update directly. No file inside the submodule is edited; only
the pinned commit in this project changes.

## Files to change

- `docs/guidelines` (submodule pointer only: `34dfd4a` → `41fa45b`)
- `CLAUDE.md` — Workflow rule 5: drop "even though engineering standard §19.2 asks for
  it"; say it matches §19.2.
- `AGENTS.md` — same line (it mirrors `CLAUDE.md`).
- `change_log/<timestamp>_update-guidelines-submodule.md` (new)

## Plan

1. In `docs/guidelines`, check out `origin/master` (`41fa45b`).
2. Edit the Dependabot sentence in `CLAUDE.md` and `AGENTS.md` to:
   "Dependabot is not used (no `.github/dependabot.yml`), as engineering standard §19.2
   requires; dependencies are updated by hand, each with its own plan."
3. `git diff` to confirm only the pointer and the two lines changed.
4. Write the change log. Do not commit unless the user asks.
