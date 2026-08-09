# CLAUDE.md — LyricCord

This file is read by Claude Code at the start of every session in this repository.
Read it before making any change. This is a **Thin** file — see the docs table
below for the full detail; do not duplicate that detail here.

---

## Project identity

| Field | Value |
|-------|-------|
| App name | LyricChord |
| Type | A lyrics & chords notebook for musicians — write chord sheets, transpose, and auto-scroll while performing |
| Platform(s) | Android and iOS (min SDK 24 / Android 7; iOS minimum confirmed at setup). Desktop is a possible later target, not built now |
| Package / org id | `in.sreerajp.lyricchord` |
| Flutter SDK | 3.44.8 (stable) |
| Dart SDK | 3.12.2 |
| State management | Riverpod (`flutter_riverpod`) |
| Navigation | go_router |
| Database | drift (SQLite) for songs; `shared_preferences` for the theme-mode setting |
| Orientation | both |
| Connectivity | **Fully offline — no INTERNET permission, no network packages** |

> This is a like-for-like Flutter port of an existing Android app. Keep this
> table honest and current — it is the fastest way to orient.

---

## Read these docs before working

| Document | Read when |
|----------|-----------|
| [docs/lyriccord_idea.md](docs/lyriccord_idea.md) | Understanding what the app is and which features must exist |
| [docs/architecture.md](docs/architecture.md) | Changing structure, screens, state, services, models, repositories, storage, navigation |
| [docs/security.md](docs/security.md) | Touching permissions, networking, imported files, logging, or the keystore |
| [docs/implementation_plan.md](docs/implementation_plan.md) | Deciding what to build next and when a phase is "done" |
| [docs/GUIDELINES_MANIFEST.md](docs/GUIDELINES_MANIFEST.md) | The shared Flutter guidelines index |
| [docs/guidelines/guideline.md](docs/guidelines/guideline.md) | About-screen config, keystore rules, baseline `lib/` layout |
| [docs/guidelines/flutter_project_engineering_standard.md](docs/guidelines/flutter_project_engineering_standard.md) | Any code change — layers, naming, testing |
| [docs/guidelines/flutter_build_flavors_guide.md](docs/guidelines/flutter_build_flavors_guide.md) | Build config, signing, flavors, Gradle, ProGuard |
| [docs/guidelines/release_process.md](docs/guidelines/release_process.md) | Building a release (create a local `docs/release_process.md` when set up) |

> If a doc is copied into this project's own `docs/`, the local copy wins over
> the submodule template.

---

## Hard rules (must follow — these override convenience)

1. **Fully offline.** The app makes no network calls. Never add the `INTERNET`
   permission or any package that performs network I/O. See
   [docs/security.md](docs/security.md).
2. **Like-for-like port.** This re-implements the Android app; it is not a
   redesign. Match the same features, palette, and 600 dp phone/tablet
   breakpoint from [docs/lyriccord_idea.md](docs/lyriccord_idea.md).
3. **No AI features.** The Android project declared Gemini/Firebase AI but never
   used it. The Flutter app has no AI feature. If AI is ever wanted, it is a new
   project.
4. **Never crash on bad input.** The one untrusted input is an imported
   ChordPro/text file. Parse defensively, fall back to safe defaults, and surface
   failures as a `SnackBar` — never corrupt the database.
5. **Scoped storage only.** Import/export use the system file picker / share
   sheet. Never request a broad storage or any runtime permission.

---

## Architecture rules

- **Layout:** Tier 1 layer-first under `lib/` — `core/` (`config/`, `constants/`,
  `errors/`, `utils/`), `models/`, `services/`, `repositories/`, `data/`,
  `providers/`, `screens/`, `widgets/`, `theme/`, `main.dart`. Do not restructure
  or promote to feature-first without instruction.
- **Dependency direction:**
  `Widget → Provider (state) → Service / Repository → drift DAO → SQLite`.
- **Layer boundaries:** widgets must not know SQL, ChordPro syntax, or PDF
  drawing. Services must not know navigation or UI strings.
- **Models are immutable** (`copyWith`, never mutate in place).
- Full detail is in [docs/architecture.md](docs/architecture.md).

---

## Build & run commands

```bash
flutter pub get                        # install dependencies
dart run build_runner build --delete-conflicting-outputs   # generate drift code
flutter run --flavor dev               # daily development run
flutter run --flavor prod              # production config, debug tooling
flutter analyze                        # static analysis (must be clean)
flutter test                           # run all tests
dart format .                          # format before committing

# Production release APK (split per ABI)
flutter build apk --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod/ --split-per-abi

# Production Play Store bundle
flutter build appbundle --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols/android-prod/
```

