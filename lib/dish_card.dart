import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:open_mensa_flutter/bloc/favorite_dish/favorite_dish.dart';
import 'package:open_mensa_flutter/bloc/favorite_dishes/favorite_dishes.dart';

import './generated/i18n.dart';
import './models/dish.dart';
import 'bloc/master/master.dart';

class Dishcard extends StatelessWidget {
  final Dish dish;
  final BuildContext context;
  final FavoriteDishBloc favoriteDishBloc;

  Dishcard(
    this.dish,
    this.context,
    this.favoriteDishBloc,
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
                  children: <Widget>[
                    BlocBuilder<FavoriteDishBloc, FavoriteDishState>(
                        bloc: favoriteDishBloc,
                        builder: (context, state) {
                          if (state is LoadingRatedState) {
                            return Row(children: <Widget>[
                              CircularProgressIndicator(),
                              Spacer(),
                              CircularProgressIndicator(),
                            ]);
                          } else if (state is LoadedRatedState) {
                            Icon dislikedIcon;
                            Icon likeIcon;
                            // TODO: Maybe add another bloc for the heart because it needs to check with every rebuild
                            switch (state.ratedState) {
                              case DishRated.Disliked:
                                dislikedIcon = Icon(
                                  GroovinMaterialIcons.emoticon_poop,
                                  color: Colors.brown,
                                );
                                likeIcon = Icon(
                                  GroovinMaterialIcons.heart_outline,
                                  color: Colors.white,
                                );
                                break;
                              case DishRated.Liked:
                                dislikedIcon = Icon(
                                    GroovinMaterialIcons.emoticon_poop,
                                    color: Colors.white);
                                likeIcon = Icon(
                                    GroovinMaterialIcons.heart_half_full,
                                    color: Colors.pink);
                                break;
                              case DishRated.Favorite:
                                dislikedIcon = Icon(
                                    GroovinMaterialIcons.emoticon_poop,
                                    color: Colors.white);
                                likeIcon =
                                    Icon(Icons.favorite, color: Colors.pink);
                                break;
                              case DishRated.Undecided:
                                dislikedIcon = Icon(
                                    GroovinMaterialIcons.emoticon_poop,
                                    color: Colors.white);
                                likeIcon = Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                );
                                break;
                              default:
                            }

                            return Row(
                              children: <Widget>[
                                IconButton(
                                    icon: dislikedIcon,
                                    onPressed: () {
                                      if (state.ratedState ==
                                          DishRated.Disliked) {
                                        BlocProvider.of<MasterBloc>(context)
                                            .add(MChangeRatedEvent(
                                                dish, DishRated.Undecided));
                                      } else {
                                        BlocProvider.of<MasterBloc>(context)
                                            .add(MChangeRatedEvent(
                                                dish, DishRated.Disliked));
                                      }
                                    }),
                                Spacer(),
                                IconButton(
                                    icon: likeIcon,
                                    onPressed: () {
                                      if (state.ratedState == DishRated.Liked) {
                                        BlocProvider.of<MasterBloc>(context)
                                            .add(MChangeRatedEvent(
                                                dish, DishRated.Favorite));
                                      } else if (state.ratedState ==
                                          DishRated.Favorite) {
                                        BlocProvider.of<MasterBloc>(context)
                                            .add(MChangeRatedEvent(
                                                dish, DishRated.Undecided));
                                      } else {
                                        BlocProvider.of<MasterBloc>(context)
                                            .add(MChangeRatedEvent(
                                                dish, DishRated.Liked));
                                      }
                                    })
                              ],
                            );
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
