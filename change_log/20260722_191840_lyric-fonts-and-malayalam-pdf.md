# Change log: Selectable lyric fonts + Malayalam in PDF export

Implements plan
[plans/20260722_052850_lyric-fonts-and-malayalam-pdf.md](../plans/20260722_092850_lyric-fonts-and-malayalam-pdf.md).

## What changed and why

Before, all lyric text used one default font and the PDF export used the
built-in Helvetica font. Helvetica has no Malayalam letters, so Malayalam lyrics
came out as blank boxes in exported PDFs. Now the user can pick a lyric font in
Settings, and PDFs always print Malayalam correctly.

### New: a "Fonts" card in Settings

- Settings now has a **Fonts** card (`Settings -> Fonts`). It opens a screen with
  a radio list of font choices, each showing a small English + Malayalam preview
  in that font.
- The choice is saved with `shared_preferences`, so it survives a restart.
- The chosen font is used for lyric text in three places: the performance view,
  the editor's lyric box, and the exported PDF. Chords keep their own font.

### Bundled fonts (all SIL Open Font Licence, modern Malayalam glyphs)

Added to `assets/fonts/` and declared in `pubspec.yaml`:

- Noto Sans Malayalam (Regular + Bold)
- Noto Serif Malayalam (Regular + Bold)
- Manjari (Regular + Bold)
- Gayathri (Regular + Bold)

The "System default" choice adds no font file (keeps Roboto). All Malayalam
fonts use the modern (reformed / "puthiya lipi") glyphs, not the old ones.
Total added size: about 0.9 MB.

### Malayalam in the PDF

- `pdf_export_service` now loads the chosen font's `.ttf` (Regular + Bold) and
  always attaches **Noto Sans Malayalam** as a fallback on the page theme. So
  Malayalam prints even when the chosen font (for example the plain default) has
  no Malayalam letters of its own.
- The guitar-diagram canvas still uses Helvetica — it only draws ASCII markers.

### Font licences shown in the app

- The bundled fonts' Open Font Licence text is registered with
  `LicenseRegistry` in `main.dart`.
- The About screen gained an **Open source licenses** row that opens Flutter's
  standard licence page, where these licences (and all package licences) appear.

## Files changed

**New**
- `assets/fonts/*.ttf` — 8 font files, plus `OFL-*.txt` licence files.
- `lib/models/lyric_font.dart` — the font catalogue (enum with labels, family
  names, asset paths, Malayalam flag, preview text).
- `lib/providers/lyric_font_provider.dart` — saves/loads the chosen font.
- `lib/screens/font_settings_screen.dart` — the Fonts screen.
- `test/providers/lyric_font_provider_test.dart`
- `test/screens/font_settings_screen_test.dart`

**Changed**
- `pubspec.yaml` — declare the fonts (as `fonts:` and under `assets:`).
- `lib/core/constants/app_constants.dart` — add `prefLyricFont` key.
- `lib/screens/settings_screen.dart` — add the Fonts card.
- `lib/core/router/app_router.dart` — add the `/settings/fonts` route.
- `lib/widgets/chord_sheet_view.dart` — new `lyricFontFamily` parameter.
- `lib/screens/song_performance_screen.dart` — pass the font to the sheet and to
  the PDF export.
- `lib/screens/song_editor_screen.dart` — apply the font to the lyrics field.
- `lib/services/pdf_export_service.dart` — load real fonts + Malayalam fallback.
- `lib/main.dart` — register the font OFL licences.
- `lib/screens/about_screen.dart` — add the "Open source licenses" row.
- `test/services/pdf_export_service_test.dart` — init the test binding, add two
  Malayalam-lyrics PDF tests.
- `test/screens/settings_screen_test.dart` — expect five cards + Fonts route.
- `test/screens/song_performance_screen_test.dart`,
  `test/screens/song_list_screen_test.dart` — override
  `sharedPreferencesProvider` (these screens now read the font provider).

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 219 tests pass.
- `dart format .` — applied.

The offline rule is kept: font files are bundled at build time; the app makes no
network calls at runtime. No new permissions, no networking packages.

## Notes / possible follow-ups

- For the plain "System default" choice, the PDF logs a harmless "Helvetica has
  no Unicode support" message when it meets Malayalam; the bundled fallback then
  renders it. Picking a Malayalam font avoids the message.
- Bold Malayalam that falls back (for example a Malayalam PDF title while using
  an English base font) prints in regular weight, because only one Malayalam
  fallback (Regular) is attached. Minor and only affects the fallback case.
