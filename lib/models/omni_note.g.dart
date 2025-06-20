// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omni_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OmniNoteAdapter extends TypeAdapter<OmniNote> {
  @override
  final int typeId = 0;

  @override
  OmniNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OmniNote(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      content: fields[3] as String,
      zone: fields[4] as ZoneTheme,
      tags: fields[5] as String,
      colorValue: fields[6] as int,
      mood: fields[7] as String?,
      direction: fields[8] as String?,
      projectId: fields[9] as String?,
      recommendedTag: fields[10] as String?,
      seriesId: fields[11] as String?,
      attachments: (fields[12] as List?)?.cast<Attachment>(),
      tasks: (fields[13] as List?)?.cast<Task>(),
      goals: (fields[14] as List?)?.cast<Goal>(),
      events: (fields[15] as List?)?.cast<Event>(),
      createdAt: fields[16] as DateTime?,
      lastUpdated: fields[17] as DateTime?,
      isPinned: fields[18] as bool,
      isStarred: fields[19] as bool,
      isArchived: fields[20] as bool,
      isTrashed: fields[21] as bool,
      isLocked: fields[22] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OmniNote obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.zone)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.mood)
      ..writeByte(8)
      ..write(obj.direction)
      ..writeByte(9)
      ..write(obj.projectId)
      ..writeByte(10)
      ..write(obj.recommendedTag)
      ..writeByte(11)
      ..write(obj.seriesId)
      ..writeByte(12)
      ..write(obj.attachments)
      ..writeByte(13)
      ..write(obj.tasks)
      ..writeByte(14)
      ..write(obj.goals)
      ..writeByte(15)
      ..write(obj.events)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.lastUpdated)
      ..writeByte(18)
      ..write(obj.isPinned)
      ..writeByte(19)
      ..write(obj.isStarred)
      ..writeByte(20)
      ..write(obj.isArchived)
      ..writeByte(21)
      ..write(obj.isTrashed)
      ..writeByte(22)
      ..write(obj.isLocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OmniNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
