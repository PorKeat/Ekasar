import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_scanner_pro/core/theme/app_colors.dart';
import 'package:pdf_scanner_pro/core/theme/wave_painter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:pdf_scanner_pro/presentation/screens/settings_screen.dart';
import 'package:pdf_scanner_pro/presentation/screens/pdf_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf_scanner_pro/presentation/screens/image_editor_screen.dart';
import 'package:pdf_scanner_pro/core/utils/pdf_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf_scanner_pro/presentation/widgets/custom_snackbar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_scanner_pro/presentation/state/document_provider.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';
import 'package:intl/intl.dart';
import 'package:pdf_scanner_pro/main.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsStreamProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const AnimatedWaveBackground(height: 220),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ekasar',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              'Scan and digitize your documents instantly',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2, end: 0),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Scans',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: docsAsync.when(
                            data: (docs) {
                              if (docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.document_scanner_outlined,
                                        size: 64,
                                        color: AppColors.textSecondary.withOpacity(0.3),
                                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 2.seconds),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No documents yet',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap the + button to start scanning',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final doc = docs[index];
                                  return Dismissible(
                                key: ValueKey(doc.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  color: Colors.red.shade400,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  return await _showDeleteConfirmation(context, doc.title);
                                },
                                onDismissed: (direction) async {
                                  final repo = ref.read(documentRepositoryProvider);
                                  await repo.deleteDocument(doc.id);
                                  if (context.mounted) {
                                    CustomSnackBar.show(
                                      context,
                                      title: 'Deleted',
                                      message: '${doc.title} was removed.',
                                      type: SnackBarType.success,
                                    );
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary, size: 32),
                                    title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(DateFormat.yMMMd().format(doc.createdAt)),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'share') {
                                          Share.shareXFiles([XFile(doc.filePath)], text: 'Sharing ${doc.title}.pdf');
                                        } else if (value == 'delete') {
                                          final shouldDelete = await _showDeleteConfirmation(context, doc.title);
                                          if (shouldDelete == true) {
                                            final repo = ref.read(documentRepositoryProvider);
                                            if (navigatorKey.currentContext != null) {
                                              CustomSnackBar.show(
                                                navigatorKey.currentContext!,
                                                title: 'Deleted',
                                                message: '${doc.title} was removed.',
                                                type: SnackBarType.success,
                                              );
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'share',
                                          child: Row(children: [Icon(Icons.share, size: 20), SizedBox(width: 8), Text('Share')]),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PdfPreviewScreen(pdfFile: File(doc.filePath)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.2, end: 0);
                            },
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, st) => Center(child: Text('Error loading documents: $e')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showScanOptions(context);
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('New Scan', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 800.ms, duration: 400.ms, curve: Curves.elasticOut),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add Document',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _OptionButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _startProfessionalScan(context);
                      },
                    ),
                    _OptionButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickFromGallery();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, String title) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "$title"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imgFile = File(image.path);
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ImageEditorScreen(imageFile: imgFile),
          ),
        );
      }
    } catch (e) {
      if (navigatorKey.currentContext != null) {
        CustomSnackBar.show(
          navigatorKey.currentContext!,
          title: 'Scan Failed',
          message: 'Unable to open image. Please try again.',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _startProfessionalScan(BuildContext context) async {
    final options = DocumentScannerOptions(
      documentFormats: {DocumentFormat.pdf, DocumentFormat.jpeg},
      pageLimit: 10,
      mode: ScannerMode.full,
      isGalleryImport: false,
    );
    final documentScanner = DocumentScanner(options: options);
    
    try {
      final result = await documentScanner.scanDocument();
      
      // Use root navigator key to avoid context.mounted issues across native activity gaps
      final navigator = navigatorKey.currentState!;
      
      if (result.pdf != null) {
        final String rawUri = result.pdf!.uri;
        final String filePath = rawUri.startsWith('file://') ? rawUri.replaceFirst('file://', '') : rawUri;
        
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(
              pdfFile: File(filePath),
              images: result.images ?? [],
            ),
          ),
        );
      } else if (result.images != null && result.images!.isNotEmpty) {
        final imgFile = File(result.images!.first);
        final pdfFile = await PdfGenerator.generatePdfFromImage(imgFile);
        navigator.push(
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(
              pdfFile: pdfFile,
              images: result.images!,
            ),
          ),
        );
      } else {
        if (navigatorKey.currentContext != null) {
          CustomSnackBar.show(
            navigatorKey.currentContext!,
            title: 'Scan Cancelled',
            message: 'No document was returned from the scanner.',
            type: SnackBarType.warning,
          );
        }
      }
    } catch (e) {
      if (navigatorKey.currentContext != null) {
        CustomSnackBar.show(
          navigatorKey.currentContext!,
          title: 'Scan Failed',
          message: 'Unable to start scanner. Please try again.',
          type: SnackBarType.error,
        );
      }
    } finally {
      documentScanner.close();
    }
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
