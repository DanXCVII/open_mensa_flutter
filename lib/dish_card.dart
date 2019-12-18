import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:open_mensa_flutter/bloc/favorite_dishes/favorite_dishes_state.dart';
import 'package:open_mensa_flutter/data/hive.dart';

import './generated/i18n.dart';
import './models/dish.dart';
import 'bloc/favorite_dishes/favorite_dishes_bloc.dart';
import 'bloc/master/master.dart';

class Dishcard extends StatelessWidget {
  final Dish dish;
  final BuildContext context;

  Dishcard(
    this.dish,
    this.context,
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
                    RatedIcons(dish: dish),
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

class RatedIcons extends StatefulWidget {
  const RatedIcons({
    Key key,
    @required this.dish,
  }) : super(key: key);

  final Dish dish;

  @override
  _RatedIconsState createState() => _RatedIconsState();
}

class _RatedIconsState extends State<RatedIcons> {
  DishRated ratedState;

  // @override
  // void initState() {
  //   super.initState();
  //   if (HiveProvider().getDislikedDishes().contains(widget.dish)) {
  //     ratedState = DishRated.Disliked;
  //   } else if (HiveProvider().getLikedDishes().contains(widget.dish)) {
  //     ratedState = DishRated.Liked;
  //   } else if (HiveProvider().getFavoriteDishes().contains(widget.dish)) {
  //     ratedState = DishRated.Favorite;
  //   } else {
  //     ratedState = DishRated.Undecided;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteDishesBloc, FavoriteDishesState>(
      listener: (context, state) => {
        if (state is LoadedFavoriteDishes)
          {
            setState(() {
              if (state.dislikedDishes.contains(widget.dish)) {
                ratedState = DishRated.Disliked;
              } else if (state.likedDishes.contains(widget.dish)) {
                ratedState = DishRated.Liked;
              } else if (state.favoriteDishes.contains(widget.dish)) {
                ratedState = DishRated.Favorite;
              } else {
                ratedState = DishRated.Undecided;
              }
            })
          }
      },
      child: Row(
        children: <Widget>[
          IconButton(
              icon: ratedState == DishRated.Disliked
                  ? Icon(
                      GroovinMaterialIcons.emoticon_poop,
                      color: Colors.brown,
                    )
                  : Icon(
                      GroovinMaterialIcons.emoticon_poop,
                      color: Colors.white,
                    ),
              onPressed: () {
                if (ratedState == DishRated.Disliked) {
                  BlocProvider.of<MasterBloc>(context)
                      .add(MChangeRatedEvent(widget.dish, DishRated.Undecided));

                  setState(() {
                    ratedState = DishRated.Undecided;
                  });
                } else {
                  BlocProvider.of<MasterBloc>(context)
                      .add(MChangeRatedEvent(widget.dish, DishRated.Disliked));

                  setState(() {
                    ratedState = DishRated.Disliked;
                  });
                }
              }),
          Spacer(),
          IconButton(
              icon: ratedState == DishRated.Liked
                  ? Icon(
                      GroovinMaterialIcons.heart_half_full,
                      color: Colors.pink,
                    )
                  : ratedState == DishRated.Favorite
                      ? Icon(
                          Icons.favorite,
                          color: Colors.pink,
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        ),
              onPressed: () {
                if (ratedState == DishRated.Liked) {
                  BlocProvider.of<MasterBloc>(context)
                      .add(MChangeRatedEvent(widget.dish, DishRated.Favorite));

                  setState(() {
                    ratedState = DishRated.Favorite;
                  });
                } else if (ratedState == DishRated.Favorite) {
                  BlocProvider.of<MasterBloc>(context)
                      .add(MChangeRatedEvent(widget.dish, DishRated.Undecided));

                  setState(() {
                    ratedState = DishRated.Undecided;
                  });
                } else {
                  BlocProvider.of<MasterBloc>(context)
                      .add(MChangeRatedEvent(widget.dish, DishRated.Liked));

                  setState(() {
                    ratedState = DishRated.Liked;
                  });
                }
              })
        ],
      ),
    );
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
