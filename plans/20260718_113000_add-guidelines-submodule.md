# Plan — Add Flutter Guidelines as a Git Submodule

**Status:** completed

## What the issue is

This project (`SreerajP_lyriccord`) is a fresh Git repo with no commits and no remote.
The `docs/` folder holds only `GUIDELINES_MANIFEST.md`. That manifest points to shared
guideline documents that are supposed to live at `docs/guidelines/`, but that folder does
not exist yet. Every path in the manifest (e.g. `docs/guidelines/guideline.md`) is
therefore broken until the guidelines repository is attached.

## The plan for the fix

Add the shared guidelines repository as a Git submodule at `docs/guidelines/`, following
step 2 of the manifest.

- Repository URL: `https://github.com/sreerajp80/Flutter_Guidelines`
- Submodule path: `docs/guidelines/`

Steps:
1. Run `git submodule add https://github.com/sreerajp80/Flutter_Guidelines docs/guidelines`
   from the project root.
2. Confirm the submodule was cloned and that the manifest's referenced files now resolve
   (spot-check `docs/guidelines/guideline.md` and `docs/guidelines/README.md`).
3. Leave the resulting changes staged but **not committed** (this repo has no commits and
   no remote yet; committing is a separate decision for you to make).

## Files to be changed

- `.gitmodules` — created by `git submodule add` (new file at project root).
- `docs/guidelines/` — new submodule gitlink entry + cloned working tree.
- `.git/config` — submodule registration (internal git metadata, not a tracked file).

## Notes / risks

- Network access is required to clone from GitHub. If the environment has no network or the
  repo is private without credentials, the clone will fail; I will report the error rather
  than work around it.
- I will not create an initial commit or add a remote unless you ask.
