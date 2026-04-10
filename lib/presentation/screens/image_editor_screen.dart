import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:pdf_scanner_pro/presentation/screens/pdf_preview_screen.dart';
import 'package:pdf_scanner_pro/core/utils/pdf_generator.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

enum FilterType { original, magicColor, bwDocument, grayscale, lighten }

class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  const ImageEditorScreen({super.key, required this.imageFile});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late File _currentImage;
  FilterType _selectedFilter = FilterType.original;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentImage.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Document',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop Document',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _currentImage = File(croppedFile.path);
        // Reset filter when cropped
        _selectedFilter = FilterType.original;
      });
    }
  }

  Future<void> _processAndSave() async {
    setState(() => _isProcessing = true);

    try {
      File finalFile = _currentImage;

      if (_selectedFilter != FilterType.original) {
        // Run in background if possible, but for simplicity await here
        final bytes = await _currentImage.readAsBytes();
        var decodedImage = img.decodeImage(bytes);
        
        if (decodedImage != null) {
          if (_selectedFilter == FilterType.magicColor) {
            decodedImage = img.adjustColor(decodedImage, contrast: 1.8, brightness: 1.4, saturation: 1.2);
          } else if (_selectedFilter == FilterType.bwDocument) {
            decodedImage = img.adjustColor(decodedImage, contrast: 2.5, brightness: 1.5, saturation: 0.0);
          } else if (_selectedFilter == FilterType.grayscale) {
            decodedImage = img.adjustColor(decodedImage, saturation: 0.0);
          } else if (_selectedFilter == FilterType.lighten) {
            decodedImage = img.adjustColor(decodedImage, brightness: 1.5, contrast: 1.1);
          }
          
          final outBytes = img.encodeJpg(decodedImage, quality: 90);
          final tempDir = _currentImage.parent;
          final outFile = File('${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await outFile.writeAsBytes(outBytes);
          finalFile = outFile;
        }
      }

      final pdfFile = await PdfGenerator.generatePdfFromImage(finalFile);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(
              pdfFile: pdfFile,
              images: [finalFile.path],
            ),
          ),
        );
