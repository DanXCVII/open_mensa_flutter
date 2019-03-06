import 'package:flutter/material.dart';

import './dish.dart';
import './database.dart';

class Dishcard extends StatefulWidget {
  final Dish dish;
  final BuildContext context;

  Dishcard(
    this.dish,
    this.context,
  );

  @override
  State<StatefulWidget> createState() {
    return DishcardState(dish, context);
  }
}

class DishcardState extends State<Dishcard> {
  Dish dish;
  BuildContext context;

  DishcardState(
    this.dish,
    this.context,
  );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return FutureBuilder<dynamic>(
        future: DBProvider.db.getFavDishByName(dish.dishName),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            bool _isFavoriteHERE;
            if (snapshot.data == Null) {
              _isFavoriteHERE = false;
            } else {
              _isFavoriteHERE = true;
            }
            return Stack(children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            // Shadow of the DishCard
                            color: dish.themeData[1],
                            blurRadius: 15.0, // default 20.0
                            spreadRadius: 1.5, // default 5.0
                            offset: Offset(10.0, 10.0),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            gradient: LinearGradient(
                              colors: [dish.themeData[0], dish.themeData[1]],
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.bottomRight,
                              stops: [0.0, 1.0],
                            )),
                        width: width * 0.9,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                                icon: _isFavoriteHERE
                                    ? Icon(Icons.favorite, color: Colors.pink)
                                    : Icon(Icons.favorite_border,
                                        color: Colors.white),
                                // TODO: If saved to favourites: Icon is favorite and not only border
                                onPressed: () {
                                  setState(() {
                                    try {
                                      // User already has favorites /// NOT FINISHED. TODO: ON INIT STATE, THE FAVORITES NEEDS TO BE INITIALIZED ?? maybe changed
                                      if (_isFavoriteHERE) {
                                        DBProvider.db
                                            .deleteFavDishByName(dish.dishName);
                                      } else {
                                        DBProvider.db.newFavDish(dish);
                                      }
                                    } catch (e) {
                                      print(
                                          'pressed favorite button and error occured: $e');
                                    }
                                  });
                                }),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 12.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        dish.dishName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Divider(),
                                    ),
                                    createRowPrices(dish.priceGroup, context),
                                    // set prices list looks different
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, bottom: 5.0),
                                      child: Text(dish.category,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.italic)),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'images/${dish.icon}.png',
                    width: 100,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ]);
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          return Container(
            height: 229, // Don't change 229😅
            child: Center(child: CircularProgressIndicator()),
          );
        });
  }
}

Row createRowPrices(Map<String, double> priceGroup, BuildContext context) {
  List<Widget> groupList = [];
  if (priceGroup['students'] != null) {
    groupList.add(createColumnPrice('students', priceGroup['students']));
  }
  if (priceGroup['employees'] != null) {
    groupList.add(getVerticalDivider(context));
    groupList.add(createColumnPrice('employees', priceGroup['employees']));
  }
  if (priceGroup['others'] != null) {
    groupList.add(getVerticalDivider(context));
    groupList.add(createColumnPrice('others', priceGroup['others']));
  }

  return Row(
    children: groupList,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  );
}

Widget getVerticalDivider(BuildContext context) {
  return Container(
    width: 1,
    height: 28,
    decoration: BoxDecoration(
        border:
            Border(right: BorderSide(color: Theme.of(context).dividerColor))),
  );
}

/// the dynamic of priceGroup hashMap is double but can't be further specified because
/// it's the data from the mensa API.

Column createColumnPrice(String group, double price) {
  return Column(
    children: <Widget>[
      Text(
        '$group:',
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
      Text(
        '$price€',
        style: TextStyle(fontSize: 20, color: Colors.white),
      )
    ],
  );
}