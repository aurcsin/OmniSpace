// File: test/omni_note_service_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/zone_theme.dart';
import 'package:omnispace/services/omni_note_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    // Create a fresh temp directory for Hive
    tempDir = await getTemporaryDirectory();
    Hive.init(tempDir.path);

    // Register adapters
    Hive.registerAdapter(OmniNoteAdapter());
    Hive.registerAdapter(ZoneThemeAdapter());

    // Initialize the service
    await OmniNoteService.instance.init();
  });

  tearDown(() async {
    // Close all boxes
    await Hive.close();
    // Delete temp dir
    await tempDir.delete(recursive: true);
  });

  test('saving and retrieving a note', () async {
    final service = OmniNoteService.instance;
    final note = OmniNote(
      id: 'note1',
      title: 'Test Note',
      content: 'Hello, world!',
      createdAt: DateTime(2025, 1, 1),
      lastUpdated: DateTime(2025, 1, 1),
    );

    await service.saveNote(note);

    final fetched = service.getById('note1');
    expect(fetched, isNotNull);
    expect(fetched!.title, equals('Test Note'));
    expect(service.notes.length, equals(1));
  });

  // ...other tests as before...
}
