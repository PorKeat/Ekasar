import 'package:flutter/material.dart';

class AppColors {
  // Primary deep purple/blue scheme
  static const Color primary = Color(0xFF4A3E92);
  static const Color secondary = Color(0xFFF15A59);
  
  // Light Mode
  static const Color backgroundLight = Color(0xFFF6F8FC);
  static const Color cardLight = Colors.white;
  static const Color textLightPrimary = Color(0xFF1E1E2C);
  static const Color textLightSecondary = Color(0xFF757575);

  // Dark Mode
  static const Color backgroundDark = Color(0xFF0F0F15);
  static const Color cardDark = Color(0xFF1A1A2E);
  static const Color textDarkPrimary = Color(0xFFF5F7FA);
  static const Color textDarkSecondary = Color(0xFFA0AABF);

  // Validation / Status
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFCC00);

  // Waves
  static const Color wavePrimary = Color(0xFF6B58CD);
  static const Color waveSecondary = Color(0xFF4A3E92);
  static const Color waveTertiary = Color(0xFF32286B);
  
  // Text (legacy placeholders, map these to theme where possible)
  static const Color textPrimary = Color(0xFF1E1E2C);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [wavePrimary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
// nit: clean up
// nit: clean up
