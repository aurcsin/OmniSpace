// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_bundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskBundleAdapter extends TypeAdapter<TaskBundle> {
  @override
  final int typeId = 13;

  @override
  TaskBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskBundle(
      id: fields[0] as String,
      name: fields[1] as String,
      tasks: (fields[2] as List?)?.cast<Task>(),
    );
  }

  @override
  void write(BinaryWriter writer, TaskBundle obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
