import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import './models/dish.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "Favorites.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Favorites ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "dish_name TEXT,"
          "category TEXT,"
          "students_price REAL,"
          "employees_price REAL,"
          "others_price REAL,"
          "notes TEXT"
          ")");
    });
  }

  newFavDish(Dish newDish) async {
    final db = await database;
    String notes = convertNotesToSingleString(newDish.notes);
    await db.insert('Favorites', {
      'dish_name': newDish.dishName,
      'category': newDish.category,
      'students_price': newDish.priceGroup['students'],
      'employees_price': newDish.priceGroup['employees'],
      'others_price': newDish.priceGroup['others'],
      'notes': notes,
    });
  }

  getFavDishByName(String name) async {
    final db = await database;
    var res =
        await db.query("Favorites", where: "dish_name = ?", whereArgs: [name]);
    return res.isNotEmpty
        ? Dish.fromMap(convertDBMapToDishMap(res.first))
        : Null;
  }

  Future<List<Dish>> getAllFavDishes() async {
    final db = await database;
    var res = await db.query("Favorites");
    List<Dish> list = res.isNotEmpty
        ? res
            .map((dBDish) => Dish.fromMap(convertDBMapToDishMap(dBDish)))
            .toList()
        : [];
    return list;
  }

  deleteFavDishByName(String name) async {
    final db = await database;
    db.delete("Favorites", where: "dish_name = ?", whereArgs: [name]);
  }
}

Map<String, dynamic> convertDBMapToDishMap(Map<String, dynamic> dBMap) {
  return ({
    'name': dBMap['dish_name'],
    'category': dBMap['category'],
    'prices': ({
      'students': dBMap['students_price'],
      'employees': dBMap['employees_price'],
      'others': dBMap['others_price']
    }),
    'notes': dBMap['notes'].split('#')
  });
}

String convertNotesToSingleString(List<String> notes) {
  String output = "";
  if (notes == null) {
    return output;
  }
  for (int i = 0; i < notes.length; i++) {
    output = output + "${notes[i]}#";
  }

  return output;
}
