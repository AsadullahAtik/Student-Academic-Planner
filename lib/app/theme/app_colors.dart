import 'package:flutter/material.dart';

/// App color palette matching prototype2.html exactly
class AppColors {
  AppColors._();

  // === Primary Palette ===
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFFEEF2FF);
  static const primaryDark = Color(0xFF3730A3);
  static const primaryLightMode = Color(0xFF4338CA);
  static const primaryDarkLightMode = Color(0xFF312E81);

  // === Semantic Colors ===
  static const secondary = Color(0xFF0D9488);
  static const secondaryLight = Color(0xFF0F766E);
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFD97706);
  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFDC2626);
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF059669);

  // === Dark Theme Surface ===
  static const backgroundDark = Color(0xFF0F172A);
  static const surfaceDark = Color(0xFF1E293B);
  static const surfaceCardDark = Color(0xFF243046);
  static const textMainDark = Color(0xFFF8FAFC);
  static const textMutedDark = Color(0xFF94A3B8);
  static const borderDark = Color(0xFF334155);

  // === Light Theme Surface ===
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceCardLight = Color(0xFFF1F5F9);
  static const textMainLight = Color(0xFF0F172A);
  static const textMutedLight = Color(0xFF64748B);
  static const borderLight = Color(0xFFE2E8F0);

  // === Subject / Category Colors ===
  static const List<Color> subjectPalette = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0D9488), // Teal
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFF84CC16), // Lime
    Color(0xFFF97316), // Orange
  ];

  static String colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  static Color hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
