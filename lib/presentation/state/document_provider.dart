import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_scanner_pro/domain/models/document.dart';
import 'package:pdf_scanner_pro/data/repositories/document_repository.dart';

final documentsStreamProvider = StreamProvider<List<ScannedDocument>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchAllDocuments();
});
