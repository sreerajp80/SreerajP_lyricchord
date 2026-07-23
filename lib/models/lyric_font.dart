/// The set of fonts the user can pick for lyric text.
///
/// A [LyricFont] is a plain, immutable description of one choice: how to show it
/// in Settings, the family name Flutter uses on screen, and the asset paths the
/// PDF export loads. It holds no logic and touches no UI or storage.
///
/// All bundled Malayalam fonts use modern (reformed / "puthiya lipi") glyphs.
enum LyricFont {
  /// The app's normal font (Roboto). No bundled asset — on screen Malayalam
  /// falls back to the device font, and the PDF falls back to Noto Sans
  /// Malayalam so Malayalam still prints.
  system(
    id: 'system',
    label: 'System default',
    // Null family means "use the theme's default font" on screen.
    family: null,
    regularAsset: null,
    boldAsset: null,
    supportsMalayalam: false,
  ),

  notoSans(
    id: 'noto_sans',
    label: 'Noto Sans Malayalam',
    family: 'Noto Sans Malayalam',
    regularAsset: 'assets/fonts/NotoSansMalayalam-Regular.ttf',
    boldAsset: 'assets/fonts/NotoSansMalayalam-Bold.ttf',
    supportsMalayalam: true,
  ),

  notoSerif(
    id: 'noto_serif',
    label: 'Noto Serif Malayalam',
    family: 'Noto Serif Malayalam',
    regularAsset: 'assets/fonts/NotoSerifMalayalam-Regular.ttf',
    boldAsset: 'assets/fonts/NotoSerifMalayalam-Bold.ttf',
    supportsMalayalam: true,
  ),

  manjari(
    id: 'manjari',
    label: 'Manjari',
    family: 'Manjari',
    regularAsset: 'assets/fonts/Manjari-Regular.ttf',
    boldAsset: 'assets/fonts/Manjari-Bold.ttf',
    supportsMalayalam: true,
  ),

  gayathri(
    id: 'gayathri',
    label: 'Gayathri',
    family: 'Gayathri',
    regularAsset: 'assets/fonts/Gayathri-Regular.ttf',
    boldAsset: 'assets/fonts/Gayathri-Bold.ttf',
    supportsMalayalam: true,
  );

  const LyricFont({
    required this.id,
    required this.label,
    required this.family,
    required this.regularAsset,
    required this.boldAsset,
    required this.supportsMalayalam,
  });

  /// Stable key saved in `shared_preferences` (never change these strings).
  final String id;

  /// Name shown in the Settings list.
  final String label;

  /// Flutter font family used on screen, or `null` to use the theme default.
  final String? family;

  /// Asset path of the regular weight, or `null` for [system].
  final String? regularAsset;

  /// Asset path of the bold weight, or `null` for [system].
  final String? boldAsset;

  /// True when this font itself draws Malayalam letters.
  final bool supportsMalayalam;

  /// The font used a song opens with.
  static const LyricFont fallback = LyricFont.system;

  /// The bundled font used to draw Malayalam in the PDF when the chosen font
  /// has no Malayalam letters of its own (see [system]).
  static const LyricFont malayalamFallback = LyricFont.notoSans;

  /// A short sample rendered in the font on the Settings screen: English on the
  /// first line, Malayalam on the second, so the user sees the glyphs.
  String get previewText => 'Amazing grace\nമനോഹര ഗാനം';

  /// Finds a font by its saved [id], falling back to [fallback] for an unknown
  /// or missing value so a bad preference never crashes the app.
  static LyricFont fromId(String? id) {
    for (final font in LyricFont.values) {
      if (font.id == id) return font;
    }
    return fallback;
  }
}
