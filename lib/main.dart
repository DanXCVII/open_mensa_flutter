import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';

import './favourite_dishes.dart';
import './current_dishes.dart';
import './add_mensa.dart';
import './mensa_list_select.dart';
import './generated/i18n.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  final debugPaintSizeEnabled = false;

  static StreamController _locale = StreamController<Locale>();
  static bool initialized = false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _locale.stream,
        initialData: Locale("en", ""),
        builder: (context, snapshot) {
          return MaterialApp(
            locale: snapshot.data,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: S.delegate.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocals) {
              Locale myLocale = deviceLocale;
              print(myLocale.languageCode + " " + myLocale.countryCode);
              S.delegate.resolution(fallback: new Locale("en", ""));
              if (initialized) {
                _locale.close();
                return myLocale;
              } else {
                print("initialized " + deviceLocale.languageCode);
                _locale.add(Locale(deviceLocale.languageCode, ""));
                initialized = true;
              }
              //setLocale(deviceLocale);
              return myLocale;
            },
            showPerformanceOverlay: false,
            title: 'First Route',

            /// TODO: Change the themeColor?
            theme: ThemeData(
              primaryColor: Colors.orange[900],
              canvasColor: Color(0xff3F3B35),
              brightness: Brightness.dark,
              primaryTextTheme:
                  TextTheme(body2: TextStyle(color: Colors.white)),
              tabBarTheme: TabBarTheme(
                labelColor: Colors.white,
              ),
              cardColor: Color(0xff312F2A),
              accentColor: Colors.red,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => MyHomePage(),
              '/mensa_list': (context) => CheckableMensaList()
            },
          );
        });
  }
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
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedDrawerIndex = 0;

  /// Initializing the drawer with:
  /// -currentDishes
  /// -favorites
  /// -mensaSelctor
  _getDrawerItemWidget(int pos) {
    Drawer myDrawer = _buildDrawer();
    switch (pos) {
      case 0:
        return CurrentDishes(myDrawer: myDrawer);
      case 1:
        return FavouriteDishes(myDrawer: myDrawer);
      case 2:
        return AddMensa(myDrawer: myDrawer);

      default:
        return Text("Error");
    }
  }

  Drawer _buildDrawer() {
    // creating the list of items shown by the drawer
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
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
      drawer: _buildDrawer(),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
      floatingActionButton: _selectedDrawerIndex == 2
          ? FloatingActionButton(
              backgroundColor: Colors.orange[700],
              onPressed: () {
                Navigator.pushNamed(context, '/mensa_list');
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
          title: Text("Select canteen"),
          content: Text(
              "Welcome to OpenMensa Germany :) \nI can take you to the place where you can select the Mensas you're interested in."),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).hello + ', let\'s go'),
              onPressed: () {
                /// TODO: pushReplacementRout and set onWillPop to pushReplacement to fix the
                /// issue that loadingIndicator is shown when a mensa is selected.
                Navigator.popAndPushNamed(context, '/mensa_list');
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
