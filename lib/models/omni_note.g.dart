// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omni_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OmniNoteAdapter extends TypeAdapter<OmniNote> {
  @override
  final int typeId = 1;

  @override
  OmniNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OmniNote(
      title: fields[0] as String,
      subtitle: fields[1] as String,
      content: fields[2] as String,
      zone: fields[3] as ZoneTheme,
      recommendedTag: fields[4] as String?,
      tags: fields[5] as String,
      createdAt: fields[6] as DateTime?,
      attachments: (fields[7] as List?)?.cast<Attachment>(),
      tasks: (fields[8] as List?)?.cast<Task>(),
      goals: (fields[9] as List?)?.cast<Goal>(),
      events: (fields[10] as List?)?.cast<Event>(),
      mood: fields[11] as String?,
      direction: fields[12] as String?,
      projectId: fields[13] as String?,
      colorValue: fields[14] as int?,
      starred: fields[15] as bool?,
      pinned: fields[16] as bool?,
      archived: fields[17] as bool?,
      isPrivate: fields[18] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, OmniNote obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.zone)
      ..writeByte(4)
      ..write(obj.recommendedTag)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.attachments)
      ..writeByte(8)
      ..write(obj.tasks)
      ..writeByte(9)
      ..write(obj.goals)
      ..writeByte(10)
      ..write(obj.events)
      ..writeByte(11)
      ..write(obj.mood)
      ..writeByte(12)
      ..write(obj.direction)
      ..writeByte(13)
      ..write(obj.projectId)
      ..writeByte(14)
      ..write(obj.colorValue)
      ..writeByte(15)
      ..write(obj.starred)
      ..writeByte(16)
      ..write(obj.pinned)
      ..writeByte(17)
      ..write(obj.archived)
      ..writeByte(18)
      ..write(obj.isPrivate);
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

class ZoneThemeAdapter extends TypeAdapter<ZoneTheme> {
  @override
  final int typeId = 0;

  @override
  ZoneTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZoneTheme.Air;
      case 1:
        return ZoneTheme.Earth;
      case 2:
        return ZoneTheme.Fire;
      case 3:
        return ZoneTheme.Water;
      case 4:
        return ZoneTheme.Void;
      case 5:
        return ZoneTheme.Fusion;
      default:
        return ZoneTheme.Air;
    }
  }

  @override
  void write(BinaryWriter writer, ZoneTheme obj) {
    switch (obj) {
      case ZoneTheme.Air:
        writer.writeByte(0);
        break;
      case ZoneTheme.Earth:
        writer.writeByte(1);
        break;
      case ZoneTheme.Fire:
        writer.writeByte(2);
        break;
      case ZoneTheme.Water:
        writer.writeByte(3);
        break;
      case ZoneTheme.Void:
        writer.writeByte(4);
        break;
      case ZoneTheme.Fusion:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
