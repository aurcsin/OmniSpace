import 'package:hive/hive.dart';
import 'package:omnispace/models/omni_note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final _noteBox = Hive.box<OmniNote>('omni_notes');

  List<OmniNote> getAllNotes() {
    return _noteBox.values.toList();
  }

  Future<void> insertNote(OmniNote note) async {
    await _noteBox.add(note);
  }

  Future<void> updateNote(OmniNote note) async {
    await note.save();
  }

  Future<void> deleteNote(OmniNote note) async {
    await note.delete();
  }
}
