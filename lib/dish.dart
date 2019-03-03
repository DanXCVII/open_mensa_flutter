import 'package:flutter/material.dart';

class Dish {
  String dishName;
  String category;
  Map<String, double> priceGroup; // dynamic = double
  List<String> notes = []; // dynamic = String
  String icon;
  List<Color> themeData;

  Dish({
    this.dishName,
    this.category,
    this.priceGroup,
    this.notes,
    this.icon,
    this.themeData,
  });

  factory Dish.fromMap(Map<String, dynamic> dishRaw) => new Dish(
      dishName: dishRaw['name'],
      category: dishRaw['category'],
      priceGroup: initPriceGroup(dishRaw),
      notes: initNotes(dishRaw),
      icon: getIconName(
          '${dishRaw['name']}${dishRaw['category']}${initNotes(dishRaw).toString()}'),
      themeData: getThemeColor(getIconName(
          '${dishRaw['name']}${dishRaw['category']}${initNotes(dishRaw).toString()}')));

  Map<String, dynamic> toMap() => {
        "name": dishName,
        "category": category,
        "prices": {
          'students': priceGroup['students'],
          'employees': priceGroup['employees'],
          'others': priceGroup['others'],
        },
        "notes": notes,
      };
}

Map<String, double> initPriceGroup(Map<String, dynamic> dishRaw) {
  Map<String, double> priceGroup = {
    'students': dishRaw['prices']['students'],
    'employees': dishRaw['prices']['employees'],
    'others': dishRaw['prices']['others'],
  };

  priceGroup['students'] ??= 0;
  priceGroup['employees'] ??= 0;
  priceGroup['others'] ??= 0;
  return priceGroup;
}

List<String> initNotes(Map<String, dynamic> dishRaw) {
  List<String> notes = [];
  try {
    dishRaw['notes'].forEach((note) {
      notes.add(note);
    });
  } catch (e) {
    print('no notes for this dish');
  }
  return notes;
}

String getIconName(String dishInfo) {
  String dISHiNFO = dishInfo.toUpperCase();

  if (dISHiNFO.contains('BURGER')) {
    return 'burger';
  } else if (dISHiNFO.contains('PIZZA')) {
    return 'pizza';
  } else if (dISHiNFO.contains('FISCH') || dISHiNFO.contains('LACHS')) {
    return 'fish';
  } else if (dISHiNFO.contains('SPAGHETTI') ||
      dISHiNFO.contains('PASTA') ||
      dISHiNFO.contains('NUDEL')) // Maybe not adding the image at nudeln..
  {
    return 'spaghetti';
  } else if (dISHiNFO.contains('POMMES')) {
    return 'pommes';
  } else if (dISHiNFO.contains('GEFLÜGEL') ||
      dISHiNFO.contains('HÄHNCHEN') ||
      dISHiNFO.contains('PUTE')) {
    return 'haehnchenBrust';
  } else if (dISHiNFO.contains('WURST')) {
    return 'sausage';
  } else if (dISHiNFO.contains('RÜHREI') ||
      dISHiNFO.contains('SPIEGELEI') ||
      dISHiNFO.contains('OMLET')) {
    return 'omlett';
  } else if (dISHiNFO.contains('JOGHURT')) {
    return 'yoghurt';
  } else if (dISHiNFO.contains('CHILI')) {
    return 'chili';
  } else if (dISHiNFO.contains('SALAT') || dISHiNFO.contains('VEGAN')) {
    return 'salat';
  } else if (dISHiNFO.contains('SPECK')) {
    return 'bacon';
  } else if (dISHiNFO.contains("SCHNITZEL")) {
    return 'schnitzel';
  } else if (dISHiNFO.contains('RIND') || dISHiNFO.contains('FLEISCH')) {
    return 'pork';
  } else {
    return 'forkSpoon';
  }
}

List<Color> getThemeColor(String dish) {
  if (dish == 'burger') {
    return [Colors.yellow, Colors.deepOrange];
  } else if (dish == 'pizza') {
    return [Colors.deepOrange, Colors.red];
  } else if (dish == 'fish') {
    return [Colors.lightBlue[900], Colors.blueAccent];
  } else if (dish == 'spaghetti') {
    return [Colors.red[900], Colors.amber];
  } else if (dish == 'pommes') {
    return [Colors.amber, Colors.brown[700]];
  } else if (dish == 'haehnchenBrust') {
    return [Colors.brown[700], Colors.deepOrange[900]];
  } else if (dish == 'sausage') {
    return [Colors.brown[900], Colors.brown[700]];
  } else if (dish == 'omlett') {
    return [Colors.yellow[900], Colors.yellow[600]];
  } else if (dish == 'yoghurt') {
    return [Colors.teal, Colors.cyan];
  } else if (dish == 'salat') {
    return [Colors.green[900], Colors.lightGreen[800]];
  } else if (dish == 'chili') {
    return [Colors.red[900], Colors.redAccent[700]];
  } else if (dish == 'bacon') {
    return [Colors.redAccent[400], Colors.deepOrange[800]];
  } else if (dish == 'schnitzel') {
    return [Colors.orange[800], Colors.brown[800]];
  } else {
    return [Colors.orange[700], Colors.red[700]];
  }
}
