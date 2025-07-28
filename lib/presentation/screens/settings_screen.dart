import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:pdf_scanner_pro/presentation/state/auth_provider.dart';
import 'package:pdf_scanner_pro/presentation/state/theme_provider.dart';
import 'package:pdf_scanner_pro/presentation/state/settings_provider.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';
import 'package:pdf_scanner_pro/main.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
