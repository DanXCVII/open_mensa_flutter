import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Canteen.fromJson(Map<String, dynamic> json)
      :
        id = json['id'].toString(),
        name = json['name'],
        city = json['city'],
        address = json['address']
  ;

  // build json from canteen
  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'city': city,
        'address': address,
      };
}