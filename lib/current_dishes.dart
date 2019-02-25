import 'package:flutter/material.dart';
import './fetch_data.dart';
import 'main.dart';
import "dart:async";
import 'package:shared_preferences/shared_preferences.dart';
import 'add_mensa.dart';

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
  Widget build(BuildContext context) // TODO: Add all the building stuff and put the async tasks somewhere else
   { 
    return Scaffold(
        backgroundColor: Colors.white,
        drawer: myDrawer,
        body: FutureBuilder<Widget>(
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
            }));
  }

  initCurrentDishesData(BuildContext context) async {
    prefs = await getPrefs();
    // making sure that the user already selected a mensa
    try {
      assert(prefs.getStringList('selectedMensas') != null);
    } catch (e) {
      return;
    }
    DishesRawData snapshot =
        await fetchMeals(getMensaId(prefs.getStringList('selectedMensas')[0]));

    mensaName = getMensaName(prefs.getStringList('selectedMensas')[0]);

    // assigning the global variables with the dishCards.
    try {
      dishCardsDay0 = await getAllDishCardsDay(snapshot, context, 0);
    } catch (e) {
      print("${e.toString()} Fehlermeldung");
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
                    background: Image.network(
                      "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
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
      DishesRawData dishesRawD, BuildContext context, int day) {
    var completer = new Completer<List<Widget>>();
    List<Widget> output = [];

    for (int i = 0; i < getMealsCount(dishesRawD.dishRaw, day); i++) {
      String icon = getIconName(
          "${dishesRawD.dishRaw[day]['meals'][i]['category']}${dishesRawD.dishRaw[day]['meals'][i]['name']}${dishesRawD.dishRaw[day]['meals'][i]['notes']}");
      try {
        output.add(createDishCard(
            dishesRawD.dishRaw[day]['meals'][i]['name'],
            dishesRawD.dishRaw[day]['meals'][i]['category'],
            dishesRawD.dishRaw[day]['meals'][i]['prices'],
            dishesRawD.dishRaw[day]['meals'][i]['notes'],
            context,
            icon,
            getThemeColor(icon),
            prefs));
      } catch (e) {}
    }
    print('test');
    completer.complete(output);
    return completer.future;
  }

  Widget createDishCard(
      String dishName,
      String category,
      Map<String, dynamic> priceGroup, // dynamic = double
      List<dynamic> notes, // dynamic = String
      BuildContext context,
      String icon,
      List<Color> themeData,
      SharedPreferences prefs) {
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
                    color: themeData[0],
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
                      colors: [themeData[0], themeData[1]],
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.bottomRight,
                      stops: [0.0, 1.0],
                    )),
                width: width * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                        icon: checkFavorite(prefs, '$dishName&$category&&${notes.toString()}&&&$icon')
                            ? Icon(Icons.favorite, color: Colors.pink)
                            : Icon(Icons.favorite_border, color: Colors.white),
                        // TODO: If saved to favourites: Icon is favorite and not only border
                        onPressed: () {
                          setState(() {
                            try {
                              // User already has favorites /// NOT FINISHED. TODO: ON INIT STATE, THE FAVORITES NEEDS TO BE INITIALIZED
                              List<String> favs =
                                  prefs.getStringList('favoriteDishes');
                              if (favorites[dishName] == true) {
                                favs.remove(
                                    '$dishName&$category&&${notes.toString()}&&&$icon');
                                prefs.setStringList('favoriteDishes', favs);
                              } else {
                                favs.add(
                                    '$dishName&$category&&${notes.toString()}&&&$icon');
                                prefs.setStringList('favoriteDishes', favs);

                              }
                            } catch (e) {
                              favorites.addAll({dishName:true});
                              prefs.setStringList('favoriteDishes', [
                                '$dishName&$category&&${notes.toString()}&&&$icon'
                              ]);
                            }
                          });
                        }),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Center(
                              child: Text(
                                dishName,
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
                            createRowPrices(priceGroup, context),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 12.0, bottom: 5.0),
                              child: Text(category,
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
            'images/$icon.png',
            width: 100,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ]);
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
Row createRowPrices(Map<String, dynamic> priceGroup, BuildContext context) {
  List<Widget> groupList = [];
  if (priceGroup['students'] != null) {
    groupList.add(createColumnPrice('students', priceGroup['students']));
  }
  if (priceGroup['employees'] != null) {
    groupList.add(getVerticalDivider(context));
    groupList.add(createColumnPrice('employees', priceGroup['employees']));
  }
  if (priceGroup['pupils'] != null || priceGroup['others'] != null) {
    groupList.add(getVerticalDivider(context));
    if (priceGroup['pupils'] != null) {
      groupList.add(createColumnPrice('others', priceGroup['pupils']));
    } else {
      groupList.add(createColumnPrice('others', priceGroup['others']));
    }
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

// Content of output List: [ColorFrom, ColorTo, Icon]
String getIconName(String dishInfo) {
  String dISHiNFO = dishInfo.toUpperCase();

  if (dISHiNFO.contains('BURGER')) {
    return 'burger';
  } else if (dISHiNFO.contains('PIZZA')) {
    return 'pizza';
  } else if (dISHiNFO.contains('FISCH') || dISHiNFO.contains('LACHS')) {
    return 'fish';
  } else if (dISHiNFO.contains('SPAGHETTI') ||
      dISHiNFO.contains('NUDEL')) // Maybe not adding the image at nudeln..
  {
    return 'spaghetti';
  } else if (dISHiNFO.contains('POMMES')) {
    return 'pommes';
  } else if (dISHiNFO.contains('GEFLÜGEL') ||
      dISHiNFO.contains('HÄHNCHEN') ||
      dISHiNFO.contains('PUTE')) {
    return 'haehnchenBrust';
  } else {
    return 'forkSpoon';
  }
}

List<Color> getThemeColor(String dish) {
  if (dish == 'burger') {
    return [Colors.yellow, Colors.deepOrange];
  } else if (dish == 'pizza') {
    return [Colors.deepOrange, Colors.red];
  } else if (dish == 'fish' || dish == 'lachs') {
    return [Colors.lightBlue[900], Colors.blueAccent];
  } else if (dish == 'spaghetti' ||
      dish == 'nudel') // Maybe not adding the image at nudeln..
  {
    return [Colors.red[900], Colors.amber];
  } else if (dish == 'pommes') {
    return [Colors.amber, Colors.brown[700]];
  } else if (dish == 'haehnchenBrust') {
    return [Colors.brown[700], Colors.deepOrange[900]];
  } else {
    return [Colors.orange[700], Colors.red[700]];
  }
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
