# Change log: Guideline compliance — Phase 10 (Malayalam and Sanskrit translations)

Implements Phase 10 of plan:
[../plans/20261023_073607_guideline-compliance-audit.md](../plans/20261023_073607_guideline-compliance-audit.md)
(gaps H1 and H10). The app now shows English, Malayalam and Sanskrit.

> **Needs native-reader review.** Every Malayalam and Sanskrit string in this change was
> written by the AI agent. All of them — the full `lib/l10n/app_ml.arb` and
> `lib/l10n/app_sa.arb`, 970 strings each — are drafts that a fluent reader must review
> before a release ships them (reviewer roles: `docs/PROJECT_PROFILE.md` §4).

## How the work was done

- The 970 template keys were translated in 11 batches. Each batch was checked as it went in:
  only template keys, no copied English, the same placeholders and plural forms as English,
  the length budget for short text (22 characters), the Hindi-marker gate for Sanskrit, and
  a `flutter gen-l10n` build in a throw-away project.
- Until the last batch the drafts lived outside the app (`l10n_drafts/`), so the app never
  showed a half-done language. That folder is now gone.

| Batch | Area | Keys |
|---|---|---|
| 1–4 | Songbook, setlists, editor, performance view, settings, metronome, pitch and drone | 440 |
| 5 | About, import and export, import preview, AirQR, storage and audio errors, notation problems, start-up error, tooltips, Delete all data, Language | 109 |
| 6 | Help: Your songbook, Write a song, Setlists | 74 |
| 7 | Help: Transpose & chords, Auto-scroll | 69 |
| 8 | Help: Full screen, Metronome | 73 |
| 9 | Help: Pitch Pipe & Drone, Melody Lines | 72 |
| 10 | Help: Indian songs, Select Songs, Import | 68 |
| 11 | Help: Export, AirQR sharing, Themes & fonts, topic not found | 65 |

## Translation choices

- Terms follow `docs/glossary.md` and the language pack's glossary. For example: song
  പാട്ട് / गीतम्; setlist പാട്ടുപട്ടിക / गीतावली; chord കോർഡ് / स्वरसमूहः; key ശ്രുതി /
  स्वरमानम्; bar ബാർ / आवर्तः; import ഇറക്കുമതി / आनयनम्; export കയറ്റുമതി / निर्यापणम्.
- Sanskrit buttons use the polite passive form (`…ताम्`), and Sanskrit sentences end with
  the danda (।).
- Brand names, formats and notation stay as they are: LyricChord, ChordPro, PDF, BPM, AirQR,
  chord names (C, Am, D/F#), swara codes (M2, G3), and the `{tonic: …}` / `{tala: …}` /
  `{melody}` lines.
- Song data stays English, because it is stored in the song, not shown from the ARB file:
  "Untitled Song" and the "(Copy)" title suffix. The Help text quotes them as they are.
- Help text names each button by its translated label, so the Help matches the screen.

## Code and test changes

- `lib/l10n/app_ml.arb`, `lib/l10n/app_sa.arb` — new, 970 strings each, in template order.
  `lib/l10n/app_localizations*.dart` regenerated with `flutter gen-l10n` (generated files).
- The language picker now offers System default, English, മലയാളം and संस्कृतम्, because it
  lists every language with an ARB file. No code change was needed for that.
- `test/l10n/translation_parity_test.dart` — the temporary `languagesStillToDo` list and the
  draft-folder check are removed. It now checks that each language file exists, has the same
  keys as English, copies no English value, and uses the same placeholders.
- `test/l10n/fallback_localizations_test.dart` — uses the full `appLocalizationsDelegates`
  now that Sanskrit app strings exist.
- `test/l10n/locale_smoke_test.dart` — new (engineering standard §8.7). It opens 29 screens
  (the songbook, every settings screen, the editor, the Help hub and every Help topic) in
  each declared language on a small 360 × 800 phone, and fails on any layout overflow or
  error, and on any English text showing under Malayalam or Sanskrit. It uses the app theme
  and loads the bundled Noto Sans Malayalam and Noto Sans Devanagari fonts, so Indic text is
  measured with real glyph widths (the test font draws every character as a wide square).

## Docs

- `CLAUDE.md`, `AGENTS.md` — the Languages row and the localization rules now say all three
  languages are built, and that `ml` / `sa` need native-reader review.
- `docs/PROJECT_PROFILE.md` §4 — status set to built, with the review still to do.
- `docs/features.md` — the Settings hub entry lists the three languages.

## Checks

- `dart format .` — clean. `flutter analyze` — no issues.
- `flutter test` — all 1160 tests pass (1065 before; the new smoke test adds 87).
- `tool/check_sanskrit_hindi_markers.sh` — passed (2 files).
- `flutter build apk --flavor prod --release --obfuscate --split-debug-info=… --split-per-abi`
  — built the three APKs. `aapt2 dump permissions` on the arm64 APK shows no `INTERNET`
  permission (only notification policy, biometric, fingerprint, camera and the app's own
  receiver permission). Gradle daemons stopped afterwards; none left running.

## Notes for the user

- **Native-reader review** is the main thing left before a release with these languages.
- **Hindi-marker gate false positive** (for the guidelines owner — the submodule was not
  changed): the gate flags the Hindi marker रहा/रहे inside correct Sanskrit words such as
  सङ्ग्रहात् / सङ्ग्रहे ("from / in the collection"). The drafts were reworded to गीतकोशात् /
  गीतकोशे to pass. The same happened with शक्याः (flagged as क्या), reworded to शक्यन्ते.
  The gate may want to match whole words only.
- The release build prints a warning that the native library holds unobfuscated debug
  (DWARF) information and suggests `--strip`. This is a Flutter tool message, not caused by
  this change; it is left for the release process to decide.
- Still waiting from earlier phases: the About signature badge wording, the privacy-policy
  URL, and the publisher, website, copyright and licence details.
