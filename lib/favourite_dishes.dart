import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './dish_card.dart';
import './generated/i18n.dart';
import 'bloc/favorite_dishes/favorite_dishes.dart';

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
        child: DefaultTabController(
            length: 3,
            child: NestedScrollView(headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 250.0,
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
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(isScrollable: false, tabs: [
                      Tab(text: 'Favorites'),
                      Tab(text: 'Liked'),
                      Tab(text: 'Shit'),
                    ]),
                  ),
                  pinned: false,
                )
              ];
            }, body: BlocBuilder<FavoriteDishesBloc, FavoriteDishesState>(
              builder: (context, state) {
                if (state is LoadingFavoriteDishesState) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is LoadedFavoriteDishes) {
                  int favCount = -1;
                  int likeCount = -1;
                  int shitCount = -1;
                  return TabBarView(
                      // TODO: Add case when no favorites added yet
                      children: [
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
                            : ListView(
                                children: state.favoriteDishes.map((dish) {
                                favCount++;
                                return Dishcard(
                                  dish,
                                  context,
                                );
                              }).toList()),
                        ListView(
                            children: state.likedDishes.map((dish) {
                          likeCount++;
                          return Dishcard(
                            dish,
                            context,
                          );
                        }).toList()),
                        ListView(
                            children: state.dislikedDishes.map((dish) {
                          shitCount++;
                          return Dishcard(
                            dish,
                            context,
                          );
                        }).toList()),
                      ]);
                } else {
                  return Container(child: Text(state.toString()));
                }
              },
            ))));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
