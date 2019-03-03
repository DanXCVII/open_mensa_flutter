import 'package:flutter/material.dart';

class Dish {
  String _dishName;
  String _category;
  Map<String, double> _priceGroup; // dynamic = double
  List<String> _notes = []; // dynamic = String
  String _icon;
  List<Color> _themeData;

  Dish(Map<String, dynamic> dishRaw) {
    _dishName = dishRaw['name'];
    _category = dishRaw['category'];
    _priceGroup = {
      'students': dishRaw['prices']['students'],
      'employees': dishRaw['prices']['employees'],
      'others': dishRaw['prices']['others']
    };

    _priceGroup['students'] ??= 0;
    _priceGroup['employees'] ??= 0;
    _priceGroup['others'] ??= 0;

    try {
      dishRaw['notes'].forEach((note) {
        _notes.add(note);
      });
    } catch (e) {
      print('no notes for this dish');
    }
    _icon = getIconName('${_dishName}${_category}${_notes}');
    _themeData = getThemeColor(_icon);
  }

  String getDishName() {
    return _dishName;
  }

  String getCategory() {
    return _category;
  }

  String getIcon() {
    return _icon;
  }

  Map<String, double> getPriceGroup() {
    return _priceGroup;
  }

  List<String> getNotes() {
    return _notes;
  }

  List<Color> getThemeData() {
    return _themeData;
  }
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
