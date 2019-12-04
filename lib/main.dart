import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_mensa_flutter/bloc/add_canteen/add_canteen.dart';
import 'package:open_mensa_flutter/bloc/canteen_overview/canteen_overview.dart';
import 'package:open_mensa_flutter/bloc/current_dishes/current_dishes.dart';
import 'package:open_mensa_flutter/bloc/favorite_dishes/favorite_dishes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './add_canteen.dart';
import './canteen_list_select.dart';
import './current_dishes.dart';
import './favourite_dishes.dart';
import './generated/i18n.dart';
import 'bloc/master/master_bloc.dart';

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/":
            return MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => MasterBloc(),
                child: MultiBlocProvider(providers: [
                  BlocProvider(
                      create: (context) => CurrentDishesBloc(
                          BlocProvider.of<MasterBloc>(context))
                        ..add(InitializeDataEvent())),
                  BlocProvider(
                      create: (context) => FavoriteDishesBloc(
                          BlocProvider.of<MasterBloc>(context))
                        ..add(FLoadFavoriteDishesEvent())),
                  BlocProvider(
                      create: (context) => CanteenOverviewBloc(
                          BlocProvider.of<MasterBloc>(context))
                        ..add(LoadCanteenOverviewEvent())),
                ], child: MyHomePage()),
              ),
            );

          case "/canteen_list":
            final CheckableCanteenListBlocArgs args = settings.arguments;

            return MaterialPageRoute(
              builder: (context) => BlocProvider<AddCanteenBloc>(
                create: (context) =>
                    AddCanteenBloc(BlocProvider.of<MasterBloc>(args.masterBlocContext)),
                child: CheckableCanteenList(),
              ),
            );
        }
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

  // When drawer item gets selected
  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      drawer: Drawer(
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
            Column(children: [
              ListTile(
                leading: Icon(Icons.restaurant),
                title: Text(S.of(context).current_dishes),
                selected: 0 == _selectedDrawerIndex,
                onTap: () => _onSelectItem(0),
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text(S.of(context).favorite_dishes),
                selected: 1 == _selectedDrawerIndex,
                onTap: () => _onSelectItem(1),
              ),
              ListTile(
                leading: Icon(Icons.edit_location),
                title: Text(S.of(context).select_canteens),
                selected: 2 == _selectedDrawerIndex,
                onTap: () => _onSelectItem(2),
              ),
            ])
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedDrawerIndex,
        children: <Widget>[
          CurrentDishesScreen(),
          FavouriteDishes(),
          AddCanteen(),
        ],
      ),
      floatingActionButton: _selectedDrawerIndex == 2
          ? FloatingActionButton(
              backgroundColor: Colors.orange[700],
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/canteen_list',
                );
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
  checkIfCanteenSelectedAlert(BuildContext homePageContext) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('selectedCanteens') == null ||
        prefs.getStringList('selectedCanteens').isEmpty) {
      showDialog(
        context: homePageContext,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).select_canteen),
          content: Text(S.of(context).welcome),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).lets_go),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/canteen_list",
                  arguments: CheckableCanteenListBlocArgs(homePageContext),
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
