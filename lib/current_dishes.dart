import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import './dish_card.dart';
import './database.dart';
import './fetch_data.dart';
import './main.dart';
//import './add_mensa.dart';
import './dish.dart';
//import './database.dart';

class CurrentDishes extends StatefulWidget {
  final Drawer myDrawer;

  CurrentDishes({@required this.myDrawer});

  @override
  State<StatefulWidget> createState() {
    return CurrentDishesState(myDrawer: myDrawer);
  }
}

class CurrentDishesState extends State<CurrentDishes> {
  Drawer myDrawer;

  CurrentDishesState({@required this.myDrawer});
  List<List<Widget>> dishCardDays = [];

  // TODO: make the 'days' list from the meal data, so that the correct days are added, and
  // only the days available get added.
  List<String> days = ["Today", "Tomorrow", "Wednesday", "Thursday", "Friday"];

  String mensaName;
  SharedPreferences prefs;
  Map<String, bool> favorites = {};

  @override
  void initState() {
    print("initState() called");
    super.initState();
    try {
      initCurrentDishesData(context).then((result) {
        setState(() {});
      });
    } catch (e) {
      return;
    }
  }

  void reload() {
    setState(() {
      initCurrentDishesData(context);
    });
  }

  @override
  Widget build(
      BuildContext
          context) // TODO: Add all the building stuff and put the async tasks somewhere else
  {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: FutureBuilder<Widget>(
          future: showDishes(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            }

            /// TODO: NTH: Maybe handle the error somehow
            /// else if (snapshot.hasError) {
            /// return Center(child: CircularProgressIndicator());
            /// }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  initCurrentDishesData(BuildContext context) async {
    prefs = await getPrefs();
    // making sure that the user already selected a mensa
    try {
      assert(prefs.getStringList('selectedMensas') != null);
    } catch (e) {
      return;
    }
    var a = prefs.getStringList('selectedMensas')[0];
    Canteen cant = Canteen.fromJson(json.decode(a));
    DishesRawData snapshot = await fetchMeals(cant.id);
    days = getDays(snapshot);
    mensaName = cant.name;

    // assigning the global variables with the dishCards.

    try {
      for (int i = 0; i < days.length; i++) {
        List<Widget> _dishCards =
            await getAllDishCardsDay(snapshot, context, i);
        _dishCards.add(SizedBox(height: 20));
        dishCardDays.add(_dishCards);

      }
    } catch (e) {
      print("Fehlermeldung: ${e.toString()}");
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
  Future<Widget> showDishes(BuildContext context) async {
    SharedPreferences prefs = await getPrefs();
    // Making sure that the user already selected mensas
    try {
      assert(prefs.getStringList('selectedMensas')[0] != null);
    } catch (e) {
      return Scaffold(
        drawer: myDrawer,
        appBar: AppBar(
          title: Text('Current Dishes'),
        ),
        body: Center(
          child: Text(
              "You haven't selected any Mensa yet. Do so, by navigating to the add mensa mensu :)"),
        ),
      );
    }

    List<ListView> tabsData = getTabsData();
    List<Tab> tabs = getTabs();

    return DefaultTabController(
      length: tabs.length,
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(mensaName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: Image.asset(
                      "images/mensaLandscape.png",
                      fit: BoxFit.cover,
                    )),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
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
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.restaurant,
          size: 70,
        ),
        Text('Index 1: Favourites'),
      ],
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

List<String> getDays(DishesRawData drd) {
  Map<int,String> dayMap = {
    1: "Monday",
    2: "Tuesday",
    3: "Wednesday",
    4: "Thursday",
    5: "Friday",
    6: "Saturday",
    7: "Sunday"
  };
  List<String> days = [];
  drd.dishRaw.forEach((item) {
    DateTime date = DateTime.parse(item["date"]);
    days.add(dayMap[date.weekday]);
  });
  return days;
}
