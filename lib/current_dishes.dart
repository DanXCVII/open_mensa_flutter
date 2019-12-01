import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import './dish_card.dart';
import './database.dart';
import './fetch_data.dart';
import './fetch_canteens.dart';

import './models/dish.dart';
import './generated/i18n.dart';
import 'models/canteen.dart';

class CurrentDishes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CurrentDishesState();
  }
}

class CurrentDishesState extends State<CurrentDishes> {
  Map<String, List<Widget>> dishCardDays = {};

  // TODO: make the 'days' list from the meal data, so that the correct days are added, and
  // only the days available get added.

  String canteenName;
  List<String> selectedCanteenNames = [];

  Map<String, bool> favorites = {};
  String dropdownValue;

  @override
  void initState() {
    super.initState();
    try {
      initCurrentDishesData(context, -1).then((result) {
        setState(() {});
      });
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(
      BuildContext
          context) // TODO: Add all the building stuff and put the async tasks somewhere else
  {
    return Container(
      color: Color(0xff3F3B35),
      child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              /*try {
                assert(
                    snapshot.data.getStringList('selectedCanteens')[0] != null);
              } catch (e) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(S.of(context).current_dishes),
                  ),
                  body: Center(
                    child: Text(S.of(context).no_canteen_selected),
                  ),
                );
              }
              */
              List<Tab> tabs = getTabs();
              List<ListView> tabsData = getTabsData();

              if (tabs.isEmpty || tabsData.isEmpty)
                return Center(
                  child: CircularProgressIndicator(),
                );

              return DefaultTabController(
                length: tabs.length,
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
                                child: DropdownButton<String>(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  value: dropdownValue == null
                                      ? canteenName
                                      : dropdownValue,
                                  onChanged: (String newValue) {
                                    initCurrentDishesData(
                                            context,
                                            selectedCanteenNames
                                                .indexOf(newValue))
                                        .then((result) {
                                      setState(() {
                                        dropdownValue = newValue;
                                      });
                                    });
                                  },
                                  items: selectedCanteenNames
                                      .map<DropdownMenuItem<String>>(
                                          (String value) =>
                                              DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                ),
                                              ))
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
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              isScrollable: tabs.length == 1 ? false : true,
                              tabs: tabs,
                            ),
                          ),
                          pinned: false,
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: tabsData,
                    )),
              );
            }

            /// TODO: NTH: Maybe handle the error somehow
            /// else if (snapshot.hasError) {
            /// return Center(child: CircularProgressIndicator());
            /// }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  initCurrentDishesData(BuildContext context, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (index == -1) {
      index = (prefs.getInt("currentCanteen") == null
          ? 0
          : prefs.getInt("currentCanteen"));
    } else {
      prefs.setInt("currentCanteen", index);
    }

    selectedCanteenNames = [];

    // making sure that the user already selected selectedCanteen canteen
    List<String> selectedCanteens = prefs.getStringList('selectedCanteens');
    if (selectedCanteens == null || selectedCanteens.isEmpty) {
      // add notice, that no canteen has ben selected yet
      canteenName = S.of(context).no_canteen;
      selectedCanteenNames.add(canteenName);
      dishCardDays = {
        S.of(context).no_canteen_selected: [displayNoCanteenSelected()],
      };
      return;
    }

    selectedCanteens.forEach((ca) {
      selectedCanteenNames.add(Canteen.fromJson(json.decode(ca)).name);
    });
    // dirty fix for problem with only one canteen selected
    index = selectedCanteens.length == 1 ? 0 : index;
    var selectedCanteen = selectedCanteens[index];
    Canteen cant = Canteen.fromJson(json.decode(selectedCanteen));
    Map<DateTime, List<Dish>> snapshot = await fetchMeals(cant.id);
    dishCardDays = initializeDishCards(snapshot);

    canteenName = cant.name;

    // assigning the global variables with the dishCards.
  }

  List<Tab> getTabs() {
    List<Tab> output = [];
    for (String day in dishCardDays.keys) {
      if (dishCardDays[day].isNotEmpty) {
        output.add(Tab(text: day));
      }
    }
    return output;
  }

  List<ListView> getTabsData() {
    List<ListView> output = [];
    for (String day in dishCardDays.keys) {
      if (dishCardDays[day].isNotEmpty) {
        output.add(ListView(children: dishCardDays[day]));
      }
    }
    return output;
  }

  // Change method to collect data of the canteen you want (index)
  Widget showDishes(BuildContext context, SharedPreferences prefs) {
    // Making sure that the user already selected canteens
  }

  Map<String, List<Widget>> initializeDishCards(
      Map<DateTime, List<Dish>> dishes) {
    Map<int, String> dayMap = {
      1: S.of(context).monday,
      2: S.of(context).tuesday,
      3: S.of(context).wednesday,
      4: S.of(context).thursday,
      5: S.of(context).friday,
      6: S.of(context).saturday,
      7: S.of(context).sunday,
    };

    Map<String, List<Widget>> currentDishes = {};

    for (DateTime key in dishes.keys) {
      currentDishes.addAll({
        dayMap[key.weekday]:
            dishes[key].map((dish) => Dishcard(dish, context, false)).toList()
      });
    }

    return currentDishes;
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
