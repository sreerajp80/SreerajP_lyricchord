# Change log: Guideline compliance — Phase 9 (multi-language foundation)

Implements Phase 9 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gaps H2–H9). The app still shows only English: Malayalam and Sanskrit strings are Phase 10.

## What changed

### Language choice (engineering standard §8.4)

- `lib/providers/locale_provider.dart` [providers] — `localeProvider`, the one place that
  holds the app language. It reads `app_language` (`system` or a language code) from
  `shared_preferences`, which start-up loads before the first frame, so the app never shows
  the wrong language first. `null` means "follow the phone". `resolveAppLocale` picks the
  phone's language when the app has it, otherwise English.
- `lib/main.dart` — `MaterialApp.locale` follows `localeProvider`; `localeResolutionCallback`
  uses `resolveAppLocale`.
- `lib/screens/language_settings_screen.dart` [screens] — Settings → Language: System default
  first, then each language by its own name, with the current choice marked. A change is
  saved and applied at once, without a restart.
- `lib/l10n/language_names.dart` — the endonyms `English`, `മലയാളം`, `संस्कृतम्` (never
  translated).
- `lib/screens/settings_screen.dart` — new Language card after Themes; its subtitle shows the
  current choice. `lib/core/router/app_router.dart` — route `/settings/language`.
- `lib/core/constants/app_constants.dart` — `prefAppLanguage = 'app_language'`.
- New ARB keys: `titleSettingsLanguage`, `labelLanguageSystem`.
- The picker lists only languages with an ARB file (`AppLocalizations.supportedLocales`), so
  today it shows System default and English; Malayalam and Sanskrit appear when Phase 10
  adds their files.

### Sanskrit framework strings (§8.3.1, language pack §1.1)

- `lib/l10n/fallback_localizations.dart` — Material, Cupertino and Widgets delegates that serve
  English framework strings for `sa` (never Hindi). They come first in
  `appLocalizationsDelegates`.
- `pubspec.yaml` — `cupertino_ui: ^1.1.4` as a direct dependency, only for
  `GlobalCupertinoLocalizations` (it was already a transitive package; no network code).

### Number formatting (§8.3.2, §8.9)

- `lib/core/utils/formatting_locale.dart` [core/utils] — `formattingLocale(localeName)` (English
  patterns for a language `intl` does not know, such as Sanskrit) and
  `formatFixed(value, digits, localeName)`.
- Every number shown to the user now goes through it instead of `toStringAsFixed` / `toString`:
  the scroll-speed label (`formatSpeedLabel` in `lib/widgets/auto_scroll_controls.dart`, used by
  the performance controls, the gesture flash and the stage HUD), the Tempo-mode bar count in
  the stage HUD, the scroll settings screen, and the AirQR frames-per-second label.
- `CarnaticWrongLength.got` (`lib/models/carnatic_import_result.dart`) is now the number
  itself; `lib/l10n/l10n_labels.dart` formats it. The service no longer decides display text.
  No visible change in English.

### Fonts (§8.3.3, language pack §2)

- **Downloaded with the user's approval:** Noto Sans Devanagari Regular and Bold, from the
  official Noto fonts repository (The Noto Project Authors, SIL Open Font License 1.1), plus its
  `OFL.txt`. Subset with `fonttools` to the Devanagari blocks (U+0900–097F, U+1CD0–1CFF,
  U+A8E0–A8FF), the joiners (U+200C–200D) and the dotted circle (U+25CC), keeping every shaping
  feature (GSUB/GPOS). About 213 KB and 221 KB.
- `assets/fonts/NotoSansDevanagari-Regular.ttf`, `-Bold.ttf`, `OFL-Noto-Devanagari.txt`;
  `pubspec.yaml` declares the family; `lib/main.dart` registers its licence for the licences
  page.
- `lib/theme/app_theme.dart` — `fontFamilyFallback`: Noto Sans Malayalam, then Noto Sans
  Devanagari, for all UI text. Also dropped `useMaterial3: true` (Material 3 is the default,
  standard §6.1).

### Build

- `android/app/build.gradle.kts` — `bundle { language { enableSplit = false } }`, so Google Play
  keeps every language's resources on the phone (§8.1).

### Checks

- `test/l10n/translation_parity_test.dart` — every declared language has the template's keys
  and no copied English values; the badge `{heart}` marker; content assets per language.
  **Temporary:** `ml` and `sa` are listed as "still to do" until Phase 10; the test fails if a
  listed language already has a file.
- `tool/check_sanskrit_hindi_markers.sh` — the language pack's Hindi-marker gate, with one
  change: it skips `docs/` so the read-only guidelines submodule is never checked as app text.
  Added to `.github/workflows/ci.yml` after `flutter test`. It passes today (it checks the
  Sanskrit in `assets/config/app_config.json`).
- `docs/glossary.md` — app-specific music and app terms in English, Malayalam and Sanskrit.

### Tests (28 new)

- `test/providers/locale_provider_test.dart`, `test/screens/language_settings_screen_test.dart`
  (order, endonyms, marked choice, saving, tooltips), `test/l10n/fallback_localizations_test.dart`
  (a date picker and a dialog open under `sa` with English buttons),
  `test/core/utils/formatting_locale_test.dart`, `test/theme/app_theme_test.dart`, and the
  parity test.
- `test/screens/settings_screen_test.dart` — eight cards; uses a taller test screen so every
  card is built.

### Docs

- `docs/architecture.md` §16 (languages), `docs/dependencies.md` (`cupertino_ui`),
  `docs/PROJECT_PROFILE.md` §4 (status), `docs/release_process.md` (gate command),
  `docs/features.md` (Language setting), `README.md` (gate command), `CLAUDE.md` / `AGENTS.md`
  (picker, fallback, `formatFixed`, glossary, gate).

## Needs native-reader review

Every Malayalam and Sanskrit term in `docs/glossary.md` (26 Sanskrit and 26 Malayalam terms) is
an AI draft. Terms most worth a careful look: Beat (മാത്ര / मात्रा), Bar (ബാർ / आवर्तः),
Key (ശ്രുതി / स्वरमानम्), Metronome (तालयन्त्रम्), Stage Mode (വേദി രീതി / रङ्गविधिः).

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1065 tests passed.
- `bash tool/check_sanskrit_hindi_markers.sh` — passed.
- Hardened prod split APKs and App Bundle built (`--obfuscate
  --split-debug-info=build/symbols/android-prod-2.6.13+37/`). arm64 APK 28.3 MB (+0.2 MB for the
  Devanagari font). `aapt2`: no `INTERNET`, no `ACCESS_NETWORK_STATE`.
- `android\gradlew --stop` run; no Gradle or Kotlin daemon left.

## Not tested

- Not run on a device. Devanagari and Malayalam UI rendering on a clean phone is part of the
  release checklist once Phase 10 brings those languages to the screen.
