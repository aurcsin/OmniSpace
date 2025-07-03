// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spirit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpiritAdapter extends TypeAdapter<Spirit> {
  @override
  final int typeId = 12;

  @override
  Spirit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Spirit(
      id: fields[0] as String,
      name: fields[1] as String,
      mythos: fields[2] as String,
      purpose: fields[3] as String,
      useInApp: fields[4] as String,
      realm: fields[5] as ZoneTheme,
      isPrimary: fields[6] as bool,
      isNPC: fields[7] as bool,
      isCollectible: fields[8] as bool,
      archetype: fields[9] as String,
      xpValue: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Spirit obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mythos)
      ..writeByte(3)
      ..write(obj.purpose)
      ..writeByte(4)
      ..write(obj.useInApp)
      ..writeByte(5)
      ..write(obj.realm)
      ..writeByte(6)
      ..write(obj.isPrimary)
      ..writeByte(7)
      ..write(obj.isNPC)
      ..writeByte(8)
      ..write(obj.isCollectible)
      ..writeByte(9)
      ..write(obj.archetype)
      ..writeByte(10)
      ..write(obj.xpValue);
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
