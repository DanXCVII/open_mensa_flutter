import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MapGenerator extends StatefulWidget {
  MapGenerator({Key key, this.title}) : super(key: key);
  final String title;
  @override
  MapGeneratorState createState() => new MapGeneratorState();
}

class MapGeneratorState extends State<MapGenerator> {
  GoogleMapController mapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Mensa location'),
          backgroundColor: Colors.black87,
        ),
        body: Stack(children: <Widget>[
          GoogleMap(
            initialCameraPosition: const CameraPosition(
                target: LatLng(51.165691, 10.451526), zoom: 6.00),
          ),
          Center(
              child: Icon(
            Icons.adjust,
            color: Colors.black54,
            size: 40,
          ))
        ]));
  }
}
