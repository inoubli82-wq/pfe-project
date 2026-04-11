import 'package:flutter/material.dart';

/// ============================================
/// APP COLORS - Centralized Color Palette
/// ============================================
///
/// Usage: AppColors.primary, AppColors.error, etc.
/// This ensures consistent colors throughout the app.

class AppColors {
  AppColors._(); // Private constructor - prevents instantiation

  // ==================== PRIMARY COLORS ====================
  static const Color primary = Color(0xFF0C44A6);
  static const Color primaryLight = Color(0xFF0C44A6);
  static const Color primaryDark = Color(0xFF0C44A6);
  static const Color primaryBlue = Color(0xFF0C44A6);

  // ==================== SECONDARY COLORS ====================
  static const Color secondary = Color(0xFFFF6F00); // Amber 900
  static const Color secondaryLight = Color(0xFFffa040);
  static const Color secondaryDark = Color(0xFFc43e00);

  // ==================== BACKGROUND COLORS ====================
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  // ==================== STATUS COLORS ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFB71C1C);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF0C44A6);
  static const Color infoLight = Color(0xFF0C44A6);

  // ==================== TEXT COLORS ====================
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // ==================== BORDER COLORS ====================
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFEEEEEE);

  // ==================== ROLE-SPECIFIC COLORS ====================
  static const Color adminColor = Color(0xFF0C44A6);
  static const Color importColor = Color(0xFF2E7D32);
  static const Color exportColor = Color(0xFFE65100);
  static const Color partenaireColor = Color(0xFF6A1B9A);

  // ==================== GRADIENT ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryBlue],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), success],
  );

  // ==================== SHADOW COLORS ====================
  static Color shadowColor = Colors.black.withValues(alpha: 0.1);
  static Color shadowColorDark = Colors.black.withValues(alpha: 0.2);
}
