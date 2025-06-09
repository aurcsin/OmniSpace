// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_bundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventBundleAdapter extends TypeAdapter<EventBundle> {
  @override
  final int typeId = 15;

  @override
  EventBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventBundle(
      id: fields[0] as String,
      name: fields[1] as String,
      events: (fields[2] as List?)?.cast<Event>(),
    );
  }

  @override
  void write(BinaryWriter writer, EventBundle obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.events);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
