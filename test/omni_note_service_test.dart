// File: test/services/omni_note_service_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:omnispace/services/omni_note_service.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/zone_theme.dart';

void main() {
  group('OmniNoteService', () {
    setUpAll(() async {
      // Initialize Hive in a temporary directory for tests
      final tempDir = Directory.systemTemp.createTempSync();
      Hive.init(tempDir.path);

      // Initialize the service (registers adapters and opens the box)
      await OmniNoteService.instance.init();
    });

    setUp(() async {
      // Clear the box before each test
      final box = Hive.box<OmniNote>('omni_notes');
      await box.clear();
    });

    test('initially has no notes', () {
      expect(OmniNoteService.instance.notes, isEmpty);
      expect(OmniNoteService.instance.trashedNotes, isEmpty);
    });

    test('saveNote and getById works', () async {
      final note = OmniNote(id: '1', title: 'Test Title', subtitle: 'Sub', content: 'Content');
      await OmniNoteService.instance.saveNote(note);

      final fetched = OmniNoteService.instance.getById('1');
      expect(fetched, isNotNull);
      expect(fetched!.title, equals('Test Title'));
      expect(OmniNoteService.instance.notes.length, equals(1));
    });

    test('trashNote moves note to trashedNotes', () async {
      final note = OmniNote(id: '2');
      await OmniNoteService.instance.save(note);
      await OmniNoteService.instance.trashNote('2');

      expect(OmniNoteService.instance.notes, isEmpty);
      expect(OmniNoteService.instance.trashedNotes.length, equals(1));
    });

    test('restoreNote moves note back to notes', () async {
      final note = OmniNote(id: '3');
      await OmniNoteService.instance.save(note);
      await OmniNoteService.instance.trashNote('3');
      await OmniNoteService.instance.restoreNote('3');

      expect(OmniNoteService.instance.notes.length, equals(1));
      expect(OmniNoteService.instance.trashedNotes, isEmpty);
    });

    test('deleteNote deletes permanently', () async {
      final note = OmniNote(id: '4');
      await OmniNoteService.instance.save(note);
      await OmniNoteService.instance.deleteNote('4');

      final fetched = OmniNoteService.instance.getById('4');
      expect(fetched, isNull);
      expect(OmniNoteService.instance.notes, isEmpty);
    });

    test('deletePermanent deletes multiple notes', () async {
      final noteA = OmniNote(id: 'a');
      final noteB = OmniNote(id: 'b');
      await OmniNoteService.instance.save(noteA);
      await OmniNoteService.instance.save(noteB);

      expect(OmniNoteService.instance.notes.length, equals(2));
      await OmniNoteService.instance.deletePermanent(['a', 'b']);
      expect(OmniNoteService.instance.notes, isEmpty);
    });

    test('all async returns all notes including trashed', () async {
      final note = OmniNote(id: 'x');
      await OmniNoteService.instance.save(note);
      await OmniNoteService.instance.trashNote('x');

      final allNotes = await OmniNoteService.instance.all;
      expect(allNotes.length, equals(1));
      expect(allNotes.first.isTrashed, isTrue);
    });
  });
}
