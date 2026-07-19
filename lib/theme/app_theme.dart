import 'package:flutter/material.dart';

import 'package:lyriccord/theme/app_colors.dart';

/// Builds the Material 3 light and dark themes from the violet "High Density"
/// palette, mirroring the role mapping in the Android app's `Theme.kt`.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _themeFrom(_lightScheme);

  static ThemeData dark() => _themeFrom(_darkScheme);

  static ThemeData _themeFrom(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.lightSecondaryContainer,
    onSecondary: AppColors.lightOnSecondaryContainer,
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
    secondary: AppColors.darkSecondaryContainer,
    onSecondary: AppColors.darkOnSecondaryContainer,
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