> Android defines `dev` and `prod` flavors (dimension `environment`). The `dev`
> flavor installs as `in.sreerajp.lyricchord.dev` ("LyricChord Dev") so it can sit
> next to the prod app. iOS has no flavor schemes yet — run iOS without
> `--flavor` until they are set up on a Mac. Details:
> [docs/guidelines/flutter_build_flavors_guide.md](docs/guidelines/flutter_build_flavors_guide.md).

---

## Signing / keystore

- Create `android/key.properties` (gitignored — **never** commit it).
- `.gitignore` must include: `key.properties`, `*.jks`, `*.keystore`,
  `build/symbols/`.
- Keep the release keystore backed up offline — losing it means you can no longer
  publish updates under the same signature. Follow the keystore rules in
  [docs/guidelines/guideline.md](docs/guidelines/guideline.md) §2.

---

## Security rules

- Never add the `INTERNET` permission; verify the built artifact has none:
  `aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk`.
- Request **no** runtime permissions — no camera, location, contacts,
  microphone, or storage.
- Never log song content in release builds; gate verbose logs on `kDebugMode`.
- Validate imported ChordPro defensively (see Hard rule 4).
- Full posture: [docs/security.md](docs/security.md).

---

## Code style / naming

- Files `snake_case.dart`; classes `PascalCase`; variables/methods `camelCase`;
  providers `camelCase` + `Provider` suffix.
- Use `package:` imports, not relative. Prefer `const` constructors, `final`
  locals, single quotes.
- Run `dart format .` and keep `flutter analyze` at zero warnings before every
  commit.
- Never hand-edit generated files (`*.g.dart`, drift-generated `*.drift.dart` /
  `*.g.dart`). Change the source and re-run `build_runner`.

---

## Testing rules

- Mirror the `lib/` structure in `test/` (`test/services/`, `test/repositories/`,
  `test/widgets/`, plus `helpers/` and `fixtures/`).
- Add or update a test whenever you add or change a service, DAO, or repository.
- Critical areas that must be covered:
  - Chord transposition (sharps/flats, slash chords, wrap-around).
  - ChordPro import/export round-trip.
  - Chord-over-lyric line parsing (the `[C]word` renderer).
  - Tempo-Auto scroll math (ends exactly at song end).
  - Database seeding on first run.
- Detail: [docs/architecture.md](docs/architecture.md) §18.

---

## Dependency constraints

- **Blocked (never add, never accept as a transitive dep):** any HTTP client,
  cloud/BaaS, analytics, crash reporting, ads, AI/LLM, or network-status package
  — this is a fully offline app.
- Before adding any package: check its `pubspec.yaml` for networking deps, state
  why it is needed, and confirm it fits the hard rules.

---

## Where things live

```
CLAUDE.md            # this file — project rules
docs/                # design docs (architecture, security, idea, plan)
docs/guidelines/     # shared Flutter guidelines submodule (read-only)
plans/               # one plan per change (see workflow rules)
change_log/          # one log per implemented change
lib/                 # app source (see architecture rules)
test/                # tests (mirrors lib/)
```

---

## Workflow rules (mandatory — from global rules)

Every change follows plan-before-changing and log-after-changing:

1. **Plan before changing.** Write a full plan to `plans/` named
   `yyyymmdd_hhMMss_<short-slug>.md` with a `**Status:**` line, the files to
   change, the issue, and the fix. Then **STOP and get explicit approval** before
   editing/creating/deleting any project file (other than the plan). A question or
   ambiguous reply is not approval.
2. **Log after changing.** After implementing, write a change log to
   `change_log/` named `yyyymmdd_hhMMss_<short-slug>.md` describing what changed
   and referencing its plan.

Create `plans/` and `change_log/` if they do not exist.

---

## Communication rules

- **Always use simple English.** Write all responses, plans, change logs, and
  explanations in plain, simple English. Short sentences, common words. Explain
  any jargon you must use.

---

## What Claude must always / never do

**Always:** read this file first; state the target layer before adding a class;
keep `main.dart` thin; run `flutter analyze` and `flutter test` after changes;
match the Android app's behaviour and palette.

**Never:** put business logic in a widget; call a DAO or touch SQL from a widget;
edit generated `*.g.dart` / drift files; add a networking, cloud, analytics, or
AI package; add the `INTERNET` permission; log song content in release builds.
