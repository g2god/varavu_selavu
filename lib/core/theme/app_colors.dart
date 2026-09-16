import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette - Slate/Teal Calm Theme
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF0EA5E9); // Ocean Sky 500

  // Semantic Financial Colors (Calm, non-neon, accessible)
  static const Color expense = Color(0xFFE11D48); // Rose 600
  static const Color expenseLight = Color(0xFFFFF1F2); // Rose 50
  static const Color expenseBorder = Color(0xFFFECDD3);

  static const Color income = Color(0xFF059669); // Emerald 600
  static const Color incomeLight = Color(0xFFECFDF5); // Emerald 50
  static const Color incomeBorder = Color(0xFFA7F3D0);

  static const Color balance = Color(0xFF2563EB); // Royal Blue 600
  static const Color balanceLight = Color(0xFFEFF6FF);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF131B2A);
  static const Color cardDark = Color(0xFF172033);
  static const Color borderDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // Category palette (harmonious, subtle pastels)
  static const List<Color> categoryPalette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFF6366F1), // Indigo
    Color(0xFFF97316), // Orange
    Color(0xFF64748B), // Slate
  ];
}
