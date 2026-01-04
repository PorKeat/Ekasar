import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:pdf_scanner_pro/core/theme/wave_painter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:pdf_scanner_pro/presentation/screens/settings_screen.dart';
import 'package:pdf_scanner_pro/presentation/screens/pdf_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_scanner_pro/presentation/screens/image_editor_screen.dart';
import 'package:pdf_scanner_pro/core/utils/pdf_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_scanner_pro/presentation/state/document_provider.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';
import 'package:intl/intl.dart';
import 'package:pdf_scanner_pro/main.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsStreamProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const AnimatedWaveBackground(height: 220),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ekasar',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              'Scan and digitize your documents instantly',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2, end: 0),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
