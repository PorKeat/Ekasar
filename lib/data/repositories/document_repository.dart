import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_scanner_pro/domain/models/document.dart';
import 'package:pdf_scanner_pro/domain/models/folder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  throw UnimplementedError('Isar is not initialized yet');
});

class DocumentRepository {
  final Isar isar;

  DocumentRepository(this.isar);

  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [ScannedDocumentSchema, FolderSchema],
      directory: dir.path,
    );
  }

  // Document Methods
  Future<int> saveDocument(ScannedDocument doc) async {
    return await isar.writeTxn(() async {
      return await isar.scannedDocuments.put(doc);
    });
  }

  Stream<List<ScannedDocument>> watchAllDocuments() {
    return isar.scannedDocuments.where().sortByCreatedAtDesc().watch(fireImmediately: true);
  }
  
  Future<void> deleteDocument(Id id) async {
    await isar.writeTxn(() async {
      await isar.scannedDocuments.delete(id);
    });
  }
  
  Future<void> clearAllDocuments() async {
    await isar.writeTxn(() async {
      await isar.scannedDocuments.clear();
    });
  }
  
  // OCR methods (to be added)
}
