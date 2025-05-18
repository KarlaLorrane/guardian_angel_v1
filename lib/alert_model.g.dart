// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertAdapter extends TypeAdapter<Alert> {
  @override
  final int typeId = 2;

  @override
  Alert read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alert(
      emergencyId: fields[0] as DateTime,
      dateTime: fields[1] as String,
      locationUrl: fields[2] as String,
      photos: fields[3] as String,
      message: fields[5] as String,
      batteryLevel: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Alert obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.emergencyId)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.locationUrl)
      ..writeByte(3)
      ..write(obj.photos)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.batteryLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
