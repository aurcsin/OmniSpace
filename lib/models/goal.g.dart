// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalStepAdapter extends TypeAdapter<GoalStep> {
  @override
  final int typeId = 20;

  @override
  GoalStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalStep(
      id: fields[0] as String,
      description: fields[1] as String,
      done: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GoalStep obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.done);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalCheckpointAdapter extends TypeAdapter<GoalCheckpoint> {
  @override
  final int typeId = 21;

  @override
  GoalCheckpoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalCheckpoint(
      id: fields[0] as String,
      title: fields[1] as String,
      target: fields[2] as double,
      progress: fields[3] as double,
      steps: (fields[4] as List).cast<GoalStep>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalCheckpoint obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.target)
      ..writeByte(3)
      ..write(obj.progress)
      ..writeByte(4)
      ..write(obj.steps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalCheckpointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 4;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      progress: fields[2] as double,
      target: fields[3] as double,
      steps: (fields[4] as List).cast<GoalStep>(),
      checkpoints: (fields[5] as List).cast<GoalCheckpoint>(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.progress)
      ..writeByte(3)
      ..write(obj.target)
      ..writeByte(4)
      ..write(obj.steps)
      ..writeByte(5)
      ..write(obj.checkpoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
