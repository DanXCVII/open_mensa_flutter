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
  
}

Future<bool> checkIfFavorite(Dish dish) async {
  
}
