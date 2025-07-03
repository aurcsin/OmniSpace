// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteCollectionAdapter extends TypeAdapter<NoteCollection> {
  @override
  final int typeId = 6;

  @override
  NoteCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteCollection(
      id: fields[0] as String,
      name: fields[1] as String,
      noteIds: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteCollection obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.noteIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
