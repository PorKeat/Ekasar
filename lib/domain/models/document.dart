import 'package:isar/isar.dart';
part 'document.g.dart';

@collection
class ScannedDocument {
  Id id = Isar.autoIncrement;

  late String title;
  
  late String filePath;

  late int sizeInBytes;

  DateTime createdAt = DateTime.now();

  bool isFavorite = false;
  
  bool isTrash = false;
  
  int? folderId;
}
