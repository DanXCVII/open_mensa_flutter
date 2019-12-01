// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../dish.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DishAdapter extends TypeAdapter<Dish> {
  @override
  Dish read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dish(
      dishName: fields[0] as String,
      category: fields[1] as String,
      priceGroup: (fields[2] as Map)?.cast<String, double>(),
      notes: (fields[3] as List)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Dish obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dishName)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.priceGroup)
      ..writeByte(3)
      ..write(obj.notes);
  }
}
