import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// fetching the meals of a mensa
Future<DishesRawData> fetchMeals(String id) async {
  final response =
      await http.get('https://openmensa.org/api/v2/canteens/$id/meals');
  if (response.statusCode == 200) {
    print(
        'Commander: We established a connection to the openMensaAPI to fetch the meals of canteen $id');
    return DishesRawData.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'Commander: We faild loading the Post (meals) from the server. Sorry for that.');
  }
}

// all data of dishes of one mensa
class DishesRawData {
  final List<dynamic> dishRaw;

  DishesRawData({this.dishRaw});

  factory DishesRawData.fromJson(List<dynamic> json) {
    return DishesRawData(dishRaw: json);
  }
}
