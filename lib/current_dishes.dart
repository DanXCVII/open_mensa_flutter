import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import './dish_card.dart';
import './database.dart';
import './fetch_data.dart';
import './fetch_canteens.dart';

import './dish.dart';
import './generated/i18n.dart';

class CurrentDishes extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return CurrentDishesState();
  }
}

class CurrentDishesState extends State<CurrentDishes> {
  List<List<Widget>> dishCardDays = [];

  // TODO: make the 'days' list from the meal data, so that the correct days are added, and
  // only the days available get added.
  List<String> days = [];

  String mensaName;
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
              if (snapshot.data.getStringList('selectedMensas').isEmpty){
                return Scaffold(
                  appBar: AppBar(
                    title: Text(S.of(context).current_dishes),
                  ),
                  body: Center(
                    child: Text(
                        S.of(context).no_canteen_selected),
                  ),
                );
              }

              List<ListView> tabsData = getTabsData();
              List<Tab> tabs = getTabs();

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
                                      ? mensaName
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
                              isScrollable: true,
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
      index = (prefs.getInt("currentMensa") == null
          ? 0
          : prefs.getInt("currentMensa"));
    } else {
      prefs.setInt("currentMensa", index);
    }

    // making sure that the user already selected selectedCanteen mensa
    try {
      assert(prefs.getStringList('selectedMensas') != null);
    } catch (e) {
      return;
    }
    List<String> selectedCanteens = prefs.getStringList('selectedMensas');

    selectedCanteenNames = [];
    selectedCanteens.forEach((ca) {
      selectedCanteenNames.add(Canteen.fromJson(json.decode(ca)).name);
    });
    print(selectedCanteenNames);
    // dirty fix for problem with only one canteen selected
    index = selectedCanteens.length == 1 ? 0 : index;
    var selectedCanteen = selectedCanteens[index];
    Canteen cant = Canteen.fromJson(json.decode(selectedCanteen));
    DishesRawData snapshot = await fetchMeals(cant.id);
    days = getDays(context, snapshot);
    mensaName = cant.name;

    // assigning the global variables with the dishCards.

    try {
      dishCardDays = [];
      for (int i = 0; i < days.length; i++) {
        List<Widget> _dishCards =
            await getAllDishCardsDay(snapshot, context, i);
        if (_dishCards.length == 0) {
          _dishCards.add(
            Center(
              child: Container(
                child: Text("no data for this day"),
              ),
            ),
          );
        }
        _dishCards.add(SizedBox(height: 20));
        dishCardDays.add(_dishCards);
      }
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  List<Tab> getTabs() {
    List<Tab> output = [];
    for (int i = 0; i < days.length; i++) {
      if (dishCardDays[i] != null) {
        output.add(Tab(text: days[i]));
      }
    }
    return output;
  }

  List<ListView> getTabsData() {
    List<ListView> output = [];
    for (int i = 0; i < days.length; i++) {
      if (dishCardDays[i] != null) {
        output.add(ListView(children: dishCardDays[i]));
      }
    }
    return output;
  }

  // Change method to collect data of the mensa you want (index)
  Widget showDishes(BuildContext context, SharedPreferences prefs) {
    // Making sure that the user already selected mensas
  }

  Future<List<Widget>> getAllDishCardsDay(
      DishesRawData dishesRawD, BuildContext context, int day) async {
    var completer = new Completer<List<Widget>>();
    List<Widget> output = [];

    for (int i = 0; i < getMealsCount(dishesRawD.dishRaw, day); i++) {
      try {
        Dish dish = Dish.fromMap(dishesRawD.dishRaw[day]['meals'][i]);
        dynamic favoriteData =
            await DBProvider.db.getFavDishByName(dish.dishName);
        bool _isFavorite = false;
        if (favoriteData == Null) {
          _isFavorite = false;
        } else {
          _isFavorite = true;
        }
        print(_isFavorite);
        output.add(Dishcard(dish, context, _isFavorite));
      } catch (e) {}
    }

    completer.complete(output);
    return completer.future;
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

/// the dynamic of priceGroup hashMap is double but can't be further specified because
/// it's the data from the mensa API.
Row createRowPrices(Map<String, double> priceGroup, BuildContext context) {
  List<Widget> groupList = [];
  if (priceGroup['students'] != null) {
    groupList.add(createColumnPrice(S.of(context).students, priceGroup['students']));
  }
  if (priceGroup['employees'] != null) {
    groupList.add(getVerticalDivider(context));
    groupList.add(createColumnPrice(S.of(context).employees, priceGroup['employees']));
  }
  if (priceGroup['others'] != null) {
    groupList.add(getVerticalDivider(context));
    groupList.add(createColumnPrice(S.of(context).others, priceGroup['others']));
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

Widget displayNoMensaSelected() {
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

List<String> getDays(context, DishesRawData drd) {
  Map<int, String> dayMap = {
    1: S.of(context).monday,
    2: S.of(context).tuesday,
    3: S.of(context).wednesday,
    4: S.of(context).thursday,
    5: S.of(context).friday,
    6: S.of(context).saturday,
    7: S.of(context).sunday,
  };
  List<String> days = [];
  drd.dishRaw.forEach((item) {
    DateTime date = DateTime.parse(item["date"]);
    days.add(dayMap[date.weekday]);
  });
  return days;
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
