import 'package:isar/isar.dart';
part 'folder.g.dart';

@collection
class Folder {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  DateTime createdAt = DateTime.now();
}
