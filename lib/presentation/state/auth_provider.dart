import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final bool isAppLocked;
  final bool isAuthenticated;
  AuthState(this.isAppLocked, this.isAuthenticated);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  AuthNotifier() : super(AuthState(false, false)) {
    _init();
  }

  Future<void> _init() async {
    final isLockedStr = await _storage.read(key: 'isAppLocked');
    final isLocked = isLockedStr == 'true';
    state = AuthState(isLocked, !isLocked);
  }

  Future<bool> authenticate() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your scanned documents',
        biometricOnly: false,
      );
      if (didAuthenticate) {
        state = AuthState(state.isAppLocked, true);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> toggleAppLock(bool enable) async {
    if (enable) {
      final canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) return false;
      
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable App Lock',
      );
      if (didAuthenticate) {
        await _storage.write(key: 'isAppLocked', value: 'true');
        state = AuthState(true, true);
        return true;
      }
      return false;
    } else {
      await _storage.write(key: 'isAppLocked', value: 'false');
      state = AuthState(false, true);
      return true;
    }
  }
}
