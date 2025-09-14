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
