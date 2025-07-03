// File: lib/models/note_collection.dart

import 'package:hive/hive.dart';

part 'note_collection.g.dart';

/// A user-defined grouping of notes.
@HiveType(typeId: 6) // pick an unused typeId—make sure it doesn’t collide!
class NoteCollection extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> noteIds;

  NoteCollection({
    required this.id,
    required this.name,
    this.noteIds = const [],
  });
}
