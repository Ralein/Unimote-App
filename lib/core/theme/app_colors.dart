import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF161D2F);
  static const Color surfaceElevated = Color(0xFF212B42);
  static const Color cardBorder = Color(0xFF2D3748);

  // Accents
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Status & Actions
  static const Color powerRed = Color(0xFFEF4444);
  static const Color powerRedGlow = Color(0x66EF4444);
  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusGreenGlow = Color(0x6610B981);
  static const Color warningAmber = Color(0xFFF59E0B);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient powerGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dpadGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
