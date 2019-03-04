import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './current_dishes.dart';
import 'dart:async';
import './database.dart';
import './dish.dart';

class FavouriteDishes extends StatefulWidget {
  final Drawer myDrawer;
  FavouriteDishes({@required this.myDrawer});

  @override
  FavouriteDishesState createState() {
    return FavouriteDishesState();
  }
}

class FavouriteDishesState extends State<FavouriteDishes> {
  final Drawer myDrawer;
  FavouriteDishesState({@required this.myDrawer});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
        future: _getFavDishCards(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.isEmpty) {
              print(snapshot.data);
              return Scaffold(
                appBar: AppBar(
                  title: Text('Favourites'),
                ),
                drawer: myDrawer,
                body: Center(
                    // Not finished Screen with the favourite dishes
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.favorite_border,
                      size: 70,
                    ),
                    Text('Index 1: favourites'),
                  ],
                )),
              );
            }
            return CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("Favourite Dishes"),
                ),
              ),
              SliverList(delegate: SliverChildListDelegate(snapshot.data))
            ]);
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}

// if the user doesn't have any favorite dishes:

// if there are favorite dishes to show:

Future<List<Widget>> _getFavDishCards(BuildContext context) async {
  List<Widget> output = [];
  Future<List<Dish>> favs = DBProvider.db.getAllFavDishes();
  favs.then((favs) {
    favs.forEach((favDish) {
      output.add(Dishcard(favDish, context));
    });
    return output;
  });
  return output;
}

void saveToFavorite(Dish dish) async {}

Future<bool> checkIfFavorite(Dish dish) async {}
