import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './generated/i18n.dart';
import './models/dish.dart';
import 'bloc/master/master.dart';
import 'bloc/master/master_bloc.dart';

class Dishcard extends StatelessWidget {
  final Dish dish;
  final BuildContext context;
  final _isFavorite;

  Dishcard(
    this.dish,
    this.context,
    this._isFavorite,
  );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
                    color: dish.theme.color[1],
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
                      colors: [dish.theme.color[0], dish.theme.color[1]],
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.bottomRight,
                      stops: [0.0, 1.0],
                    )),
                width: width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                        icon: _isFavorite
                            ? Icon(Icons.favorite, color: Colors.pink)
                            : Icon(Icons.favorite_border, color: Colors.white),
                        // TODO: If saved to favourites: Icon is favorite and not only border
                        onPressed: () {
                          // User already has favorites /// NOT FINISHED. TODO: ON INIT STATE, THE FAVORITES NEEDS TO BE INITIALIZED ?? maybe changed
                          if (_isFavorite) {
                            BlocProvider.of<MasterBloc>(context)
                                .add(MDeleteFavoriteDishEvent(dish));
                          } else {
                            BlocProvider.of<MasterBloc>(context)
                                .add(MAddFavoriteDishEvent(dish));
                          }
                        }),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
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
                              padding:
                                  const EdgeInsets.only(top: 12.0, bottom: 5.0),
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
            'images/${dish.theme.iconName}.png',
            width: 100,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ]);
  }
}

Row createRowPrices(Map<String, double> priceGroup, BuildContext context) {
  List<Widget> groupList = [];
  if (priceGroup['students'] != null) {
    groupList
        .add(createColumnPrice(S.of(context).students, priceGroup['students']));
  }
  if (priceGroup['employees'] != null) {
    groupList.add(VerticalDivider());
    groupList.add(
        createColumnPrice(S.of(context).employees, priceGroup['employees']));
  }
  if (priceGroup['others'] != null) {
    groupList.add(VerticalDivider());
    groupList
        .add(createColumnPrice(S.of(context).others, priceGroup['others']));
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
  int _width = (price < 10.0) ? 4 : 5;
  String _price = '$price'.padRight(_width, '0');

  return Column(
    children: <Widget>[
      Text(
        '$group:',
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
      Text(
        '$_price€',
        style: TextStyle(fontSize: 20, color: Colors.white),
      )
    ],
  );
}
