import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/dish.dart';

// fetching the meals of a canteen
Future<Map<DateTime, List<Dish>>> fetchMeals(String id) async {
  final response =
      await http.get('https://openmensa.org/api/v2/canteens/$id/meals');
  if (response.statusCode == 200) {
    print(
        'Commander: We established a connection to the openCanteenAPI to fetch the meals of canteen $id');
    return _decodeJsonToDishes(json.decode(response.body));
  } else {
    throw Exception(
        'Commander: We faild loading the Post (meals) from the server. Sorry for that.');
  }
}

Map<DateTime, List<Dish>> _decodeJsonToDishes(List<dynamic> json) {
  Map<DateTime, List<Dish>> fetchedDishes = {};

  for (int day = 0; day < json.length; day++) {
    DateTime date = DateTime.parse(json[day]['date']);
    fetchedDishes.addAll({date: []});
    for (int i = 0; i < json[day]['meals'].length; i++) {
      try {
        fetchedDishes[date].add(Dish.fromMap(json[day]['meals'][i])..initTheme());
      } catch (e) {}
    }
  }
  return fetchedDishes;
}
