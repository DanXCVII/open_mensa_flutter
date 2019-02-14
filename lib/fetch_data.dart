import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<MensaList> fetchPost(String lat, String lng) async {
  final response = await http.get(
      'http://openmensa.org/api/v2/canteens?near[lat]=$lat&near[lng]=$lng&near[dist]=50');

  if (response.statusCode == 200) {
    print(
        'Commander: We established a connection to the openMensaAPI to fetch the canteens around you');
    print(json.decode(response.body));
    return MensaList.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'Commander: We faild loading the Post from the server. Sorry for that.');
  }
}

class MensaList {
  final List<dynamic> mensas;

  MensaList({this.mensas});

  factory MensaList.fromJson(List<dynamic> json) {
    return MensaList(
      mensas: json);
  }
}
