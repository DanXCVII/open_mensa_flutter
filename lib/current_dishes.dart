import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import './dish_card.dart';
import './fetch_data.dart';
import './main.dart';
import './add_mensa.dart';
import './dish.dart';
import './database.dart';

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

  List<Widget> dishCardsDay0;
  List<Widget> dishCardsDay1;
  List<Widget> dishCardsDay2;
  List<Widget> dishCardsDay3;
  List<Widget> dishCardsDay4;
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
    DishesRawData snapshot =
        await fetchMeals(cant.id);

    mensaName = cant.name; //getMensaName(prefs.getStringList('selectedMensas')[0]);

    // assigning the global variables with the dishCards.
    try {
      dishCardsDay0 = await getAllDishCardsDay(snapshot, context, 0);
      dishCardsDay0.add(Container(height: 20.0,));
    } catch (e) {
      print("Fehlermeldung: ${e.toString()}");
    }
    try {
      dishCardsDay1 = await getAllDishCardsDay(snapshot, context, 1);
    } catch (e) {
      return;
    }
    try {
      dishCardsDay2 = await getAllDishCardsDay(snapshot, context, 2);
    } catch (e) {
      return;
    }
    try {
      dishCardsDay3 = await getAllDishCardsDay(snapshot, context, 3);
    } catch (e) {
      return;
    }
    try {
      dishCardsDay4 = await getAllDishCardsDay(snapshot, context, 4);
    } catch (e) {
      return;
    }
  }

  List<Tab> getTabs() {
    List<Tab> output = [];
    if (dishCardsDay0 != null) {
      output.add(Tab(text: "Today"));
      if (dishCardsDay1 != null) {
        output.add(Tab(text: "Tomorrow"));
        if (dishCardsDay2 != null) {
          output.add(Tab(text: "Wednesday"));
          if (dishCardsDay3 != null) {
            output.add(Tab(text: "Thursday"));
            if (dishCardsDay4 != null) {
              output.add(Tab(text: "Friday"));
            }
          }
        }
      }
    }
    return output;
  }

  List<ListView> getTabsData() {
    List<ListView> output = [];
    if (dishCardsDay0 != []) {
      output.add(ListView(children: dishCardsDay0));
      if (dishCardsDay1 != []) {
        output.add(ListView(children: dishCardsDay1));
        if (dishCardsDay2 != []) {
          output.add(ListView(children: dishCardsDay2));
          if (dishCardsDay3 != []) {
            output.add(ListView(children: dishCardsDay3));
            if (dishCardsDay4 != []) {
              output.add(ListView(children: dishCardsDay4));
            }
          }
        }
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
        output.add(Dishcard(
            Dish.fromMap(dishesRawD.dishRaw[day]['meals'][i]), context));
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

bool checkFavorite(SharedPreferences prefs, String dishInfo) {
  bool output = false;
  try {
    prefs.getStringList('favoriteDishes').forEach((dish) {
      if (dish == dishInfo) {
        output = true;
      }
    });
  } catch (e) {
    print(e);
  }
  return output;
}
