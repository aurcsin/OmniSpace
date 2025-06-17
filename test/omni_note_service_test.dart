import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:omnispace/models/attachment.dart';
import 'package:omnispace/models/event.dart';
import 'package:omnispace/models/goal.dart';
import 'package:omnispace/models/omni_note.dart';
import 'package:omnispace/models/task.dart';
import 'package:omnispace/services/omni_note_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('omni_note_test');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(OmniNoteAdapter().typeId)) {
      Hive.registerAdapter(OmniNoteAdapter());
    }
    if (!Hive.isAdapterRegistered(ZoneThemeAdapter().typeId)) {
      Hive.registerAdapter(ZoneThemeAdapter());
    }
    if (!Hive.isAdapterRegistered(AttachmentAdapter().typeId)) {
      Hive.registerAdapter(AttachmentAdapter());
    }
    if (!Hive.isAdapterRegistered(AttachmentTypeAdapter().typeId)) {
      Hive.registerAdapter(AttachmentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(TaskAdapter().typeId)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(EventAdapter().typeId)) {
      Hive.registerAdapter(EventAdapter());
    }

    await OmniNoteService.instance.init();
  });

  tearDown(() async {
    await Hive.box<OmniNote>('notes').close();
    await Hive.deleteBoxFromDisk('notes');
    await tempDir.delete(recursive: true);
  });

  test('saveNote persists zone field', () async {
    final note = OmniNote(id: 'n1', zone: ZoneTheme.Fire);
    await OmniNoteService.instance.saveNote(note);

    final fetched = OmniNoteService.instance.getNoteById('n1');
    expect(fetched, isNotNull);
    expect(fetched!.zone, ZoneTheme.Fire);
  });
}
