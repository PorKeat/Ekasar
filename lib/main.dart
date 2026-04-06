import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:pdf_scanner_pro/core/theme/app_theme.dart';
import 'package:pdf_scanner_pro/presentation/screens/auth_wrapper.dart';
import 'package:pdf_scanner_pro/presentation/state/camera_provider.dart';
import 'package:pdf_scanner_pro/presentation/state/theme_provider.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final isar = await DocumentRepository.init();
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera error: $e');
  }
  
  runApp(
    ProviderScope(
      overrides: [
        documentRepositoryProvider.overrideWithValue(DocumentRepository(isar)),
        camerasProvider.overrideWith((ref) => cameras),
      ],
      child: const PDFScannerApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class PDFScannerApp extends ConsumerWidget {
  const PDFScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Ekasar',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
// Update: fix: Resolve edge case in document boundary detection
// Update: refactor: Optimize memory usage during image compression
// Update: style: Improve bottom sheet corner radius
// Update: perf: Reduce latency when opening the camera
// Update: fix: Handle null context properly when navigating
// Update: refactor: Extract filter logic into separate methods
// Update: feat: Improve error messages for better UX
// Update: fix: Fix padding overflow on smaller screens
// Update: chore: Update dependencies to latest versions
// Update: style: Tweak primary button colors for higher contrast
// Update: fix: Prevent memory leak in WavePainter animation
