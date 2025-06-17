// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 13;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      title: fields[1] as String,
      noteIds: (fields[2] as List?)?.cast<String>() ?? [],
      trackerIds: (fields[3] as List?)?.cast<String>() ?? [],
      goalIds: (fields[4] as List?)?.cast<String>() ?? [],
      eventIds: (fields[5] as List?)?.cast<String>() ?? [],
      seriesIds: (fields[6] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.noteIds)
      ..writeByte(3)
      ..write(obj.trackerIds)
      ..writeByte(4)
      ..write(obj.goalIds)
      ..writeByte(5)
      ..write(obj.eventIds)
      ..writeByte(6)
      ..write(obj.seriesIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
