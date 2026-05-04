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
                    if (!success && context.mounted) {
                      CustomSnackBar.show(
                        context,
                        title: 'Authentication Failed',
                        message: 'Could not verify your identity.',
                        type: SnackBarType.error,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const _SectionHeader(title: 'Appearance'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.dark_mode, color: AppColors.primary),
                title: const Text('App Theme'),
                subtitle: Text(_getThemeName(themeMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, ref, themeMode),
              ),
            ),
            const SizedBox(height: 24),
            
            const _SectionHeader(title: 'Preferences'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.edit_document, color: AppColors.primary),
                title: const Text('Default Scan Prefix'),
                subtitle: Text(appSettings.defaultScanPrefix),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () => _showPrefixDialog(context, ref, appSettings.defaultScanPrefix),
              ),
            ),
            const SizedBox(height: 24),
            
            const _SectionHeader(title: 'Data Management'),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Documents', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                subtitle: const Text('Wipe the database completely'),
                onTap: () => _showClearDataConfirmation(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Light Mode';
      case ThemeMode.dark: return 'Dark Mode';
      case ThemeMode.system: return 'System Default';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (val) {
                if (val != null) ref.read(themeProvider.notifier).setTheme(val);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (val) {
                if (val != null) ref.read(themeProvider.notifier).setTheme(val);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (val) {
                if (val != null) ref.read(themeProvider.notifier).setTheme(val);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPrefixDialog(BuildContext context, WidgetRef ref, String currentPrefix) {
    final controller = TextEditingController(text: currentPrefix);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Scan Prefix'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Scan_, Receipt_',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setDefaultPrefix(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Documents?'),
        content: const Text('Are you absolutely sure you want to delete all scanned documents? This action cannot be undone and will permanently erase your data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final repo = ref.read(documentRepositoryProvider);
              await repo.clearAllDocuments();
              if (navigatorKey.currentContext != null) {
                CustomSnackBar.show(
                  navigatorKey.currentContext!,
                  title: 'Cleared',
                  message: 'All documents have been cleared.',
                  type: SnackBarType.success,
                );
              }
            },
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
