// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineAdapter extends TypeAdapter<Routine> {
  @override
  final int typeId = 25;

  @override
  Routine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routine(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      start: fields[3] as DateTime?,
      frequency: fields[4] as String?,
      customDates: (fields[5] as List?)?.cast<String>(),
      linkedNoteIds: (fields[6] as List?)?.cast<String>(),
      linkedTrackerIds: (fields[7] as List?)?.cast<String>(),
      isCompleted: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
      lastUpdated: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Routine obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.start)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.customDates)
      ..writeByte(6)
      ..write(obj.linkedNoteIds)
      ..writeByte(7)
      ..write(obj.linkedTrackerIds)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
