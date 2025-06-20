// lib/models/tracker_type.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_type.dart';

class TrackerTypeAdapter extends TypeAdapter<TrackerType> {
  @override
  final int typeId = 3; // ← make sure this matches your @HiveType(typeId: X)

  @override
  TrackerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrackerType.goal;
      case 1:
        return TrackerType.event;
      case 2:
        return TrackerType.routine;
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
      case TrackerType.event:
        writer.writeByte(1);
        break;
      case TrackerType.routine:
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
