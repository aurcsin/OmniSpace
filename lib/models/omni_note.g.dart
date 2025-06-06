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
      id: fields[0] as int?,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      content: fields[3] as String,
      tags: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      zoneTheme: fields[6] as String,
      isPinned: fields[7] as bool,
      mediaPaths: (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, OmniNote obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.zoneTheme)
      ..writeByte(7)
      ..write(obj.isPinned)
      ..writeByte(8)
      ..write(obj.mediaPaths);
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
