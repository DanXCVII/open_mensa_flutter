import 'package:flutter/material.dart';
import './maps/static_map_screen.dart';

class AddMensa extends StatefulWidget {
  AddMensa({Key key}) : super(key: key);

  @override
  _AddMensaState createState() {
    return _AddMensaState();
  }
}

class _AddMensaState extends State<AddMensa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[700],
          onPressed: () {
            Navigator.pushNamed(context, '/mensa_selector');
          },
          child: Icon(Icons.add),
        ),
        body: Stack(
          children: <Widget>[],
        ));
  }
}
