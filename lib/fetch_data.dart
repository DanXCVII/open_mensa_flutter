import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// fetching the mensas around a given location
Future<List<Canteen>> fetchMensas(String lat, String lng) async {
  List<Canteen> canteens = [];
  List decodedResponses = [];

  final response = await http.get(
      'http://openmensa.org/api/v2/canteens?near[lat]=$lat&near[lng]=$lng&near[dist]=40');

  if (response.statusCode == 200) {
    print(
        'Commander: We established a connection to the openMensaAPI to fetch the canteens around you');
    decodedResponses.addAll(json.decode(response.body));
    decodedResponses.forEach((item) {
      canteens.add(Canteen.fromJson(item));
    });

    return canteens;
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

Future<List<Canteen>> fetchAllCanteens() async {
  List<Canteen> canteens = [];

  // array to store the canteens, decoded from json. every canteen is stored as
  // map in one entry
  List decodedResponses = [];

  // inital api response, used to determine how many pages we need to get
  var response = await http.get(
      'http://openmensa.org/api/v2/canteens');

  if (response.statusCode == 200) {
    print(
        'Commander: We established a connection to the openMensaAPI to fetch the canteens around you');

    // add to list
    decodedResponses.addAll(json.decode(response.body));

    // number of pages
    var pages = int.parse(response.headers["x-total-pages"]);
    for(int i = 2; i<=pages; i++) {
      response = await http.get(
          'http://openmensa.org/api/v2/canteens?page=$i');
      decodedResponses.addAll(json.decode(response.body));
    }

    decodedResponses.forEach((item) {
      canteens.add(Canteen.fromJson(item));
    });

    return canteens;
  } else {
    throw Exception(
        'Commander: We faild loading the Post from the server. Sorry for that.');
  }
}

/// Canteens are identified by name (human readable) and id (for api calls)
/// here, coordinates aren't saved
class Canteen {
  final String id;
  final String name;
  final String city;
  final String address;

  Canteen({this.id, this.name, this.city, this.address});

  // build canteen from json
  Canteen.fromJson(Map<String,dynamic> json):
        id = json['id'].toString(),
        name = json['name'],
        city = json['city'],
        address = json['address']
  ;

  // build json from canteen
  Map<String, dynamic> toJson() =>
      {
        'id' : id,
        'name' : name,
        'city' : city,
        'address' : address,
      };
}