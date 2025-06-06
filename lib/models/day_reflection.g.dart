// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_reflection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayReflectionAdapter extends TypeAdapter<DayReflection> {
  @override
  final int typeId = 2;

  @override
  DayReflection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayReflection(
      dateKey: fields[0] as String,
      summary: fields[1] as String,
      noteIds: (fields[2] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, DayReflection obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.summary)
      ..writeByte(2)
      ..write(obj.noteIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayReflectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
