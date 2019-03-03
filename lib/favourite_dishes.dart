import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import './dish.dart';

class FavouriteDishes extends StatefulWidget {
  @override
  FavouriteDishesState createState() {
    return FavouriteDishesState();
  }
}

class FavouriteDishesState extends State<FavouriteDishes> {
  @override
  Widget build(BuildContext context) {
    return Center();
  }
}

void saveToFavorite(Dish dish) async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'favorites.db');

  Database database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Test (id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
            'dishName TEXT, category TEXT, notes TEXT, icon TEXT, studentPrice REAL, ' +
            'employeePrice REAL, othersPrice REAL)');
  });
  String notesConcatenated = '';
  dish.getNotes().forEach((note) {
    notesConcatenated = notesConcatenated + '$note';
  });
  await database.transaction((txn) async {
    int id1 = await txn.rawInsert(
        'INSERT INTO Test(dishName, category, notes, icon, studentPrice, employeePrice, othersPrice) ' +
            'VALUES(${dish.getDishName()}, ${dish.getCategory()}, $notesConcatenated, ${dish.getIcon()}, ' +
            '${dish.getPriceGroup()[0]}}, ${dish.getPriceGroup()[1]}, ${dish.getPriceGroup()[2]})');
  });
}

Future<bool> checkIfFavorite(Dish dish) async {
  var completer = new Completer<bool>();

  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'favorites.db');

  Database database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Test (id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
            'dishName TEXT, category TEXT, notes TEXT, icon TEXT, studentPrice REAL, ' +
            'employeePrice REAL, othersPrice REAL)');
  });

  List<Map> list = await database.rawQuery(
      'SELECT dishName FROM Test WHERE dishName = ${dish.getDishName()}');
  if (list.isEmpty != true) {
    completer.complete(true);
    return completer.future;
  } else {
    completer.complete(false);
    return completer.future;
  }
}
