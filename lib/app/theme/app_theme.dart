import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        card: AppColors.surfaceCardDark,
        onBackground: AppColors.textMainDark,
        muted: AppColors.textMutedDark,
        border: AppColors.borderDark,
      );

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        primary: AppColors.primaryLightMode,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        card: AppColors.surfaceCardLight,
        onBackground: AppColors.textMainLight,
        muted: AppColors.textMutedLight,
        border: AppColors.borderLight,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color card,
    required Color onBackground,
    required Color muted,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primary.withOpacity(0.15),
        onPrimaryContainer: primary,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondary.withOpacity(0.15),
        onSecondaryContainer: AppColors.secondary,
        error: AppColors.danger,
        onError: Colors.white,
        surface: surface,
        onSurface: onBackground,
        surfaceContainerHighest: card,
        outline: border,
        shadow: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.2),
        indicatorColor: primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            );
          }
          return TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 22);
          }
          return IconThemeData(color: muted, size: 22);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: TextStyle(color: muted, fontSize: 14),
        hintStyle: TextStyle(color: muted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: onBackground, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: onBackground, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(color: onBackground, fontWeight: FontWeight.w800, fontSize: 24),
        headlineMedium: TextStyle(color: onBackground, fontWeight: FontWeight.w800, fontSize: 20),
        headlineSmall: TextStyle(color: onBackground, fontWeight: FontWeight.w700, fontSize: 18),
        titleLarge: TextStyle(color: onBackground, fontWeight: FontWeight.w700, fontSize: 16),
        titleMedium: TextStyle(color: onBackground, fontWeight: FontWeight.w600, fontSize: 14),
        titleSmall: TextStyle(color: onBackground, fontWeight: FontWeight.w600, fontSize: 13),
        bodyLarge: TextStyle(color: onBackground, fontSize: 15),
        bodyMedium: TextStyle(color: onBackground, fontSize: 14),
        bodySmall: TextStyle(color: muted, fontSize: 12),
        labelLarge: TextStyle(color: onBackground, fontWeight: FontWeight.w700, fontSize: 14),
        labelMedium: TextStyle(color: muted, fontWeight: FontWeight.w600, fontSize: 12),
        labelSmall: TextStyle(color: muted, fontWeight: FontWeight.w600, fontSize: 10),
      ),
    );
  }
}
