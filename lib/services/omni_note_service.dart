// lib/services/omni_note_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';          // Used for Attachment and AttachmentType
import 'garden_service.dart';
import 'stats_service.dart';
import 'spirit_buddy_service.dart';

class OmniNoteService extends ChangeNotifier {
  OmniNoteService._();
  static final OmniNoteService instance = OmniNoteService._();

  static const String _boxName = 'omni_notes_box';
  Box<OmniNote>? _box;

  final List<OmniNote> _notes = [];
  List<OmniNote> get notes => List.unmodifiable(_notes);

  /// ------------------------------------------------------
  /// initHive()
  /// Called from main() after registering adapters.
  /// Just open the Hive box and load all existing notes.
  /// ------------------------------------------------------
  Future<void> initHive() async {
    _box = await Hive.openBox<OmniNote>(_boxName);
    _notes
      ..clear()
      ..addAll(
        _box!.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
    notifyListeners();
  }

  /// Reload all notes from Hive into memory
  Future<void> loadAllNotes() async {
    if (_box == null) {
      await initHive();
      return;
    }
    _notes
      ..clear()
      ..addAll(
        _box!.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
    notifyListeners();
  }

  /// Create a new note (text + any existing attachments in the model),
  /// then fire integrations and reload.
  Future<void> createNote(OmniNote note) async {
    if (_box == null) await initHive();
    await _box!.add(note); // Hive auto-assigns a key to note.id

    // Integration stubs
    await GardenService.instance.addFlowerFromEntry(note);
    await StatsService.instance.updateStatsForEntry(note);
    SpiritBuddyService.instance.reflectOnEntry(note);

    await loadAllNotes();
  }

  /// Update an existing note (text/metadata changes only),
  /// then fire integrations and reload.
  Future<void> updateNote(OmniNote note) async {
    if (_box == null) await initHive();
    await note.save();

    // Integration stubs
    await GardenService.instance.addFlowerFromEntry(note);
    await StatsService.instance.updateStatsForEntry(note);
    SpiritBuddyService.instance.reflectOnEntry(note);

    await loadAllNotes();
  }

  /// Delete a note (all attachments remain on disk unless you clean them manually),
  /// then reload.
  Future<void> deleteNote(OmniNote note) async {
    if (_box == null) await initHive();
    await note.delete();
    await loadAllNotes();
  }

  /// Search text content, tags, recommendedTag over all notes
  Future<List<OmniNote>> searchNotes(String query) async {
    if (_box == null) await initHive();
    final lowerQ = query.toLowerCase().trim();
    if (lowerQ.isEmpty) {
      return _box!.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final results = _box!.values.where((note) {
      final inTitle = note.title.toLowerCase().contains(lowerQ);
      final inSub = note.subtitle.toLowerCase().contains(lowerQ);
      final inContent = note.content.toLowerCase().contains(lowerQ);
      final inTags = note.tags.toLowerCase().contains(lowerQ);
      final inRecTag = note.recommendedTag?.toLowerCase().contains(lowerQ) ?? false;
      return inTitle || inSub || inContent || inTags || inRecTag;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results;
  }

  /// -------------------------------------------------------------------------
  /// Attach an IMAGE to an existing or newly created note:
  /// 1) Copy the picked File into app-specific folder
  /// 2) Create an Attachment(type=image, localPath=savedPath)
  /// 3) Append to note.attachments, call note.save()
  /// 4) Reload note list
  /// -------------------------------------------------------------------------
  Future<void> addImageAttachment(OmniNote note, File pickedImage) async {
    if (_box == null) await initHive();

    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/notes');
    if (!await notesDir.exists()) await notesDir.create(recursive: true);

    // Unique filename using timestamp
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await pickedImage.copy('${notesDir.path}/$fileName');

    final attachment = Attachment(
      type: AttachmentType.image,
      localPath: savedImage.path,
      createdAt: DateTime.now(),
    );
    note.attachments.add(attachment);
    await note.save();

    await loadAllNotes();
  }

  /// -------------------------------------------------------------------------
  /// Attach an AUDIO (voice note) to a note:
  /// 1) Copy the recorded file into app-specific folder
  /// 2) Create Attachment(type=audio, localPath=... )
  /// 3) Append + save + reload
  /// -------------------------------------------------------------------------
  Future<void> addAudioAttachment(OmniNote note, File recordedAudio) async {
    if (_box == null) await initHive();

    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/notes');
    if (!await notesDir.exists()) await notesDir.create(recursive: true);

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    final savedAudio = await recordedAudio.copy('${notesDir.path}/$fileName');

    final attachment = Attachment(
      type: AttachmentType.audio,
      localPath: savedAudio.path,
      createdAt: DateTime.now(),
      transcription: null, // can fill later if you do AI transcription
    );
    note.attachments.add(attachment);
    await note.save();

    await loadAllNotes();
  }

  /// -------------------------------------------------------------------------
  /// Attach a VIDEO to a note:
  /// 1) Copy the captured/picked video file into a local folder
  /// 2) Create Attachment(type=video, localPath=... )
  /// 3) Append, save, reload
  /// -------------------------------------------------------------------------
  Future<void> addVideoAttachment(OmniNote note, File videoFile) async {
    if (_box == null) await initHive();

    final appDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${appDir.path}/notes');
    if (!await notesDir.exists()) await notesDir.create(recursive: true);

    final fileName = 'vid_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedVideo = await videoFile.copy('${notesDir.path}/$fileName');

    // We’re not generating a thumbnail here, so leave thumbnailPath null
    final attachment = Attachment(
      type: AttachmentType.video,
      localPath: savedVideo.path,
      createdAt: DateTime.now(),
      thumbnailPath: null,
    );
    note.attachments.add(attachment);
    await note.save();

    await loadAllNotes();
  }
}
