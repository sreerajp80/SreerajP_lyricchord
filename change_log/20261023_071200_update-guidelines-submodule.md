# Change log: Update the Flutter_Guidelines submodule

Implements plan: [../plans/20261023_070625_update-guidelines-submodule.md](../plans/20261023_070625_update-guidelines-submodule.md)

## What changed

- `docs/guidelines` submodule moved from `7e664ba` to `34dfd4a` (upstream `master`, 12 commits).
  This was a fast-forward. No file inside the submodule was edited.
- The new submodule version is not committed yet in the parent project.

## New guideline rules that may affect this project (not applied here)

These need their own plan if we want to adopt them:

1. **Submodule is read-only** (`DOCS_FOLDER_GUIDELINE.md` §1, §1.1). Only the user updates the
   submodule version. The `CLAUDE.md` / `AGENTS.md` templates now have a workflow rule for this.
2. **CI is checks + Dependabot only** (engineering standard §19). The `CLAUDE.md` / `AGENTS.md`
   templates now have a workflow rule for this. If the project adds CI, it must follow §19.
3. **Flutter 3.47+ toolchain notes** — `material_ui` / `cupertino_ui` imports, AGP 9 / Gradle 9
   baseline, built-in Kotlin. These apply only after this project upgrades from Flutter 3.44.
4. **Identity table** in the templates now says to read SDK versions from `flutter --version`
   instead of writing them from memory.
5. New files: `AI_AGENT_START_HERE.md`, `PROJECT_PROFILE_TEMPLATE.md`,
   `platform_store_readiness.md`, `language_packs/sanskrit_malayalam.md`.
