import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

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

void saveToFavorite(
    String dishName,
    String category,
    Map<String, dynamic> priceGroup, // dynamic = double
    List<dynamic> notes, // dynamic = String
    String icon) async {
  var databasesPath = await getDatabasesPath();
  // String path = join(databasesPath, 'demo.db');
  
}

bool checkIfFavorite(
    String dishName,
    String category,
    Map<String, dynamic> priceGroup, // dynamic = double
    List<dynamic> notes, // dynamic = String
    String icon) {}
