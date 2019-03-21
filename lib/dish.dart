import 'package:flutter/material.dart';

class Dish {
  String dishName;
  String category;
  Map<String, double> priceGroup;
  List<String> notes = [];
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

const Map<String, List<Color>> themeData = {
  'burger': [Colors.yellow, Colors.deepOrange],
  'pizza': [Colors.deepOrange, Colors.red],
  'fish': [Color(0xFF01579B), Colors.blueAccent], // lightBlue[900]
  'spaghetti': [Color(0xFFB71C1C), Colors.amber], // red[900]
  'pommes': [Colors.amber, Color(0xFF5D4037)], // brown[700]
  'haehnchenBrust': [
    Color(0xFF5D4037),
    Color(0xFFBF360C)
  ], // brown[700], deepOrange[900]
  'sausage': [Color(0xFF3E2723), Color(0xFF5D4037)], // brown[900], brown[700]
  'omlett': [Color(0xFFF57F17), Color(0xFFFDD835)], // yellow[900], yellow[600]
  'yoghurt': [Colors.teal, Colors.cyan],
  'salat': [
    Color(0xFF1B5E20),
    Color(0xFF558B2F)
  ], // green[900], lightGreen[800]
  'chili': [Color(0xFFB71C1C), Color(0xFFD50000)], // red[900], redAccent[700]
  'bacon': [
    Color(0xFFFF1744),
    Color(0xFFD84315)
  ], // redAccent[400], deepOrange[800]
  'schnitzel': [
    Color(0xFFEF6C00),
    Color(0xFF4E342E)
  ], // orange[800], brown[800]
  'default': [Color(0xFFF57C00), Color(0xFFD32F2F)], // orange[700], red[700]
};

List<Color> getThemeColor(String dish) {
  return themeData[dish] ?? themeData['default'];
}
