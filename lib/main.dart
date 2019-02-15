import 'package:flutter/material.dart';
import './fetch_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './maps/static_map_screen.dart';
import './add_mensa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './maps/mensa_selector_list.dart';

void main() {
  runApp(MaterialApp(
      title: 'First Route',
      // TODO: theme: ThemeData(primaryColor: Colors.purple),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/mensa_selector': (context) => MapGenerator(),
        // '/mensa_selector/list': (context) => RandomWords(latlng: ,),
      }));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  bool _alreadySelectedMensa;
  final _widgetOptions = [
    Text('Index 0: Current Dishes'),
    Text('Index 1: Favourites'),
    AddMensa(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfMensaSelected(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Mensa'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              activeIcon: Icon(Icons.restaurant, color: Colors.grey),
              title: Text('Dishes'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, color: Colors.pink[400]),
              title: Text('Favourites'),
              backgroundColor: Colors.brown[700]),
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.edit_location, color: Colors.red),
              icon: Icon(Icons.edit_location),
              title: Text('Mensas'),
              backgroundColor: Colors.green[700]),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.shifting,
      ),
    );
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
                    FlatButton(child: Text('Let\'s go'), onPressed: () {
                      Navigator.pushNamed(context, '/mensa_selector');
                    },)
                  ],
            ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
