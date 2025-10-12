import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:pdf_scanner_pro/presentation/state/camera_provider.dart';
import 'package:pdf_scanner_pro/presentation/screens/image_preview_screen.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: cameraState.when(
          data: (controller) {
            if (controller == null || !controller.value.isInitialized) {
              return const Center(
                child: Text(
                  'Camera not available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(controller),
                ),
                _buildOverlay(context),
