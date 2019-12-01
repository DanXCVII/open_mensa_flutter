import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './add_canteen.dart';
import './canteen_list_select.dart';
import './current_dishes.dart';
import './favourite_dishes.dart';
import './generated/i18n.dart';

void main() {
  // String languageCode = ui.window.locale.languageCode;
  runApp(App());
}

class App extends StatelessWidget {
  final debugPaintSizeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: false,
      title: 'First Route',
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      /// TODO: Change the themeColor?
      theme: ThemeData(
        primaryColor: Colors.orange[900],
        canvasColor: Color(0xff3F3B35),
        brightness: Brightness.dark,
        primaryTextTheme: TextTheme(body2: TextStyle(color: Colors.white)),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
        ),
        cardColor: Color(0xff312F2A),
        accentColor: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/canteen_list': (context) => CheckableCanteenList(),
      },
    );
  }
}

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem(this.title, this.icon);
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedDrawerIndex = 0;

  /// Initializing the drawer with:
  /// -currentDishes
  /// -favorites
  /// -canteenSelctor
  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return CurrentDishes();
      case 1:
        return FavouriteDishes();
      case 2:
        return AddCanteen();

      default:
        return Text("Error");
    }
  }

  Drawer _buildDrawer(context) {
    List<DrawerItem> drawerItems = [
      DrawerItem(S.of(context).current_dishes, Icons.restaurant),
      DrawerItem(S.of(context).favorite_dishes, Icons.favorite),
      DrawerItem(S.of(context).selected_canteens, Icons.edit_location)
    ];

    // creating the list of items shown by the drawer
    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }
    // creating and returning the drawer with the userAccountHeader
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ingredients.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              accountName: Text(S.of(context).hello),
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

    return Scaffold(
      backgroundColor: Colors.grey[350],
      drawer: _buildDrawer(context),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
      floatingActionButton: _selectedDrawerIndex == 2
          ? FloatingActionButton(
              backgroundColor: Colors.orange[700],
              onPressed: () {
                Navigator.pushNamed(context, '/canteen_list');
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void initState() {
    // TODO: Maybe not good practise to do async activity in the init state
    super.initState();
    checkIfCanteenSelectedAlert(context);
  }

  /// checking if a canteen is selected and otherwise showing an alert.
  checkIfCanteenSelectedAlert(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('selectedCanteens') == null ||
        prefs.getStringList('selectedCanteens').isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).select_canteen),
          content: Text(S.of(context).welcome),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).lets_go),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WillPopScope(
                            child: CheckableCanteenList(),
                            onWillPop: () async {
                              Navigator.pop(context);
                              Navigator.of(context).popAndPushNamed('/');
                              return false;
                            },
                          )),
                );
              },
            )
          ],
        ),
      );
    }
  }
}

Future<SharedPreferences> getPrefs() async {
  return await SharedPreferences.getInstance();
}
