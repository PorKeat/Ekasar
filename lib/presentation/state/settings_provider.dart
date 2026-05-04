import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());

class AppSettings {
  final String defaultScanPrefix;
  AppSettings({required this.defaultScanPrefix});
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final _storage = const FlutterSecureStorage();

  SettingsNotifier() : super(AppSettings(defaultScanPrefix: 'Scanned_Document')) {
    _init();
  }

  Future<void> _init() async {
    final prefix = await _storage.read(key: 'default_prefix');
    if (prefix != null && prefix.isNotEmpty) {
      state = AppSettings(defaultScanPrefix: prefix);
    }
  }

  Future<void> setDefaultPrefix(String prefix) async {
    if (prefix.trim().isEmpty) return;
    await _storage.write(key: 'default_prefix', value: prefix.trim());
    state = AppSettings(defaultScanPrefix: prefix.trim());
  }
}
