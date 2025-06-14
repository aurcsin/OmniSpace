// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackerAdapter extends TypeAdapter<Tracker> {
  @override
  final int typeId = 8;

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
      childIds: (fields[6] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Tracker obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.childIds);
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
