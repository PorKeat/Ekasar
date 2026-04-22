import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf_scanner_pro/core/utils/pdf_generator.dart';
import 'package:pdf_scanner_pro/presentation/screens/pdf_preview_screen.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

class ImagePreviewScreen extends StatefulWidget {
  final XFile imageFile;

  const ImagePreviewScreen({super.key, required this.imageFile});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  bool _isGeneratingPdf = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_rotate),
            onPressed: () {
              // TODO: Implement image rotation
              CustomSnackBar.show(
                context,
                title: 'Coming Soon',
                message: 'Rotate feature is coming soon.',
                type: SnackBarType.warning,
              );
            },
          ),
        ],
      ),
