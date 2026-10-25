# Change log: Guideline compliance — Phase 7 (About screen)

Implements Phase 7 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gaps C1–C3 and H11). C4 was done in Phase 4. C5 (privacy-policy row) waits for the URL,
and the signature badge waits for its wording — both as the user decided.

## What changed

### Model — `lib/core/config/app_config.dart` [core/config]

- New `LocalizedText`: one string for every language, or one string per language code.
  `resolve(languageCode)` picks the exact language, then English, then any entry.
  `fromJson` reads a string or a map and falls back on anything else, never throwing.
- `AppConfig.appName`, `description` and every `details` value are now `LocalizedText`
  (guideline §1.4). `fromJson` still reads field by field with a safe fallback per field.
- `ConfigService` did not need changes.

### Config — `assets/config/app_config.json`

- Reshaped to guideline §1.2:
  - `details` keys are `lowerCamelCase` ids: `Author` → `author`, `Email` → `email`,
    `License` → `license`, `AI used` → `aiUsed`, `IDE used` → `ideUsed`.
  - `appName`, `description` and the display rows are per-language maps with `en`, `ml`
    and `sa`. Names (app, author, tools) keep the same spelling in each language.
    `email` stays a plain string (an address, not text a user reads).
- **Malayalam and Sanskrit drafts — needs native-reader review** (written by the AI agent):
  - `description.ml`: "സംഗീതജ്ഞർക്കായി വരികളും കോർഡുകളും എഴുതിവയ്ക്കാനുള്ള പുസ്തകം — കോർഡ്
    ഷീറ്റുകൾ എഴുതുക, ശ്രുതി മാറ്റുക, പാടുമ്പോൾ വരികൾ സ്വയം നീങ്ങട്ടെ."
  - `description.sa`: "सङ्गीतज्ञानां कृते गीतपाठानां स्वरसमूहानां च पुस्तिका — स्वरसमूहपत्राणि
    लिख्यन्ताम्, स्वरमानं परिवर्त्यताम्, प्रस्तुतिकाले पाठः स्वयं सर्पतु।"
  - `details.license.ml`: "ഉപയോഗിച്ച എല്ലാ ലൈബ്രറികളും ഓപ്പൺ സോഴ്സ് ആണ്."
  - `details.license.sa`: "प्रयुक्ताः सर्वे तन्त्रांशकोशाः मुक्तस्रोतसः सन्ति।"
  - These are not shown yet: the app offers only English until Phase 10.

### Labels — `lib/l10n/app_en.arb` (+ generated) and `lib/l10n/l10n_labels.dart`

- New ARB keys: `aboutDetailAuthor`, `aboutDetailEmail`, `aboutDetailLicense`,
  `aboutDetailWebsite`, `aboutDetailPrivacyPolicy`, `aboutDetailAiUsed`, `aboutDetailIdeUsed`.
  Website and privacy policy are ready for when those rows are added to the JSON.
- New `aboutDetailLabel(l10n, key)`: maps a details key to its label; an unknown key
  shows as itself so a new row still appears.

### Screen — `lib/screens/about_screen.dart`

- Rows show the translated label and the value for the active language; the app name and
  description are resolved the same way. Rows with a blank value are skipped.
- Tapping `email` opens the mail app (as before); tapping an `https://` value (website,
  privacy policy) opens the browser. The app itself still has no network permission.

### Tests (15 new)

- `test/core/config/app_config_test.dart` — `LocalizedText` resolution and parsing;
  `AppConfig.fromJson` with good and bad input.
- `test/l10n/app_config_test.dart` — the real JSON: required fields; every text a user reads
  has `en`, `ml` and `sa`; detail keys are `lowerCamelCase` with an `aboutDetail<Key>` ARB
  label; `version`/`build` match `pubspec.yaml`.
- `test/screens/about_screen_test.dart` — updated to the new model; new checks for
  translated labels, English values, a row with no label yet, a blank row, and tooltips.

### Docs

- `docs/architecture.md` §15 — how the About config is shaped and checked.

## Checks

- `dart format --output=none --set-exit-if-changed .` — no changes.
- `flutter analyze` — no issues.
- `flutter test` — all 1030 tests passed.
- The Sanskrit drafts were checked against the language pack's Hindi-marker list.

## Note for the guidelines owner (not changed here — the submodule is read-only)

The Hindi-marker gate in `docs/guidelines/language_packs/sanskrit_malayalam.md` §4.1
matches `रहा` anywhere in a word. Correct Sanskrit words that contain it, such as
`सङ्ग्रहाः` ("collections") or anything built on `ग्रह`, are flagged as Hindi. The first
draft of the license line used `तन्त्रांशसङ्ग्रहाः` and would have failed; it now uses
`तन्त्रांशकोशाः`. The pack could match `रहा` / `रही` / `रहे` only at word edges, like the
copulas, or list such words as allowed. This needs a change in the guidelines repository.

## Not done (waiting for the user)

- The privacy-policy row: needs the privacy policy URL (profile §1).
- The signature badge: needs its wording in English, Malayalam and Sanskrit (profile §5).
