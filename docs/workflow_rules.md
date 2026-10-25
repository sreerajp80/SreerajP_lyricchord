# Workflow Rules — LyricChord

This document defines the mandatory development workflow for LyricChord. Read it before
creating, editing, or deleting any file in the repository. Every change follows the
three-step process: plan first, obtain approval, and write a change log.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) — project overview and hard rules for Claude.
- [../AGENTS.md](../AGENTS.md) — project overview and hard rules for AI agents.
- [guidelines/DOCS_FOLDER_GUIDELINE.md](guidelines/DOCS_FOLDER_GUIDELINE.md) — documentation creation standards.

---

## 1. Plan Before Changing

Before making any source code change or creating, editing, or deleting any project file,
write a complete implementation plan.

- Plans live in `plans/` at the project root.
- File naming format: `yyyymmdd_hhMMss_<short-slug>.md` using the current timestamp.
- Every plan MUST start with a `**Status:** proposed` line and a `**Date:** yyyy-mm-dd` line.
- The plan must clearly state:
  1. What the issue or requirement is.
  2. The exact list of files to change or create.
  3. The technical approach and design decisions.
  4. The verification steps (analysis, tests, manual checks).

---

## 2. Explicit Approval Gate

Do not edit, create, or delete any project file (other than the plan file itself) until
receiving explicit user approval.

- A question, suggestion, or ambiguous reply is **not** approval.
- Only an unambiguous positive statement (such as "Approved", "Go ahead", or "Proceed")
  grants permission to execute the plan.
- If the plan changes during review, update the plan file first before starting work.

---

## 3. Log After Changing

Immediately after implementing the plan and verifying all tests pass, record the work in
a change log file.

- Change logs live in `change_log/` at the project root.
- File naming format: `yyyymmdd_hhMMss_<short-slug>.md` matching or following the plan timestamp.
- Every change log must:
  1. Reference the corresponding plan file using a relative path.
  2. List the exact files created, modified, or deleted.
  3. Explain what changed and why in simple English.
  4. Record the verification results (e.g., test outcomes, static analysis).
- Once logged, update the corresponding plan's `**Status:**` to `completed`.

---

## 4. Relative Paths And Privacy Policy

All files in `plans/`, `change_log/`, and `docs/` are committed to the repository and may
be published to public hosting platforms. They MUST protect user and system privacy.

### 4.1 Strict Privacy Rules

- Use **relative repository paths only** (e.g., `lib/main.dart`, `../plans/...`). Never use
  absolute paths containing drive letters or system URIs (`C:\...`, `l:\...`, `file:///...`).
- NEVER include **local system details**:
  - Operating system usernames
  - Host or machine names
  - User home directory paths
  - Local network share names
  - Local server URLs with ports or LAN IP addresses (`192.168.x.x`, `10.x.x.x`)
  - Device serial numbers or UDIDs
  - Personal email addresses (unless part of public config documentation)
- NEVER include **secrets**:
  - API keys or access tokens
  - Keystore passwords or alias passphrases
  - Passwords or credentials
  - Personally Identifiable Information (PII)

### 4.2 Writing Clean Paths

| Do not write | Write instead |
|---|---|
| `l:\Android\SreerajP_lyricchord\lib\main.dart` | `lib/main.dart` |
| `C:\Users\<user>\.gradle\gradle.properties` | "the local Gradle home" |
| `file:///L:/Android/SreerajP_lyricchord/plans/x.md` | `../plans/x.md` |
| `\\DESKTOP-WORK\builds\app.apk` | "the local build directory" |
| `http://192.168.1.15:8080` | "the local test server" |
| `my_password=secret123` | "the keystore password (stored outside the repo)" |

---

## 5. The Guidelines Submodule Is Read-Only

`docs/guidelines/` is a shared submodule. Never edit, pull, check out or commit it or its
version from this project. If a guideline needs a change, write a note for the user (in chat or
in `plans/`); the user makes the change in the guidelines repository and updates the submodule
version themselves ([guidelines/DOCS_FOLDER_GUIDELINE.md](guidelines/DOCS_FOLDER_GUIDELINE.md)
§1.1). If the folder is empty or missing, stop and ask the user.

---

## 6. CI Is Checks And Dependabot Only

GitHub CI (`.github/workflows/ci.yml`) runs only `flutter pub get`, code generation, the
generated-file check, the format check, `flutter analyze` and `flutter test`.
`.github/dependabot.yml` opens update pull requests for `pub` and `github-actions`; each one
still goes through plan → approve → log before it is merged. CI never builds release artifacts,
signs, holds secrets, uploads or publishes. Releases are built locally
([release_process.md](release_process.md)).

---

## 7. Communication Standard

All responses, plans, change logs, and explanations must be written in simple English:

- Use short sentences and common, everyday words.
- Explain any musical, technical, or framework jargon clearly.
- Keep bullet points focused on a single idea.
