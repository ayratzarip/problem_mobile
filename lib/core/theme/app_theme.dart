import 'package:flutter/material.dart';

/// Цветовые токены из `DESIGN_REFERENCE.md` (web `problem_web/src/index.css`).
abstract final class AppColors {
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryDark = Color(0xFF0F6BD0);
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF92ADC9);
  static const Color textPrimary = Color(0xFF0F172A);
}

ThemeData buildAppTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
