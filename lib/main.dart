import 'package:flutter/material.dart';
import './fetch_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './maps/static_map_screen.dart';

void main() {
  runApp(MaterialApp(title: 'First Route', initialRoute: '/', routes: {
    '/': (context) => MyApp(),
    '/mensa_selector': (context) => MapGenerator(),
  }));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Open route'),
          onPressed: () {
            Navigator.pushNamed(context, '/mensa_selector');
          },
        ),
      ),
    );
  }
}
