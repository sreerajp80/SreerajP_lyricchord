# Project Profile — LyricChord

This file records the choices the shared guidelines leave open: platforms, stores, languages,
identity and About options. Every rule that depends on a platform, store or language applies
only when this file declares it (engineering standard §1.2.1). Read it before writing code.

**Read first**

- [../CLAUDE.md](../CLAUDE.md) / [../AGENTS.md](../AGENTS.md) — project rules.
- [guidelines/PROJECT_PROFILE_TEMPLATE.md](guidelines/PROJECT_PROFILE_TEMPLATE.md) — the template this file follows.
- [guidelines/AI_AGENT_START_HERE.md](guidelines/AI_AGENT_START_HERE.md) — §3 intake rules.

> **Where each value came from.** Values marked `(from code — please confirm)` were read from
> the existing project and still need the user's yes. Values written `TODO — needed before
> <gate>` are not known yet; treat each as a blocker for that gate. Never replace a `TODO` with
> a guess.
>
> **Privacy:** this file is committed. Only public information goes here — no passwords, keys,
> keystore details or private contact details.

---

## 0. Product brief

| Item | Value |
|---|---|
| What the app does | See §1 (short description). Full concept: [lyriccord_idea.md](lyriccord_idea.md) |
| Main features | Songbook; chord-sheet editor; transpose; performance view with auto-scroll; setlists; chord reference; ChordPro/text import and export; PDF export; metronome; pitch drone; Carnatic swara notation; AirQR song sharing; Stage Mode (from code — please confirm) |
| Who uses it | Singers and players (guitar, keyboard, harmonium), worship teams, songwriters (from code — please confirm) |
| Out of scope for now | AI features; network or cloud features; desktop platforms (from code — please confirm) |

### 0.1 Data and privacy

| Item | Value |
|---|---|
| Works offline / needs the network | Offline only — no `INTERNET` permission ([security.md](security.md) §2) |
| Backend or third-party API | none |
| User accounts / sign-in | none |
| Data the app stores, and where | Songs, setlists and notes in a local SQLite database; display settings in `shared_preferences` — device only |
| Personal, health, finance or secret data | none |
| Analytics | none |
| Crash reporting | none |
| Ads | none |
| In-app purchases or subscriptions | none |
| Device permissions | Camera — scan AirQR codes, only when the user opens the scanner |
|  | Photo picker — read one picked photo to find an AirQR code |
|  | Biometric / Face ID — unlock Stage Lock |
|  | Notification policy (Android) — let Stage Quiet Mode silence the ringer |

## 1. Identity

| Item | Value |
|---|---|
| App display name | `LyricChord` (dev flavor: `LyricChord Dev`) |
| Short description (one line) | A lyrics & chords notebook for musicians — write chord sheets, transpose, and auto-scroll while performing. |
| Organization / publisher | TODO — needed before first store release |
| Reverse-DNS app id | `in.sreerajp.lyricchord` (from code — please confirm). Permanent once published |
| Dart package name | `lyricchord` |
| Public support contact | `sreerajp@zohomail.in` (confirmed public by the user, 2026-10-23) |
| Website | TODO — needed before first store release (or `none`) |
| Privacy policy URL | TODO — needed before first store release. Draft text: [../PRIVACY.md](../PRIVACY.md) |
| Copyright line | TODO — needed before first store release |
| License of the app's own code | TODO — needed before first store release |

## 2. Applicability profiles (engineering standard §1.2)

- [x] `Core Baseline` (always)
- [x] `Production App Extension` — ships on Google Play and as a direct APK
- [ ] `Sensitive Data Extension` — not in force: no secrets, PII, health, finance or encrypted data ([security.md](security.md) §1)

## 3. Target platforms and distribution

| Platform | Ship? | Minimum OS | Distribution channels |
|---|---|---|---|
| Android | yes | `minSdk 24` (Android 7) — matches the original Android app | Google Play and direct APK |
| iOS | not decided yet — the `ios/` folder is kept | iOS 13.0 in Xcode today; must be raised to at least 14.0 (needed by `file_picker`) when iOS is declared | TODO — needed before first iOS release |
| Windows | no | — | — |
| macOS | no | — | — |
| Linux | no | — | — |
| Web | no | — | — |

Build flavors: `dev + prod` on Android (`--flavor`). iOS has no flavor schemes yet; run iOS
without `--flavor` until they are set up on a Mac.

## 4. Languages (engineering standard §8)

| Locale | Language | Script | Role | Language pack |
|---|---|---|---|---|
| `en` | English | Latin | Template ARB, ultimate fallback | — |
| `ml` | Malayalam | Malayalam | Full UI translation | [guidelines/language_packs/sanskrit_malayalam.md](guidelines/language_packs/sanskrit_malayalam.md) |
| `sa` | Sanskrit | Devanagari | Full UI translation | [guidelines/language_packs/sanskrit_malayalam.md](guidelines/language_packs/sanskrit_malayalam.md) |

- Declared by the user on 2026-10-23. **Status:** built. The groundwork came in Phase 9
  (language picker, Sanskrit fallback, fonts, checks) and the Malayalam and Sanskrit strings
  in Phase 10 of `plans/20261023_073607_guideline-compliance-audit.md`. Every Malayalam and
  Sanskrit string still needs a native reader's review before a release. Song lyrics may be
  in any script, whatever the UI language.
- App-specific terms: [glossary.md](glossary.md).
- In-app language picker: required — 3 languages (System default, `English`, `മലയാളം`, `संस्कृतम्`).
- Languages without a Flutter framework translation: `sa` (needs the fallback delegate, §8.3.1).
- Store-listing languages: Google Play — English and Malayalam (`ml-IN`). Sanskrit is not a Play
  listing language; it ships inside the app only.
- Native-reader reviewer: TODO — needed before the first release that ships `ml` or `sa`
  (a fluent Malayalam reader and a fluent Sanskrit reader; record roles, not personal emails).

## 5. About screen (`guideline.md` §1)

| Item | Value |
|---|---|
| `details` rows to show | author, email, license, aiUsed, ideUsed (from code — please confirm); privacyPolicy once the URL exists |
| Signature badge (§1.7) | `on` (user, 2026-10-23) |
| Badge text — template language | TODO — needed before the About-screen change (must contain `{heart}`) |
| Badge text — Malayalam and Sanskrit | TODO — needed before the About-screen change |

## 6. Optional project-specific values

| Item | Value |
|---|---|
| App size budget override (§10.7) | default |
| State management | Riverpod (`flutter_riverpod`) |
| Structure tier (§3.1) | Tier 1 layer-first |
| Brand colours | The original Android app's palette, held in `lib/theme/app_colors.dart` |
| Theme modes | light + dark, user-selectable (system / light / dark) |
| App icon source | Supplied — `assets/icon/app_icon.png` and `assets/icon/app_icon_foreground.png` |

## 7. Tools and workflow

| Item | Value |
|---|---|
| AI agents used on the project | Claude Code (from code — please confirm); `AGENTS.md` is kept for other agents |
| IDE | VS Code (from code — please confirm) |
| Can build iOS / macOS locally | TODO — needed before first iOS release |
| Git hosting | GitHub |
| CI checks | yes — analyze/test only (no Dependabot) (engineering standard §19) |
| Release owner (role) | The app owner |
