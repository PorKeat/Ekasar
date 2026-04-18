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
// Update: perf: Cache decoded images to speed up filtering
// Update: refactor: Clean up unused imports in presentation layer
// Update: fix: Fix state bug when canceling image crop
// Update: feat: Enhance Grayscale filter matrix for documents
// Update: style: Update typography for titles
// Update: fix: Address PDF generation issue on Android 13
// Update: perf: Defer heavy computations in ImageEditorScreen
// Update: refactor: Simplify logic in PdfGenerator
// Update: chore: Clean up old debug logs
// Update: style: Adjust shadow elevation on PDF preview cards
// Update: fix: Fix rotation bug when picking images from gallery
// Update: feat: Add subtle micro-animations to UI buttons
// Update: refactor: Restructure core utilities folder
// Update: fix: Resolve layout overflow in landscape mode
// Update: perf: Optimize list view scrolling on Home Screen
// Update: chore: Bump build number for internal testing
