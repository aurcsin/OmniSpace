// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_theme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZoneThemeAdapter extends TypeAdapter<ZoneTheme> {
  @override
  final int typeId = 19;

  @override
  ZoneTheme read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ZoneTheme.Air;
      case 1:
        return ZoneTheme.Earth;
      case 2:
        return ZoneTheme.Fire;
      case 3:
        return ZoneTheme.Water;
      case 4:
        return ZoneTheme.Void;
      case 5:
        return ZoneTheme.Fusion;
      default:
        return ZoneTheme.Air;
    }
  }

  @override
  void write(BinaryWriter writer, ZoneTheme obj) {
    switch (obj) {
      case ZoneTheme.Air:
        writer.writeByte(0);
        break;
      case ZoneTheme.Earth:
        writer.writeByte(1);
        break;
      case ZoneTheme.Fire:
        writer.writeByte(2);
        break;
      case ZoneTheme.Water:
        writer.writeByte(3);
        break;
      case ZoneTheme.Void:
        writer.writeByte(4);
        break;
      case ZoneTheme.Fusion:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZoneThemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
