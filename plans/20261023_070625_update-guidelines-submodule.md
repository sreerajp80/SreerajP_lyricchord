# Update the Flutter_Guidelines submodule

**Status:** completed

## Files to be changed

- `docs/guidelines` (submodule pointer only — no file inside the submodule is edited)

## What the issue is

The shared guidelines submodule at `docs/guidelines` points to commit `7e664ba`.
The upstream `master` branch is now at `34dfd4a`, which is 12 commits ahead.
The newer commits include: agent intake for new projects, a stricter read-only
rule for the submodule, Kotlin notes for Flutter 3.47+ / AGP 9+, CI checks and
Dependabot notes, an accuracy review, a new `platform_store_readiness.md`, and
updates to `release_process.md` and `security.md`.

## Plan for the fix

1. In `docs/guidelines`, check out `origin/master` (`34dfd4a`). This only moves the
   submodule to the newer upstream commit; nothing inside it is edited by hand.
2. In the parent project, the submodule pointer will show as changed. Stage only
   `docs/guidelines` (plus this plan and its change log) if the user asks for a commit.
3. Quickly scan the updated guidelines for any new rule that affects this project
   and report it to the user. Any follow-up change to project files will get its
   own plan.
4. Write a change log in `change_log/`.

No build or test run is needed: the submodule holds only docs.
