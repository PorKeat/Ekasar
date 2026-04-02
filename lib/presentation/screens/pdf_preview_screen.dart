import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';
import 'package:pdf_scanner_pro/domain/models/document.dart';
import 'package:pdf_scanner_pro/presentation/state/settings_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PdfPreviewScreen extends ConsumerStatefulWidget {
  final File pdfFile;
  final List<String> images;

  const PdfPreviewScreen({
    super.key, 
    required this.pdfFile,
    this.images = const [],
  });

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  late final TextEditingController _titleController;
  bool _isSaving = false;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    final defaultPrefix = ref.read(settingsProvider).defaultScanPrefix;
    _titleController = TextEditingController(text: '${defaultPrefix}_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _extractText() async {
    if (widget.images.isEmpty) {
      CustomSnackBar.show(
        context,
        title: 'OCR Unavailable',
        message: 'No images available for text extraction.',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() => _isExtracting = true);
    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final StringBuffer extractedText = StringBuffer();
      
      for (String imagePath in widget.images) {
        final rawPath = imagePath.startsWith('file://') ? imagePath.replaceFirst('file://', '') : imagePath;
        final inputImage = InputImage.fromFilePath(rawPath);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        extractedText.writeln(recognizedText.text);
        extractedText.writeln('\n--- Page Break ---\n');
      }
      textRecognizer.close();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Extracted Text'),
            content: SingleChildScrollView(child: SelectableText(extractedText.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () => Share.share(extractedText.toString()),
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          title: 'Action Failed',
          message: 'Unable to share document. Please try again.',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isExtracting = false);
    }
  }
