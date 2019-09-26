import 'package:flutter/material.dart';
import 'dart:async';

import './dish_card.dart';
import './database.dart';
import './dish.dart';
import './generated/i18n.dart';

class FavouriteDishes extends StatefulWidget {
  final Drawer myDrawer;

  FavouriteDishes({@required this.myDrawer});

  @override
  FavouriteDishesState createState() {
    return FavouriteDishesState(myDrawer: myDrawer);
  }
}

class FavouriteDishesState extends State<FavouriteDishes> {
  final Drawer myDrawer;

  FavouriteDishesState({@required this.myDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff3F3B35),
      child: FutureBuilder<List<Widget>>(
          future: _getFavDishCards(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // If the user hasn't selected any favourite dishes yet
              if (snapshot.data.isEmpty) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(S.of(context).favorites),
                  ),
                  drawer: myDrawer,
                  body: Center(
                    child: Icon(
                      Icons.favorite_border,
                      size: 70,
                    ),
                  ),
                );
              }
              // If the user has favourite dishes, show them:
              return CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset(
                      'images/pralines.jpg',
                      fit: BoxFit.cover,
                    ),
                    title: Text(S.of(context).favorite_dishes),
                  ),
                ),
                SliverList(delegate: SliverChildListDelegate(snapshot.data))
              ]);
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

// if the user doesn't have any favorite dishes:

// if there are favorite dishes to show:

Future<List<Widget>> _getFavDishCards(BuildContext context) async {
  List<Widget> output = [];
  Future<List<Dish>> favs = DBProvider.db.getAllFavDishes();
  favs.then((favs) {
    favs.forEach((favDish) {
      print(favs);
      output.add(Dishcard(favDish, context, true));
    });
    return output;
  });
  return output;
}
