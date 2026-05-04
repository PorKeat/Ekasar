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
      case SnackBarType.error:
        typeColor = AppColors.error;
        icon = Icons.error_outline_rounded;
        break;
      case SnackBarType.warning:
        typeColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(isDark ? 0.7 : 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: typeColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: typeColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: typeColor, size: 28)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2.seconds, color: typeColor.withOpacity(0.5)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack, duration: 600.ms).fadeIn(),
      ),
    );
  }
}
