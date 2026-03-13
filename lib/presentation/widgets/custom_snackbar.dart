import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';

enum SnackBarType { success, error, warning }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required SnackBarType type,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color typeColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        typeColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        break;
