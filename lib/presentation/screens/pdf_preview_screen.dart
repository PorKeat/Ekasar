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

  Future<void> _sharePdf() async {
    await Share.shareXFiles(
      [XFile(widget.pdfFile.path)],
      text: 'Sharing ${_titleController.text}.pdf',
    );
  }

  Future<void> _savePdf() async {
    if (_titleController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context,
        title: 'Missing Title',
        message: 'Please enter a document title to save.',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${_titleController.text}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savedFile = await widget.pdfFile.copy(path.join(appDir.path, fileName));

      final doc = ScannedDocument()
        ..title = _titleController.text
        ..filePath = savedFile.path
        ..sizeInBytes = await savedFile.length()
        ..createdAt = DateTime.now();

      final repo = ref.read(documentRepositoryProvider);
      await repo.saveDocument(doc);

      if (mounted) {
        CustomSnackBar.show(
          context,
          title: 'Success',
          message: 'Document saved successfully!',
          type: SnackBarType.success,
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          title: 'Save Failed',
          message: 'Unable to save document. Please try again.',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Document Title',
            hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
          ),
        ),
        actions: [
          if (_isExtracting)
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.text_snippet),
              tooltip: 'Extract Text (OCR)',
              onPressed: _extractText,
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SfPdfViewer.file(
                    widget.pdfFile,
                    canShowScrollHead: false,
                    canShowScrollStatus: false,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Document',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
