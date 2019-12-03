import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_mensa_flutter/bloc/favorite_dishes/favorite_dishes_bloc.dart';
import 'dart:async';

import './dish_card.dart';
import './database.dart';
import './models/dish.dart';
import './generated/i18n.dart';
import 'bloc/favorite_dishes/favorite_dishes_state.dart';

class FavouriteDishes extends StatefulWidget {
  @override
  FavouriteDishesState createState() {
    return FavouriteDishesState();
  }
}

class FavouriteDishesState extends State<FavouriteDishes> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xff3F3B35),
        child: CustomScrollView(slivers: <Widget>[
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
          BlocBuilder<FavoriteDishesBloc, FavoriteDishesState>(
            builder: (context, state) {
              if (state is LoadingFavoriteDishes) {
                return SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Center(child: CircularProgressIndicator()),
                    ],
                  ),
                );
              } else if (state is LoadedFavoriteDishes) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    state.favoriteDishes.isEmpty
                        ? Container(
                            height: MediaQuery.of(context).size.height / 2,
                            child: Center(
                              child: Icon(
                                Icons.favorite_border,
                                size: 80,
                              ),
                            ),
                          )
                        : state.favoriteDishes
                            .map((dish) => Dishcard(dish, context, true))
                  ]),
                );
              } else {
                return Text(state.toString());
              }
            },
          )
        ]));
  }
}
