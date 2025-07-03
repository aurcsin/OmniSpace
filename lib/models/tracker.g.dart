// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackerAdapter extends TypeAdapter<Tracker> {
  @override
  final int typeId = 17;

  @override
  Tracker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tracker(
      id: fields[0] as String,
      type: fields[1] as TrackerType,
      title: fields[2] as String,
      progress: fields[3] as double?,
      frequency: fields[4] as String?,
      start: fields[5] as DateTime?,
      tags: fields[6] as String,
      isCompleted: fields[7] as bool,
      isTrashed: fields[8] as bool,
      childIds: (fields[9] as List?)?.cast<String>(),
      linkedTrackerIds: (fields[10] as List?)?.cast<String>(),
      linkedNoteIds: (fields[11] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tracker obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.progress)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.start)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.isTrashed)
      ..writeByte(9)
      ..write(obj.childIds)
      ..writeByte(10)
      ..write(obj.linkedTrackerIds)
      ..writeByte(11)
      ..write(obj.linkedNoteIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
