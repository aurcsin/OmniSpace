// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spirit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpiritAdapter extends TypeAdapter<Spirit> {
  @override
  final int typeId = 50;

  @override
  Spirit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Spirit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      realm: fields[3] as ZoneTheme,
      isPrimary: fields[4] as bool,
      isNPC: fields[5] as bool,
      isCollectible: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Spirit obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.realm)
      ..writeByte(4)
      ..write(obj.isPrimary)
      ..writeByte(5)
      ..write(obj.isNPC)
      ..writeByte(6)
      ..write(obj.isCollectible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpiritAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
