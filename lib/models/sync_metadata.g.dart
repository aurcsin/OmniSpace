// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncMetadataAdapter extends TypeAdapter<SyncMetadata> {
  @override
  final int typeId = 13;

  @override
  SyncMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncMetadata(
      lastSyncedAt: fields[0] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncMetadata obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.lastSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
