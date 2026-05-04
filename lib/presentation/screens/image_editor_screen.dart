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
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          title: 'Scan Failed',
          message: 'Unable to process document. Please try again.',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildFilterThumbnail(String label, FilterType type, ColorFilter? filter) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: filter != null
                      ? ColorFiltered(
                          colorFilter: filter,
                          child: Image.file(_currentImage, fit: BoxFit.cover),
                        )
                      : Image.file(_currentImage, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                fontSize: 12,
                color: isSelected ? AppColors.secondary : Theme.of(context).textTheme.bodyMedium?.color,
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorFilter? currentPreviewFilter;
    if (_selectedFilter == FilterType.magicColor) {
      currentPreviewFilter = const ColorFilter.matrix([
        1.8, 0, 0, 0, 20,
        0, 1.8, 0, 0, 20,
        0, 0, 1.8, 0, 20,
        0, 0, 0, 1, 0,
      ]);
    } else if (_selectedFilter == FilterType.bwDocument) {
      currentPreviewFilter = const ColorFilter.matrix([
        0.83, 0.83, 0.83, 0, 30,
        0.83, 0.83, 0.83, 0, 30,
        0.83, 0.83, 0.83, 0, 30,
        0, 0, 0, 1, 0,
      ]);
    } else if (_selectedFilter == FilterType.grayscale) {
      currentPreviewFilter = const ColorFilter.matrix([
        0.33, 0.59, 0.11, 0, 0,
        0.33, 0.59, 0.11, 0, 0,
        0.33, 0.59, 0.11, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    } else if (_selectedFilter == FilterType.lighten) {
      currentPreviewFilter = const ColorFilter.matrix([
        1.2, 0, 0, 0, 40,
        0, 1.2, 0, 0, 40,
        0, 0, 1.2, 0, 40,
        0, 0, 0, 1, 0,
      ]);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F15),
      appBar: AppBar(
        title: const Text('Edit Document'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_rotate),
            onPressed: _cropImage,
            tooltip: 'Crop / Rotate',
          ),
          if (!_isProcessing)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _processAndSave,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                ),
                child: const Text('Save PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: currentPreviewFilter != null
                              ? ColorFiltered(
                                  colorFilter: currentPreviewFilter,
                                  child: Image.file(_currentImage),
                                )
                              : Image.file(_currentImage),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildFilterThumbnail('Original', FilterType.original, null),
                          _buildFilterThumbnail('Magic', FilterType.magicColor, const ColorFilter.matrix([
                            1.3, 0, 0, 0, 15,
                            0, 1.3, 0, 0, 15,
                            0, 0, 1.3, 0, 15,
                            0, 0, 0, 1, 0,
                          ])),
                          _buildFilterThumbnail('B & W', FilterType.bwDocument, const ColorFilter.matrix([
                            0.8, 0.8, 0.8, 0, 20,
                            0.8, 0.8, 0.8, 0, 20,
                            0.8, 0.8, 0.8, 0, 20,
                            0, 0, 0, 1, 0,
                          ])),
                          _buildFilterThumbnail('Grayscale', FilterType.grayscale, const ColorFilter.matrix([
                            0.33, 0.59, 0.11, 0, 0,
                            0.33, 0.59, 0.11, 0, 0,
                            0.33, 0.59, 0.11, 0, 0,
                            0, 0, 0, 1, 0,
                          ])),
                          _buildFilterThumbnail('Lighten', FilterType.lighten, const ColorFilter.matrix([
                            1.1, 0, 0, 0, 30,
                            0, 1.1, 0, 0, 30,
                            0, 0, 1.1, 0, 30,
                            0, 0, 0, 1, 0,
                          ])),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
