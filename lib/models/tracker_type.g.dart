// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackerTypeAdapter extends TypeAdapter<TrackerType> {
  @override
  final int typeId = 14;

  @override
  TrackerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrackerType.goal;
      case 1:
        return TrackerType.task;
      case 2:
        return TrackerType.event;
      case 3:
        return TrackerType.series;
      default:
        return TrackerType.goal;
    }
  }

  @override
  void write(BinaryWriter writer, TrackerType obj) {
    switch (obj) {
      case TrackerType.goal:
        writer.writeByte(0);
        break;
      case TrackerType.task:
        writer.writeByte(1);
        break;
      case TrackerType.event:
        writer.writeByte(2);
        break;
      case TrackerType.series:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
