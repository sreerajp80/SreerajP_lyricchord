# Update the guidelines submodule

Plan: [plans/20261025_200802_update-guidelines-submodule.md](../plans/20261025_200802_update-guidelines-submodule.md)

## What changed

- `docs/guidelines` — submodule pointer moved from `34dfd4a` to `41fa45b` (upstream
  `master`). That upstream commit removes Dependabot from the shared guidelines;
  engineering standard §19.2 now requires manual dependency updates and forbids
  `.github/dependabot.yml`. No file inside the submodule was edited.
- `CLAUDE.md` and `AGENTS.md` — Workflow rule 5 no longer says Dependabot is skipped
  "even though engineering standard §19.2 asks for it". It now says this is what §19.2
  requires.

## Checks

- `git submodule status` shows `docs/guidelines` at `41fa45b`.
- `git diff` shows only the pointer and the one sentence in each of the two files.
- No code changed, so no build, analyze or test run was needed.
