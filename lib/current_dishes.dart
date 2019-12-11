import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './dish_card.dart';
import 'bloc/current_dishes/current_dishes.dart';
import 'generated/i18n.dart';
import 'models/canteen.dart';

class CurrentDishesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CurrentDishesScreenState();
  }
}

class CurrentDishesScreenState extends State<CurrentDishesScreen> {
  Map<int, String> dayMap;

  @override
  void initState() {
    super.initState();
    dayMap = {
      // 1: S.of(context).monday,
      // 2: S.of(context).tuesday,
      // 3: S.of(context).wednesday,
      // 4: S.of(context).thursday,
      // 5: S.of(context).friday,
      // 6: S.of(context).saturday,
      // 7: S.of(context).sunday,
      1: 'Montag',
      2: 'Dienstag',
      3: 'Mittwoch',
      4: 'Donnerstag',
      5: 'Freitag',
      6: 'Samstag',
      7: 'Sonntag',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff3F3B35),
      child: BlocBuilder<CurrentDishesBloc, CurrentDishesState>(
          builder: (context, state) {
        if (state is LoadingCurrentDishesState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is LoadingCurrentDishesForCanteenState) {
          return DefaultTabController(
            length: 0,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                        height: 20,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Canteen>(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            value: state.selectedCanteen,
                            onChanged: (Canteen newValue) {
                              BlocProvider.of<CurrentDishesBloc>(context)
                                  .add(ChangeSelectedCanteenEvent(newValue));
                            },
                            items: state.availableCanteenList
                                .map(
                                  (canteen) => DropdownMenuItem<Canteen>(
                                    value: canteen,
                                    child: Text(
                                      canteen.name,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      background: Image.asset(
                        "images/ingredientsRound.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        } else if (state is NoDataToLoadState) {
          return Center(
            child: Text('You haven\'t selected any canteen yet'),
          );
        } else if (state is LoadedCurrentDishesState) {
          return DefaultTabController(
            length: state.currentDishesList.keys.length == 0
                ? 1
                : state.currentDishesList.keys.length,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                        height: 20,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Canteen>(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            value: state.selectedCanteen,
                            onChanged: (Canteen newValue) {
                              BlocProvider.of<CurrentDishesBloc>(context)
                                  .add(ChangeSelectedCanteenEvent(newValue));
                            },
                            items: state.availableCanteenList
                                .map(
                                  (canteen) => DropdownMenuItem<Canteen>(
                                    value: canteen,
                                    child: Text(
                                      canteen.name,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      background: Image.asset(
                        "images/ingredientsRound.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  state.currentDishesList.keys.isEmpty
                      ? null
                      : SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              isScrollable: true,
                              tabs: state.currentDishesList.keys
                                  .toList()
                                  .map((day) => Tab(text: dayMap[day]))
                                  .toList(),
                            ),
                          ),
                          pinned: false,
                        ),
                ]..removeWhere((item) => item == null);
              },
              body: state.currentDishesList.keys.isEmpty
                  ? Container(child: Text('This canteen has no dishes :/'))
                  : TabBarView(
                      children: state.currentDishesList.keys
                          .map((key) => ListView(
                              children: state.currentDishesList[key]
                                  .map((dish) => Dishcard(dish, context))
                                  .toList()))
                          .toList(),
                    ),
            ),
          );
        } else {
          return Text(state.toString());
        }
      }),
    );
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

Widget displayNoCanteenSelected() {
  return Center(
    child: Icon(
      Icons.restaurant,
      size: 70,
    ),
  );
}

// TODO: think about how to manage it with the getters.
String getDateDishes(List<dynamic> dishesRaw, int dayFromToday) {
  return dishesRaw[dayFromToday]['date'];
}

bool isOpenDishes(List<dynamic> dishesRaw, int dayFromToday) {
  return dishesRaw[dayFromToday]['closed'];
}

int getMealsCount(List<dynamic> dishesRaw, int dayFromToday) {
  return dishesRaw[dayFromToday]['meals'].length;
}

class CustomDropdownClipper extends CustomClipper<Path> {
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height / 4);
    path.lineTo(size.width, size.height / 4);
    path.lineTo(size.width, size.height / 4 * 2);
    path.lineTo(0, size.height / 4 * 2);
    path.close();
    return path;
  }

  bool shouldReclip(CustomDropdownClipper oldClipper) => false;
}

// clips a diamond shape
class CustomStepsClipper extends CustomClipper<Path> {
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width / 2, 0);
    path.close();
    return path;
  }

  bool shouldReclip(CustomStepsClipper oldClipper) => false;
}
