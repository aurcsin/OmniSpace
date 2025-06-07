// lib/services/omni_note_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';

class OmniNoteService extends ChangeNotifier {
  OmniNoteService._();
  static final instance = OmniNoteService._();

  late Box<OmniNote> _box;

  /// Call once at app startup (after registering adapters).
  Future<void> init() async {
    _box = await Hive.openBox<OmniNote>('notes');
    notifyListeners();
  }

  /// Ensure `init()` has run. Useful if someone forgot to await it.
  Future<void> _ensureInit() async {
    if (!Hive.isBoxOpen('notes')) {
      await init();
    }
  }

  /// All notes in insertion order.
  List<OmniNote> get notes => _box.values.toList();

  /// Reloads notes (no-op for Hive, but matches previous API).
  Future<void> loadAllNotes() async {
    await _ensureInit();
    notifyListeners();
  }

  /// Simple full‑text search on title or content.
  Future<List<OmniNote>> searchNotes(String query) async {
    await _ensureInit();
    final q = query.toLowerCase();
    return _box.values
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList();
  }

  /// Add a new note.
  Future<void> createNote(OmniNote note) async {
    await _ensureInit();
    await _box.add(note);
    notifyListeners();
  }

  /// Update an existing note (must have been saved once).
  Future<void> updateNote(OmniNote note) async {
    await _ensureInit();
    await note.save();
    notifyListeners();
  }

  /// Add an image attachment to the given note.
  Future<void> addImageAttachment(OmniNote note, File file) async {
    await _ensureInit();
    note.attachments.add(
      Attachment(type: AttachmentType.image, localPath: file.path),
    );
    await note.save();
    notifyListeners();
  }

  /// Add an audio attachment to the given note.
  Future<void> addAudioAttachment(OmniNote note, File file) async {
    await _ensureInit();
    note.attachments.add(
      Attachment(type: AttachmentType.audio, localPath: file.path),
    );
    await note.save();
    notifyListeners();
  }

  /// Add a video attachment to the given note.
  Future<void> addVideoAttachment(OmniNote note, File file) async {
    await _ensureInit();
    note.attachments.add(
      Attachment(type: AttachmentType.video, localPath: file.path),
    );
    await note.save();
    notifyListeners();
  }
}
