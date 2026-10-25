import 'package:material_ui/material_ui.dart';

import 'package:lyricchord/theme/app_colors.dart';

/// Builds the Material 3 light and dark themes from the violet "High Density"
/// palette, mirroring the role mapping in the Android app's `Theme.kt`.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _themeFrom(_lightScheme);

  static ThemeData dark() => _themeFrom(_darkScheme);

  /// Bundled fonts that cover the scripts of the declared languages, tried in
  /// order when the main UI font has no glyph (engineering standard §8.3.3):
  /// Malayalam, then Devanagari for Sanskrit. Material 3 is the default, so
  /// `useMaterial3` is not set.
  static const List<String> uiFontFallback = [
    'Noto Sans Malayalam',
    'Noto Sans Devanagari',
  ];

  static ThemeData _themeFrom(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamilyFallback: uiFontFallback,
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.lightPrimary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.lightSecondaryContainer,
    onSecondaryContainer: AppColors.lightOnSecondaryContainer,
    tertiary: AppColors.lightFabBg,
    onTertiary: AppColors.lightFabText,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: AppColors.lightBg,
    onSurface: AppColors.lightText,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.lightSubtext,
    outline: AppColors.lightBorder,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkFabText,
    secondary: AppColors.darkPrimary,
    onSecondary: AppColors.darkFabText,
    secondaryContainer: AppColors.darkSecondaryContainer,
    onSecondaryContainer: AppColors.darkOnSecondaryContainer,
    tertiary: AppColors.darkFabBg,
    onTertiary: AppColors.darkFabText,
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: AppColors.darkBg,
    onSurface: AppColors.darkText,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkSubtext,
    outline: AppColors.darkBorder,
  );
}
