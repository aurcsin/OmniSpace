// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_bundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SeriesBundleAdapter extends TypeAdapter<SeriesBundle> {
  @override
  final int typeId = 16;

  @override
  SeriesBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SeriesBundle(
      id: fields[0] as String,
      name: fields[1] as String,
      goalBundles: (fields[2] as List?)?.cast<GoalBundle>(),
      eventBundles: (fields[3] as List?)?.cast<EventBundle>(),
      taskBundles: (fields[4] as List?)?.cast<TaskBundle>(),
      seriesBundles: (fields[5] as List?)?.cast<SeriesBundle>(),
    );
  }

  @override
  void write(BinaryWriter writer, SeriesBundle obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.goalBundles)
      ..writeByte(3)
      ..write(obj.eventBundles)
      ..writeByte(4)
      ..write(obj.taskBundles)
      ..writeByte(5)
      ..write(obj.seriesBundles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeriesBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
