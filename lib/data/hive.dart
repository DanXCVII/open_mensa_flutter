import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

const currentSelectedCanteen = 'currentKey';
const dislikedDishesKey = 'dislikedDishes';
const likedDishesKey = 'likedDishes';
const favoriteDishesKey = 'favoriteDishes';

class BoxNames {
  static final selectedCanteensBox = "selectedCanteens";
  static final selectedCanteenIndexBox = "selectedCanteenIndex";
  static final currentDishesBox = "currentDishes";
  static final ratedDishesBox = "ratedDishes";
}

class HiveProvider {
  static final HiveProvider _singleton = HiveProvider._internal(
    Hive.box<Canteen>(BoxNames.selectedCanteensBox),
    Hive.box<String>(BoxNames.selectedCanteenIndexBox),
    Hive.box<Map>(BoxNames.currentDishesBox),
    Hive.box<List>(BoxNames.ratedDishesBox),
  );

  Box<Canteen> selectedCanteensBox;
  Box<String> selectedCanteenIndexBox;
  Box<Map> currentDishesBox;
  Box<List> ratedDishesBox;

  factory HiveProvider() {
    return _singleton;
  }

  HiveProvider._internal(
    this.selectedCanteensBox,
    this.selectedCanteenIndexBox,
    this.currentDishesBox,
    this.ratedDishesBox,
  );

  Map<DateTime, List<Dish>> getCachedDataOfCanteen(Canteen canteen) {
    Map<String, List> hiveData;
    var tmpHiveData = currentDishesBox.get(getHiveKey(canteen.name));
    hiveData = tmpHiveData == null ? null : tmpHiveData.cast<String, List>();

    Map<DateTime, List<Dish>> output = {};

    for (String key in hiveData.keys) {
      var dynamicList = hiveData[key];
      List<Dish> dishList = dynamicList.cast<Dish>();
      output.addAll(
          {DateTime.parse(key): dishList..map((dish) => dish).toList()});
    }
    return output;
  }

  Canteen getCurrentCanteen() {
    return selectedCanteensBox
        .get(selectedCanteenIndexBox.get(currentSelectedCanteen));
  }

  List<Canteen> getSelectedCanteens() {
    final List<Canteen> selectedCanteens = selectedCanteensBox.keys
        .map((key) => selectedCanteensBox.get(key))
        .toList();

    return selectedCanteens;
  }

  List<Dish> getDislikedDishes() {
    var dislikedDishesHive = ratedDishesBox.get(dislikedDishesKey);
    List<Dish> dislikedDishes =
        dislikedDishesHive != null ? dislikedDishesHive.cast<Dish>() : [];

    return dislikedDishes;
  }

  List<Dish> getLikedDishes() {
    var hiveLikedDishes = ratedDishesBox.get(likedDishesKey);
    List<Dish> likedDishes =
        hiveLikedDishes != null ? hiveLikedDishes.cast<Dish>() : [];

    return likedDishes;
  }

  List<Dish> getFavoriteDishes() {
    var hiveFavoriteDishes = ratedDishesBox.get(favoriteDishesKey);
    List<Dish> favoriteDishes =
        hiveFavoriteDishes != null ? hiveFavoriteDishes.cast<Dish>() : [];

    return favoriteDishes;
  }

  /// returns the first date of the cached data which the canteen holds on index 0.
  /// And on index 1 the latest date of dishinfo in the cache. If
  /// there is no data cached under this canteen, it returns null.
  List<DateTime> getDateRangeOfCache(Canteen canteen) {
    Map<String, List<Dish>> currentDishes;
    var tmpHiveData = currentDishesBox.get(getHiveKey(canteen.name));
    currentDishes =
        tmpHiveData == null ? null : tmpHiveData.cast<String, List<Dish>>();

    if (currentDishes == null || currentDishes.keys.isEmpty) return null;
    return [
      DateTime.parse(currentDishes.keys.first),
      DateTime.parse(currentDishes.keys.last)
    ];
  }

  Future<void> cacheDataOfCanteen(
      Canteen canteen, Map<DateTime, List<Dish>> dishes) async {
    Map<String, List<Dish>> cacheData = {};

    for (DateTime key in dishes.keys) {
      cacheData.addAll({key.toIso8601String(): dishes[key]});
    }

    await currentDishesBox.put(getHiveKey(canteen.name), cacheData);
  }

  Future<void> setCurrentSelectedCanteen(Canteen canteen) async {
    await selectedCanteenIndexBox.put(
        // this may seem like wrong order but isnt:
        // this box only contains one item at the index currentSelectedCanteen
        // which stores the key of the canteen
        currentSelectedCanteen,
        getHiveKey(canteen.name));
  }

  Future<void> deleteCurrentSelectedCanteen() async {
    await selectedCanteenIndexBox.delete(currentSelectedCanteen);
  }

  Future<void> addSelectedCanteen(Canteen canteen) async {
    await selectedCanteensBox.put(getHiveKey(canteen.name), canteen);
  }

  Future<void> changeRatedState(Dish dish, DishRated ratedState) async {
    switch (ratedState) {
      case DishRated.Disliked:
        await ratedDishesBox.put(
            dislikedDishesKey, getDislikedDishes()..add(dish));
        return;
      case DishRated.Liked:
        await ratedDishesBox.put(likedDishesKey, getLikedDishes()..add(dish));
        return;
      case DishRated.Favorite:
        await ratedDishesBox.put(
            likedDishesKey, getFavoriteDishes()..add(dish));
        return;
      case DishRated.Undecided:
        await removeRatedState(dish);
        return;
      default:
    }
  }

  Future<void> removeRatedState(Dish dish) async {
    for (var ratedTypeKey in ratedDishesBox.keys) {
      if (ratedDishesBox.get(ratedTypeKey).contains(dish)) {
        ratedDishesBox.put(
            ratedTypeKey, ratedDishesBox.get(ratedTypeKey)..remove(dish));
        return;
      }
    }
  }

  Future<void> deleteCachedDataFromCanteen(Canteen canteen) async {
    await currentDishesBox.delete(getHiveKey(canteen.name));
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
