// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackerCollectionAdapter extends TypeAdapter<TrackerCollection> {
  @override
  final int typeId = 22;

  @override
  TrackerCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackerCollection(
      id: fields[0] as String,
      name: fields[1] as String,
      ownerId: fields[2] as String,
      trackerIds: (fields[3] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TrackerCollection obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.trackerIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
