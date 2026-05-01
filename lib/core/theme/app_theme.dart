import 'package:flutter/material.dart';

/// Цветовые токены из `DESIGN_REFERENCE.md` (web `problem_web/src/index.css`).
abstract final class AppColors {
  static const Color primary = Color(0xFF137FEC);
  static const Color primaryDark = Color(0xFF0F6BD0);
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color searchBackground = Color(0xFFE8EEF5);
  static const Color borderLight = Color(0xFFE6E8EC);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textBody = Color(0xFF5F6B7A);
  static const Color textMuted = Color(0xFF8A97A8);
  static const Color textSecondary = Color(0xFF92ADC9);
  static const Color darkBackground = Color(0xFF101922);
  static const Color darkSurface = Color(0xFF1E2936);
  static const Color darkSurfaceAlt = Color(0xFF233648);
  static const Color darkBorder = Color(0xFF324D67);
  static const Color darkOnSurface = Color(0xFFE8EDF3);
  static const Color darkOnSurfaceVariant = Color(0xFFB0C0D4);
}

abstract final class AppSpacing {
  static const double screenPadding = 18;
  static const double cardRadius = 14;
  static const double controlRadius = 12;
  static const double bottomButtonHeight = 52;

  /// Нижний отступ у `ListView` над одной фиксированной CTA + safe area.
  static const double listBottomPaddingSingleCta = 144;

  /// Нижний отступ при двух кнопках в колонке (главный экран).
  static const double listBottomPaddingDoubleCta = 176;
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
      secondary: AppColors.primaryDark,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimary,
      outline: AppColors.borderLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textBody),
      floatingLabelStyle: const TextStyle(color: AppColors.textPrimary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.bottomButtonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textBody,
        fontSize: 16,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textBody,
        fontSize: 14,
        height: 1.35,
      ),
      labelSmall: TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    ),
  );
}

/// Тёмная тема по палитре из `DESIGN_REFERENCE.md`; тексты — светлые для контраста.
ThemeData buildAppDarkTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );

  final scheme = base.copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primaryDark,
    onSecondary: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    surfaceContainerLow: AppColors.darkSurfaceAlt,
    surfaceContainerHigh: const Color(0xFF283548),
    surfaceContainerHighest: const Color(0xFF323F50),
    outline: AppColors.darkBorder,
    outlineVariant: const Color(0xFF3A4F66),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: scheme.onSurface),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSpacing.bottomButtonHeight),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.controlRadius),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineSmall: TextStyle(
        color: scheme.onSurface,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: scheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 16,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 14,
        height: 1.35,
      ),
      labelSmall: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    ),
  );
}
