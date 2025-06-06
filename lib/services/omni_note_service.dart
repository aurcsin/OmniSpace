import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/omni_note.dart';
import '../models/attachment.dart';
import '../models/task.dart';
import '../models/goal.dart';
import '../models/event.dart';

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

  Future<void> initHive() async {
    _box = await Hive.openBox<OmniNote>(_boxName);
    await loadAllNotes();
  }

  Future<void> loadAllNotes() async {
    if (_box == null) await initHive();
    _notes
      ..clear()
      ..addAll(
        _box!
            .values
            .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
    notifyListeners();
  }

  Future<void> createNote(OmniNote note) async {
    if (_box == null) await initHive();
    await _box!.add(note);
    await GardenService.instance.addFlowerFromEntry(note);
    await StatsService.instance.updateStatsForEntry(note);
    SpiritBuddyService.instance.reflectOnEntry(note);
    await loadAllNotes();
  }

  Future<void> updateNote(OmniNote note) async {
    if (_box == null) await initHive();
    await note.save();
    await GardenService.instance.addFlowerFromEntry(note);
    await StatsService.instance.updateStatsForEntry(note);
    SpiritBuddyService.instance.reflectOnEntry(note);
    await loadAllNotes();
  }

  Future<void> deleteNote(OmniNote note) async {
    if (_box == null) await initHive();
    await note.delete();
    await loadAllNotes();
  }

  Future<List<OmniNote>> searchNotes(String query) async {
    if (_box == null) await initHive();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return notes;
    final results = _box!.values.where((note) {
      return note.title.toLowerCase().contains(q) ||
          note.subtitle.toLowerCase().contains(q) ||
          note.content.toLowerCase().contains(q) ||
          note.tags.toLowerCase().contains(q) ||
          (note.recommendedTag?.toLowerCase().contains(q) ?? false) ||
          (note.mood?.toLowerCase().contains(q) ?? false);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  // ─────────── Attachment Helpers ───────────

  Future<void> addImageAttachment(OmniNote note, File pickedImage) async {
    if (_box == null) await initHive();
    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${dir.path}/notes');
    if (!await notesDir.exists()) await notesDir.create(recursive: true);
    final saved = await pickedImage.copy('${notesDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg');
    note.attachments.add(
      Attachment(type: AttachmentType.image, localPath: saved.path, createdAt: DateTime.now()),
    );
    await note.save();
    await loadAllNotes();
  }

  Future<void> addAudioAttachment(OmniNote note, File recordedAudio) async {
    if (_box == null) await initHive();
    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${dir.path}/notes');
    if (!await notesDir.exists()) await notesDir.create(recursive: true);
    final saved = await recordedAudio.copy('${notesDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac');
    note.attachments.add(
      Attachment(type: AttachmentType.audio, localPath: saved.path, createdAt: DateTime.now()),
    );
    await note.save();
    await loadAllNotes();
  }

  Future<void> addVideoAttachment(OmniNote note, File videoFile) async {
    if (_box == null) await initHive();
    final dir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${dir.path}/notes');
    if (!await notesDir.exists()) await notesDir.create(recursive: true);
    final saved = await videoFile.copy('${notesDir.path}/vid_${DateTime.now().millisecondsSinceEpoch}.mp4');
    note.attachments.add(
      Attachment(type: AttachmentType.video, localPath: saved.path, createdAt: DateTime.now()),
    );
    await note.save();
    await loadAllNotes();
  }

  // ─────────── Task / Goal / Event Helpers ───────────

  Future<void> addTask(OmniNote note, Task task) async {
    if (_box == null) await initHive();
    note.tasks = (note.tasks ?? <Task>[])..add(task);
    await note.save();
    await loadAllNotes();
  }

  Future<void> removeTask(OmniNote note, Task task) async {
    if (_box == null) await initHive();
    (note.tasks ?? []).remove(task);
    await note.save();
    await loadAllNotes();
  }

  Future<void> addGoal(OmniNote note, Goal goal) async {
    if (_box == null) await initHive();
    note.goals = (note.goals ?? <Goal>[])..add(goal);
    await note.save();
    await loadAllNotes();
  }

  Future<void> removeGoal(OmniNote note, Goal goal) async {
    if (_box == null) await initHive();
    (note.goals ?? []).remove(goal);
    await note.save();
    await loadAllNotes();
  }

  Future<void> addEvent(OmniNote note, Event event) async {
    if (_box == null) await initHive();
    note.events = (note.events ?? <Event>[])..add(event);
    await note.save();
    await loadAllNotes();
  }

  Future<void> removeEvent(OmniNote note, Event event) async {
    if (_box == null) await initHive();
    (note.events ?? []).remove(event);
    await note.save();
    await loadAllNotes();
  }

  // ─────────── Star / Pin / Privacy / Archive ───────────

  Future<void> toggleStar(OmniNote note) async {
    if (_box == null) await initHive();
    note.starred = !note.starred;
    await note.save();
    await loadAllNotes();
  }

  Future<void> togglePin(OmniNote note) async {
    if (_box == null) await initHive();
    note.pinned = !note.pinned;
    await note.save();
    await loadAllNotes();
  }

  Future<void> togglePrivacy(OmniNote note) async {
    if (_box == null) await initHive();
    note.isPrivate = !note.isPrivate;
    await note.save();
    await loadAllNotes();
  }

  Future<void> archiveNote(OmniNote note) async {
    if (_box == null) await initHive();
    note.archived = true;
    await note.save();
    await loadAllNotes();
  }
}
