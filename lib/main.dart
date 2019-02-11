import 'package:flutter/material.dart';
import './fetch_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './maps/static_map_screen.dart';
import './add_mensa.dart';

void main() {
  runApp(MaterialApp(
      title: 'First Route',
      //theme: ThemeData(primaryColor: Colors.grey),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/mensa_selector': (context) => MapGenerator(),
      }));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _widgetOptions = [
    Text('Index 0: Current Dishes'),
    Text('Index 1: Favourites'),
    AddMensa(),
  ];

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
              icon: Icon(Icons.restaurant, color: Colors.grey),
              title: Text('Dishes'),
              backgroundColor: Colors.blue),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, color: Colors.pink[400]),
              title: Text('Favourites'),
              backgroundColor: Colors.brown[700]),
          BottomNavigationBarItem(
              activeIcon: Icon(Icons.edit_location, color: Colors.deepOrange),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
