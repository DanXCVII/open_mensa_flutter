import 'package:flutter/material.dart';
import './maps/static_map_screen.dart';
import './add_mensa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './current_dishes.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = false;

  runApp(MaterialApp(
      showPerformanceOverlay: false,
      title: 'First Route',
      // TODO: theme: ThemeData(primaryColor: Colors.purple),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/mensa_selector': (context) => MapGenerator(),
        // '/mensa_selector/list': (context) => RandomWords(latlng: ,),
      }));
}

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class MyHomePage extends StatefulWidget {
  final drawerItems = [
    DrawerItem("Fragment 1", Icons.restaurant),
    DrawerItem("Fragment 2", Icons.favorite),
    DrawerItem("Fragment 3", Icons.edit_location)
  ];

  @override
  State<StatefulWidget> createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    Drawer myDrawer = buildDrawer();
    switch (pos) {
      case 0:
        return CurrentDishes(myDrawer: myDrawer);
      case 1:
        return Scaffold(
          appBar: AppBar(title: Text('Favourites'),),
          drawer:myDrawer,
          body: Center(
              // Not finished Screen with the favourite dishes
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.favorite_border,
                size: 70,
              ),
              Text('Index 1: favourites'),
            ],
          )),
        );
      case 2:
        return AddMensa(myDrawer: myDrawer);

      default:
        return new Text("Error");
    }
  }

  Drawer buildDrawer() {
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
    return Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
              accountName: new Text("John Doe"), accountEmail: null),
          new Column(children: drawerOptions)
        ],
      ),
    );
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
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
                accountName: new Text("John Doe"), accountEmail: null),
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
    checkIfMensaSelected(context);
  }

  checkIfMensaSelected(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('selectedMensas') == null ||
        prefs.getStringList('selectedMensas').isEmpty) {
      showAlert(context);
    }
  }

  showAlert(BuildContext context) {
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
                    Navigator.pushNamed(context, '/mensa_selector');
                  },
                )
              ],
            ));
  }
}

Future<SharedPreferences> getPrefs() async {
  return await SharedPreferences.getInstance();
}
