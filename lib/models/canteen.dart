import 'package:hive/hive.dart';

part './adapters/canteen.g.dart';

/// Canteens are identified by name (human readable) and id (for api calls)
/// here, coordinates aren't saved
@HiveType()
class Canteen {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String city;

  @HiveField(3)
  final String address;

  Canteen({
    this.id,
    this.name,
    this.city,
    this.address,
  });

  // build canteen from json
  Canteen.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        name = json['name'],
        city = json['city'],
        address = json['address'];

  // build json from canteen
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'address': address,
      };

  @override
  String toString() => 'canteen: $name, id: $id';
}
