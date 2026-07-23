# Plan: Selectable lyric fonts + Malayalam support in PDF export

**Status:** completed

## The issue / goal

Today the app uses the default font everywhere, and the PDF export uses the
built-in Helvetica font. Helvetica has no Malayalam letters, so Malayalam lyrics
show up as blank boxes in exported PDFs, even though they look fine on screen
(the device font renders them).

The user wants:

1. **Malayalam in PDF export** — exported PDFs must show Malayalam correctly.
2. **A set of bundled fonts** — some English fonts and some Malayalam fonts. The
   Malayalam fonts must use **modern (reformed / "puthiya lipi") glyphs**, not
   the old traditional glyphs.
3. **A "Fonts" card in Settings** — the user picks a font, and it is used for the
   lyric text (both on screen and in the exported PDF).

## Scope decision (please confirm)

- The chosen font applies to **lyric text only** — the performance view lyrics,
  the editor's lyric box, and the PDF lyrics/title/artist. The rest of the app
  UI (menus, buttons, labels) keeps the normal theme font. Reason: this is a
  lyrics app; Malayalam matters for song text, and a Malayalam font would look
  odd on English UI labels.
- **Chords stay as they are** (bold monospace on screen, bold accent in PDF).
  Chords are Latin (C, G, Am), so they do not need a Malayalam font.
- **PDF always renders Malayalam**, no matter which font is picked: the PDF text
  style gets a Malayalam **fallback font** (Noto Sans Malayalam). So even if the
  user picks an English-only font, Malayalam words still render in the PDF.
- The font choice is **saved** (via `shared_preferences`, like the theme setting)
  so it survives app restarts.

## Fonts to bundle

All fonts below are free/open licence (SIL Open Font Licence or Apache), so they
can ship inside the app. Malayalam fonts all use **modern reformed glyphs**.
Bundling font files at build time does **not** break the "fully offline" rule —
the app makes no network calls at runtime; the files ship inside the APK.

| Choice in Settings | Family | Script | Notes |
|--------------------|--------|--------|-------|
| System Default | (none — Roboto) | Latin | Current look. Malayalam falls back to device font on screen, Noto Sans Malayalam in PDF. |
| Noto Sans Malayalam | Noto Sans Malayalam | Malayalam + Latin | Clean modern sans. Also used as the PDF Malayalam fallback. |
| Manjari | Manjari | Malayalam + Latin | Modern reformed sans (SMC). |
| Gayathri | Gayathri | Malayalam + Latin | Modern reformed sans (SMC). |
| Noto Serif Malayalam | Noto Serif Malayalam | Malayalam + Latin | Modern serif option. |

Each family bundles **Regular + Bold** weights (Bold is used for the PDF title).
Estimated added app size: roughly 1–2 MB total.

**Font file sourcing:** I will download the `.ttf` files at implementation time
from their official open-source repositories (Google Fonts / SMC) using a
PowerShell download, and place them in `assets/fonts/`. If the build machine has
no internet access and the download fails, I will stop and ask you to drop the
`.ttf` files into `assets/fonts/` manually (I will give the exact file names).

## Files to change

**New files**

- `assets/fonts/*.ttf` — the bundled font files (downloaded at build time).
- `lib/models/lyric_font.dart` — the font catalogue: a small immutable model /
  enum listing each choice (id, label, `fontFamily`, `supportsMalayalam`, a
  short Malayalam+English preview string, and the asset paths used by the PDF).
- `lib/providers/lyric_font_provider.dart` — a `Notifier` that reads/saves the
  chosen font in `shared_preferences` (mirrors `theme_mode_provider.dart`).
- `lib/screens/font_settings_screen.dart` — the Fonts screen: a radio list, each
  option showing its name and a small preview line rendered in that font (so the
  user sees the Malayalam glyphs before choosing).
- `test/providers/lyric_font_provider_test.dart` — save/restore test.
- `test/screens/font_settings_screen_test.dart` — the screen shows options and
  changing the choice updates the provider.

**Changed files**

- `pubspec.yaml` — declare the fonts under `flutter: fonts:` (and make sure
  `assets/fonts/` ships).
- `lib/core/constants/app_constants.dart` — add `prefLyricFont` key.
- `lib/screens/settings_screen.dart` — add a "Fonts" card (icon
  `Icons.font_download_outlined`) opening `/settings/fonts`.
- `lib/core/router/app_router.dart` — add the `/settings/fonts` route.
- `lib/widgets/chord_sheet_view.dart` — add an optional `lyricFontFamily`
  parameter and use it for the lyric text style (chords unchanged).
- `lib/screens/song_performance_screen.dart` — read `lyricFontProvider` and pass
  the family to `ChordSheetView`.
- `lib/screens/song_editor_screen.dart` — apply the chosen family to the lyrics
  `TextField` style.
- `lib/services/pdf_export_service.dart` — the main change:
  - Load the chosen font's Regular + Bold `.ttf` and the Noto Sans Malayalam
    fallback from assets (via `rootBundle`).
  - Use the loaded fonts for the title, artist, key line, chords, and lyric text,
    with the Malayalam font set as `fontFallback` so Malayalam always renders.
  - Keep the low-level guitar-diagram canvas on Helvetica (it only draws ASCII
    `O`/`X`/fret numbers).
  - `buildPdf` gains an optional font parameter (the chosen `LyricFont`); when
    omitted it defaults to the system/default font so existing callers/tests keep
    working.
- `test/services/pdf_export_service_test.dart` — initialise the test binding for
  asset loading, keep the existing checks, and add one test that builds a PDF
  from Malayalam lyrics and confirms it is a valid PDF.
- `docs/implementation_progress.md` — short note that lyric fonts + Malayalam PDF
  were added.

## Plan for the fix (steps)

1. Download the `.ttf` files into `assets/fonts/`; declare them in `pubspec.yaml`.
2. Add `LyricFont` catalogue model and the `lyricFontProvider` (persisted).
3. Build the Fonts settings screen with per-option previews; wire the Settings
   card and the router route.
4. Apply the chosen family to on-screen lyrics (performance view + editor).
5. Rework `pdf_export_service` to load and use real fonts with a Malayalam
   fallback.
6. Add/adjust tests; run `flutter analyze`, `flutter test`, and `dart format .`.
7. Write the change log.

## Testing

- `lyric_font_provider_test` — choosing a font saves it and it restores on
  restart.
- `font_settings_screen_test` — options render; picking one updates the provider.
- `pdf_export_service_test` — existing checks still pass; new Malayalam-lyrics
  PDF builds without error and is a valid PDF.
- Manual: pick each font in Settings, check the performance view and editor, and
  export a Malayalam song to PDF to confirm the letters show.

## Open questions for you

1. **Scope** — OK to apply the font to lyric text only (not the whole app UI)?
2. **Font list** — is the five-choice list above good, or do you want specific
   fonts added/removed (e.g. a particular English font)?
3. **Where it applies** — should the chosen font also change the **editor** lyric
   box (my plan: yes), or only the performance view and PDF?
