import 'package:flutter/material.dart';

/// The violet "High Density" palette, ported 1:1 from the Android app's
/// `Color.kt`. These are raw colour values only; the [ThemeData] mapping lives
/// in `app_theme.dart`.
class AppColors {
  AppColors._();

  // Light mode.
  static const Color lightBg = Color(0xFFFDF8FD);
  static const Color lightText = Color(0xFF1C1B1F);
  static const Color lightSubtext = Color(0xFF49454F);
  static const Color lightPrimary = Color(0xFF0052CC);
  static const Color lightSecondaryContainer = Color(0xFFEADDFF);
  static const Color lightOnSecondaryContainer = Color(0xFF21005D);
  static const Color lightBorder = Color(0xFFCAC4D0);
  static const Color lightSurfaceVariant = Color(0xFFF7F2FA);
  static const Color lightFabBg = Color(0xFFD0BCFF);
  static const Color lightFabText = Color(0xFF381E72);

  // Dark mode.
  static const Color darkBg = Color(0xFF141218);
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkPrimary = Color(0xFFFFD54F);
  static const Color darkSecondaryContainer = Color(0xFF4F378B);
  static const Color darkOnSecondaryContainer = Color(0xFFEADDFF);
  static const Color darkText = Color(0xFFE6E1E5);
  static const Color darkSubtext = Color(0xFFCAC4D0);
  static const Color darkBorder = Color(0xFF49454F);
  static const Color darkSurfaceVariant = Color(0xFF2B2930);
  static const Color darkFabBg = Color(0xFFD0BCFF);
  static const Color darkFabText = Color(0xFF381E72);
}
