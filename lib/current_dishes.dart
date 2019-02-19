import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './fetch_data.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_mensa.dart';

class CurrentDishes extends StatefulWidget {
  Drawer drawer;
  CurrentDishes({@required this.drawer});

  @override
  State<StatefulWidget> createState() {
    return CurrentDishesState(myDrawer: drawer);
  }
}

class CurrentDishesState extends State<CurrentDishes> {
  Drawer myDrawer;
  CurrentDishesState({@required this.myDrawer});

  @override
  Widget build(BuildContext context) {
    print('CurrentDishesState');
    return Scaffold(
        backgroundColor: Colors.grey[100],
        drawer: myDrawer,
        body: FutureBuilder<CustomScrollView>(
            future: showDishes(context),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data;
              } else if (snapshot.hasError) {
                return Center(child: Text("Fehlermeldung: ${snapshot.error}"));
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}

Future<CustomScrollView> showDishes(BuildContext context) async {
  SharedPreferences prefs = await getPrefs();
  DishesRawData snapshot =
      await fetchMeals(getMensaId(prefs.getStringList('selectedMensas')[0]));
  print(snapshot.dishRaw);

  if (snapshot.dishRaw.isEmpty) {
    throw Exception('No DISHES found');
  }
  return CustomScrollView(slivers: <Widget>[
    SliverAppBar(
      expandedHeight: 150.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text("Current Dishes"),
      ),
    ),
    SliverList(delegate: SliverChildListDelegate(getAllDishCards(snapshot, context)))
  ]);
}

List<Widget> getAllDishCards(DishesRawData snapshot, BuildContext context) {
  List<Widget> output = [];
  for (int i = 0; i < getMealsCount(snapshot.dishRaw, 0); i++) {
    output.add(createDishCard(
        snapshot.dishRaw[0]['meals'][i]['name'],
        snapshot.dishRaw[0]['meals'][i]['category'],
        snapshot.dishRaw[0]['meals'][i]['prices'],
        snapshot.dishRaw[0]['meals'][i]['notes'],
        context));
  }
  return output;
}

/// Dynamics are actually doubles but can't be further specified.
Widget createDishCard(
    String dishName,
    String category,
    Map<String, dynamic> priceGroup,
    List<dynamic> notes,
    BuildContext context) {
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
                  color: Colors.grey,
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                  offset: Offset(10.0, 10.0),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                    begin: FractionalOffset.topLeft,
                    end: FractionalOffset.bottomRight,
                    stops: [0.0, 1.0],
                  )),
              width: width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.favorite_border, color: Colors.white),
                      // TODO: If saved to favourites: Icon is favorite and not only border
                      onPressed: () {}),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Center(
                            child: Text(
                              // TODO: Center properly. When device in landscape mode, it's not correctly centered right now
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/burger.svg',
            semanticsLabel: 'Acme Logo',
            height: 80,
          ),
        ],
      ),
    ),
  ]);
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
