// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_bundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalBundleAdapter extends TypeAdapter<GoalBundle> {
  @override
  final int typeId = 14;

  @override
  GoalBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalBundle(
      id: fields[0] as String,
      name: fields[1] as String,
      goals: (fields[2] as List?)?.cast<Goal>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalBundle obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.goals);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
