import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Post> fetchPost() async {
  final responsePage1 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=1');
  final responsePage2 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=2');
  final responsePage3 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=3');
  final responsePage4 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=4');
  final responsePage5 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=5');
  final responsePage6 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=6');
  final responsePage7 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=7');
  final responsePage8 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=8');
  final responsePage9 =
      await http.get('http://openmensa.org/api/v2/canteens/?page=9');

  if (responsePage1.statusCode == 200 &&
      responsePage2.statusCode == 200 &&
      responsePage3.statusCode == 200 &&
      responsePage4.statusCode == 200 &&
      responsePage5.statusCode == 200 &&
      responsePage6.statusCode == 200 &&
      responsePage7.statusCode == 200 &&
      responsePage8.statusCode == 200 &&
      responsePage9.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    print('response status 200 :)');
    List allPages = new List<dynamic>();
    allPages.addAll(json.decode(responsePage1.body));
    allPages.addAll(json.decode(responsePage2.body));
    allPages.addAll(json.decode(responsePage3.body));
    allPages.addAll(json.decode(responsePage4.body));
    allPages.addAll(json.decode(responsePage5.body));
    allPages.addAll(json.decode(responsePage6.body));
    allPages.addAll(json.decode(responsePage7.body));
    allPages.addAll(json.decode(responsePage8.body));
    allPages.addAll(json.decode(responsePage9.body));
    print(allPages.length);
    return Post.fromJson(allPages);
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  final int id;
  final String name;
  final String city;
  final String address;
  final double latitude;
  final double altitude;

  Post(
      {this.id,
      this.name,
      this.city,
      this.address,
      this.latitude,
      this.altitude});

  factory Post.fromJson(List<dynamic> json) {
    return Post(
      id: json[0]['id'],
      name: json[0]['name'],
      city: json[0]['city'],
      address: json[0]['address'],
      latitude: json[0]['coordinates'][0],
      altitude: json[0]['coordinates'][1],
    );
  }
}
