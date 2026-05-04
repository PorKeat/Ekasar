import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf_scanner_pro/presentation/state/auth_provider.dart';
import 'package:pdf_scanner_pro/presentation/screens/home_screen.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState.isAppLocked && !authState.isAuthenticated) {
      return Scaffold(
        body: Stack(
          children: [
            // Premium Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF0F0F15),
                            const Color(0xFF1A1A2E),
                            const Color(0xFF0F0F15),
                          ]
                        : [
                            const Color(0xFFF5F7FA),
                            const Color(0xFFE4E9F2),
                            const Color(0xFFF5F7FA),
                          ],
                  ),
                ),
              ),
            ),
            
            // Decorative Animated Orbs
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                      blurRadius: 100,
                      spreadRadius: 50,
                    )
                  ]
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 4.seconds, curve: Curves.easeInOut),
            ),
            Positioned(
              bottom: -150,
              left: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(isDark ? 0.15 : 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(isDark ? 0.15 : 0.08),
                      blurRadius: 100,
                      spreadRadius: 50,
                    )
                  ]
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 5.seconds, curve: Curves.easeInOut),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withOpacity(isDark ? 0.4 : 0.6),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Glowing Fingerprint Icon
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fingerprint_rounded,
                                size: 80,
                                color: AppColors.primary,
                              ),
                            )
                            .animate(onPlay: (controller) => controller.repeat(reverse: true))
                            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut)
                            .shimmer(color: Colors.white54, duration: 2.seconds)
                            .then()
                            .animate()
                            .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                            .slideY(begin: 0.3, end: 0),

                            const SizedBox(height: 40),

                            // App Name
                            Text(
                              'Ekasar',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 36,
                                letterSpacing: 1.5,
                              ),
                            ).animate()
                             .fadeIn(delay: 300.ms, duration: 600.ms)
                             .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              'Secured by Biometrics',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ).animate()
                             .fadeIn(delay: 500.ms, duration: 600.ms)
                             .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

                            const SizedBox(height: 50),

                            // Unlock Button
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                onPressed: () => ref.read(authProvider.notifier).authenticate(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: AppColors.primary.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_open_rounded, size: 24),
                                    SizedBox(width: 12),
                                    Text(
                                      'Unlock Vault',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate()
                             .fadeIn(delay: 700.ms, duration: 600.ms)
                             .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack)
                             .shimmer(delay: 1.5.seconds, duration: 1.5.seconds, color: Colors.white30)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const HomeScreen();
  }
}
