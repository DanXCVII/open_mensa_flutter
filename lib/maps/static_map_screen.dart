import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';

class MapGenerator extends StatefulWidget {
  MapGenerator({Key key, this.title}) : super(key: key);
  final String title;
  @override
  MapGeneratorState createState() => new MapGeneratorState();
}

BuildContext scaffoldContext;

class MapGeneratorState extends State<MapGenerator> {
  GoogleMapController mapController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.my_location,
            color: Colors.white,
          ),
          backgroundColor: Colors.black87,
          onPressed: () {
            // TODO: animate camera to current location
            setCameraToDeviceLocation();
          },
        ),
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Text(
                'confirm',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () { // When pressed confirm: show pop up with the mensas around the location with a tickbox to select the mensa.
                mapController.addMarker(MarkerOptions(
                    position: LatLng(
                        mapController.cameraPosition.target.latitude,
                        mapController.cameraPosition.target.longitude)));
              },
            ),
          ],
          title: Text('Select Mensa location'),
          backgroundColor: Colors.black87,
        ),
        body: Builder(
            builder: (context) => Stack(children: <Widget>[
                  // TODO: Put stack in another class for better readability
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    trackCameraPosition: true,
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(51.165691, 10.451526), zoom: 6.00),
                  ),
                  Center(
                      // TODO: Correct the Center for better centering
                      child: IconButton(
                    icon: Icon(
                      Icons.adjust,
                      size: 40,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      createSnackBar('Please don\'t touch me 😥', context);
                    },
                  )), // TODO: Add description with more info about the selction of a location where the mesa is. Eg. "select masa location within 30km."
                ])));
  }

  Future<LatLng> getUserLocation() async {
    var currentLocation = <String, double>{};
    var location = Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation["latitude"];
      final lng = currentLocation["longitude"];
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void setCameraToDeviceLocation() async {
    final center = await getUserLocation();
    if (center == null) {
      return;
    } else {
      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: center, zoom: 10)));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}

void createSnackBar(String message, BuildContext context) {
  final snackBar = new SnackBar(
    content: new Text(message),
  );

  // Find the Scaffold in the Widget tree and use it to show a SnackBar!
  Scaffold.of(context).showSnackBar(snackBar);
}
