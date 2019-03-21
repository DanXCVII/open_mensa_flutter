import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import './favourite_dishes.dart';
import './current_dishes.dart';
import './add_mensa.dart';
import './mensa_list_select.dart';

void main() {
  debugPaintSizeEnabled = false;

  runApp(MaterialApp(
      showPerformanceOverlay: false,
      title: 'First Route',

      /// TODO: Change the themeColor?
      theme: ThemeData(primaryColor: Colors.orange[800]),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/mensa_list': (context) => CheckableMensaList()
      }));
}

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class MyHomePage extends StatefulWidget {
  final drawerItems = [
    DrawerItem("Current Dishes", Icons.restaurant),
    DrawerItem("Favorites", Icons.favorite),
    DrawerItem("Selected Mensas", Icons.edit_location)
  ];

  @override
  State<StatefulWidget> createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedDrawerIndex = 0;

  /// Initializing the drawer with:
  /// -currentDishes
  /// -favorites
  /// -mensaSelctor
  _getDrawerItemWidget(int pos) {
    Drawer myDrawer = buildDrawer();
    switch (pos) {
      case 0:
        return CurrentDishes(myDrawer: myDrawer);
      case 1:
        return FavouriteDishes(myDrawer: myDrawer);
      case 2:
        return AddMensa(myDrawer: myDrawer);

      default:
        return new Text("Error");
    }
  }

  Drawer buildDrawer() {
    // creating the list of items shown by the drawer
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    // creating and returning the drawer with the userAccountHeader
    return Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/hat.png'),
                  fit: BoxFit.cover,
                ),
              ),
              accountName: new Text("OpenMensa"),
              accountEmail: null),
          Column(children: drawerOptions)
        ],
      ),
    );
  }

  // When drawer item gets selected
  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    /// building the drawer again over here and not using the buidlDrawer() method
    /// because it's good practise to put much in the build method
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    return new Scaffold(
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/hat.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                accountName: new Text("OpenMensa"),
                accountEmail: null),
            new Column(children: drawerOptions)
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }

  @override
  void initState() {
    // TODO: Maybe not good practise to do async activity in the init state
    super.initState();
    checkIfMensaSelectedAlert(context);
  }

  /// checking if a mensa is selected and otherwise showing an alert.
  checkIfMensaSelectedAlert(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('selectedMensas') == null ||
        prefs.getStringList('selectedMensas').isEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Select Mensa"),
                content: Text(
                    "Welcome to Open Mensa Germany :) \nI can take you to the place where you can select the Mensas you're interested in."),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Let\'s go'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/mensa_list');
                    },
                  )
                ],
              ));
    }
  }
}

Future<SharedPreferences> getPrefs() async {
  return await SharedPreferences.getInstance();
}
