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
    final themeMode = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(title: 'Security'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.security, color: AppColors.primary),
                title: const Text('App Lock'),
                subtitle: const Text('Require Face ID / PIN to open app'),
                trailing: Switch(
                  value: authState.isAppLocked,
                  activeColor: AppColors.primary,
                  onChanged: (value) async {
                    final success = await ref.read(authProvider.notifier).toggleAppLock(value);
