import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// fetching the mensas around a given location
Future<MensaListRawData> fetchMensas(String lat, String lng) async {
  final response = await http.get(
      'http://openmensa.org/api/v2/canteens?near[lat]=$lat&near[lng]=$lng&near[dist]=40');

  if (response.statusCode == 200) {
    print(
        'Commander: We established a connection to the openMensaAPI to fetch the canteens around you');
    return MensaListRawData.fromJson(json.decode(response.body));
  } else {
    throw Exception(
        'Commander: We faild loading the Post from the server. Sorry for that.');
  }
}

// list of mensas
class MensaListRawData {
  final List<dynamic> mensas;

  MensaListRawData({this.mensas});

  factory MensaListRawData.fromJson(List<dynamic> json) {
    return MensaListRawData(mensas: json);
  }
}

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
