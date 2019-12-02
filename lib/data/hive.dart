import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import 'package:path_provider/path_provider.dart';

const currentSelectedCanteen = 'currentKey';

class BoxNames {
  static final selectedCanteensBox = "selectedCanteens";
  static final selectedCanteenIndexBox = "selectedCanteenIndex";
  static final currentDishesBox = "currentDishes";
  static final favoriteDishesBox = "favoriteDishes";
}

class HiveProvider {
  static final HiveProvider _singleton = HiveProvider._internal(
    Hive.box<Canteen>(BoxNames.selectedCanteensBox),
    Hive.box<String>(BoxNames.selectedCanteenIndexBox),
    Hive.box<Map<String, List<Dish>>>(BoxNames.currentDishesBox),
    Hive.box<Dish>(BoxNames.favoriteDishesBox),
  );

  Box<Canteen> selectedCanteensBox;
  Box<String> selectedCanteenIndexBox;
  Box<Map<String, List<Dish>>> currentDishesBox;
  Box<Dish> favoriteDishesBox;

  factory HiveProvider() {
    return _singleton;
  }

  HiveProvider._internal(
    this.selectedCanteensBox,
    this.selectedCanteenIndexBox,
    this.currentDishesBox,
    this.favoriteDishesBox,
  );

  Map<DateTime, List<Dish>> getCachedDataOfCanteen(Canteen canteen) {
    Map<String, List<Dish>> hiveData =
        currentDishesBox.get(getHiveKey(canteen.name));

    Map<DateTime, List<Dish>> output = {};

    for (String key in hiveData.keys) {
      output.addAll({DateTime.parse(key): hiveData[key]});
    }
    return output;
  }

  Canteen getCurrentCanteen() {
    return selectedCanteensBox
        .get(selectedCanteenIndexBox.get(currentSelectedCanteen));
  }

  List<Canteen> getSelectedCanteens() {
    final List<Canteen> selectedCanteens =
        selectedCanteensBox.keys.map((key) => selectedCanteensBox.get(key));

    return selectedCanteens;
  }

  List<Dish> getFavoriteDishes() {
    final List<Dish> favoriteDishes =
        favoriteDishesBox.keys.map((key) => favoriteDishesBox.get(key));

    return favoriteDishes;
  }

  DateTime getDateOfLatestDish(Canteen canteen) {
    return DateTime.parse(currentDishesBox.keys.first);
  }

  Future<void> cacheDataOfCanteen(
      Canteen canteen, Map<DateTime, List<Dish>> dishes) async {
    Map<String, List<Dish>> hiveData = {};

    for (DateTime key in dishes.keys) {
      hiveData.addAll({key.toIso8601String(): dishes[key]});
    }

    await currentDishesBox.put(getHiveKey(canteen.name), hiveData);
  }

  Future<void> setCurrentSelectedCanteen(Canteen canteen) async {
    await selectedCanteenIndexBox.put(
        currentSelectedCanteen, getHiveKey(canteen.name));
  }

  Future<void> addSelectedCanteen(Canteen canteen) async {
    await selectedCanteensBox.put(getHiveKey(canteen.name), canteen);
  }

  Future<void> addFavoriteDish(Dish dish) async {
    favoriteDishesBox.add(dish);
  }

  Future<void> deleteCachedDataFromCanteen(Canteen canteen) async {
    await currentDishesBox.delete(getHiveKey(canteen.name));
  }

  Future<void> deleteFavoriteDish(Dish dish) async {
    for (var key in favoriteDishesBox.keys) {
      if (favoriteDishesBox.get(key) == dish)
        await favoriteDishesBox.delete(key);
    }
  }

  Future<void> removeSelectedCanteen(Canteen canteen) async {
    await selectedCanteensBox.delete(getHiveKey(canteen.name));
  }

  ////////////// hive internal related //////////////
  String getHiveKey(String name) {
    if (name == "no category") return "no category";
    if (name.contains(RegExp(r"[^\x00-\x7F]+"))) {
      List<int> bytes = utf8.encode(name).toList();
      for (int i = 0; i < bytes.length; i++) {
        if (bytes[i] > 127) {
          bytes.insert(i + 1, bytes[i] - 127);
          bytes[i] = 127;
        }
      }

      return String.fromCharCodes(bytes);
    }
    return name;
  }
}

// must(!) be executed before calling the HiveProvider
Future<void> initHive(bool firstTime) async {
  if (firstTime) {
    Hive.init((await getApplicationDocumentsDirectory()).path);
    Hive.registerAdapter(DishAdapter(), 1);
    Hive.registerAdapter(CanteenAdapter(), 2);
  }

  await Hive.openBox<Canteen>(BoxNames.selectedCanteensBox);
  Hive.openBox<String>(BoxNames.selectedCanteenIndexBox);
  Hive.openBox<Map<String, List<Dish>>>(BoxNames.currentDishesBox);
  Hive.openBox<Dish>(BoxNames.favoriteDishesBox);
}
