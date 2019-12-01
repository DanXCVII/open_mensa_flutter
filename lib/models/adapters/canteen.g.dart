// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../canteen.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CanteenAdapter extends TypeAdapter<Canteen> {
  @override
  Canteen read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Canteen(
      id: fields[0] as String,
      name: fields[1] as String,
      city: fields[2] as String,
      address: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Canteen obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.address);
  }
}
