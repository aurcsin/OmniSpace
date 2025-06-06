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
    );
  }

  @override
  void write(BinaryWriter writer, OmniNote obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.createdAt);
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
