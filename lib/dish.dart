import 'package:flutter/material.dart';

class Dish {
  String dishName;
  String category;
  Map<String, double> priceGroup;
  List<String> notes = [];

  MyThemeData themeData;

  Dish({
    this.dishName,
    this.category,
    this.priceGroup,
    this.notes,
    this.themeData,
  });

  factory Dish.fromMap(Map<String, dynamic> dishRaw) => new Dish(
      dishName: dishRaw['name'],
      category: dishRaw['category'],
      priceGroup: initPriceGroup(dishRaw),
      themeData: getIconName(
          '${dishRaw['name']}${dishRaw['category']}${initNotes(dishRaw).toString()}'));

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

MyThemeData getIconName(String dishInfo) {
  String dISHiNFO = dishInfo.toUpperCase();

  MyThemeData theme = themeData['DEFAULT'];
  for (final _key in themeData.keys) {
    if (dISHiNFO.contains(_key)) {
      theme = themeData[_key];
      break;
    }
  }
  return theme;
}

const Map<String, MyThemeData> themeData = {
  'BURGER': MyThemeData('burger', [Colors.yellow, Colors.deepOrange]),
  'PIZZA': MyThemeData('pizza', [Colors.deepOrange, Colors.red]),
  'NUDEL': MyThemeData('spaghetti', [Color(0xFFB71C1C), Colors.amber]),
  'PASTA': MyThemeData('spaghetti', [Color(0xFFB71C1C), Colors.amber]),
  'SPAGHETTI': MyThemeData('spaghetti', [Color(0xFFB71C1C), Colors.amber]),
  'POMMES': MyThemeData('pommes', [Colors.amber, Color(0xFF5D4037)]),
  'HÄHNCHEN':
      MyThemeData('haehnchenBrust', [Color(0xFF5D4037), Color(0xFFBF360C)]),
  'GEFLÜGEL':
      MyThemeData('haehnchenBrust', [Color(0xFF5D4037), Color(0xFFBF360C)]),
  'PUTE': MyThemeData('haehnchenBrust', [Color(0xFF5D4037), Color(0xFFBF360C)]),
  'WURST': MyThemeData('sausage', [Color(0xFF3E2723), Color(0xFF5D4037)]),
  'RÜHREI': MyThemeData('omlett', [Color(0xFFF57F17), Color(0xFFFDD835)]),
  'SPIEGELEI': MyThemeData('omlett', [Color(0xFFF57F17), Color(0xFFFDD835)]),
  'OMLET': MyThemeData('omlett', [Color(0xFFF57F17), Color(0xFFFDD835)]),
  'JOGHURT': MyThemeData('yoghurt', [Colors.teal, Colors.cyan]),
  'SALAT': MyThemeData('salat', [Color(0xFF1B5E20), Color(0xFF558B2F)]),
  'VEGAN': MyThemeData('salat', [Color(0xFF1B5E20), Color(0xFF558B2F)]),
  'CHILI': MyThemeData('chili', [Color(0xFFB71C1C), Color(0xFFD50000)]),
  'SPECK': MyThemeData('bacon', [Color(0xFFFF1744), Color(0xFFD84315)]),
  'SCHNITZEL': MyThemeData('schnitzel', [Color(0xFFEF6C00), Color(0xFF4E342E)]),
  'DEFAULT': MyThemeData('forkSpoon', [Color(0xFFF57C00), Color(0xFFD32F2F)]),
  'RIND': MyThemeData('cow', [Color(0xFFEF6C00), Color(0xFF4E342E)]),
  //
  'FISCH': MyThemeData('fish', [Color(0xFF01579B), Colors.blueAccent]),
  'LACHS': MyThemeData('fish', [Color(0xFF01579B), Colors.blueAccent]),
  //
  'KLOß': MyThemeData('dumpling', [Color(0xFFD7B772), Color(0xFFA14400)]),
  'KLÖSSE': MyThemeData('dumpling', [Color(0xFFD7B772), Color(0xFFA14400)]),
  'KLOSS': MyThemeData('dumpling', [Color(0xFFD7B772), Color(0xFFA14400)]),
  'KNÖDEL': MyThemeData('dumpling', [Color(0xFFD7B772), Color(0xFFA14400)]),
  //
  'RÖSTI': MyThemeData('roesti', [Color(0xFFA76433), Color(0xFFEAB334)]),
  'PUFFER': MyThemeData('roesti', [Color(0xFFA76433), Color(0xFFEAB334)]),
  //
  'LASAGNE': MyThemeData('lasagne', [Color(0xFFF57F17), Color(0xFFFDD835)]),
  'BROCCOLI': MyThemeData('broccoli', [Color(0xff107C28), Color(0xff60DA00)]),
  'BLUMENKOHL':
      MyThemeData('cauliflower', [Color(0xffB4B4B4), Color(0xff646464)]),
  'VANILLEPUDDING':
      MyThemeData('vanille', [Color(0xFFEEBC00), Color(0xFFFFCD1A)]),
  //
  'SCHOKOLADENPUDDING':
      MyThemeData('choco', [Color(0xFF611D00), Color(0xFF9A4521)]),
  'PUDDING': MyThemeData('choco', [Color(0xFF611D00), Color(0xFF9A4521)]),
  //
  'MAULTASCHEN': MyThemeData('ravioli', [Color(0xFFF57F17), Color(0xFFFDD835)]),
  'TASCHEN': MyThemeData('ravioli', [Color(0xFFF57F17), Color(0xFFFDD835)]),
  //
  'LAMM': MyThemeData('sheep', [Color(0xffC0BD95), Color(0xff697064)]),
  'SCHAF': MyThemeData('sheep', [Color(0xffC0BD95), Color(0xff697064)]),
  //
  'EI': MyThemeData('egg', [Color(0xffFFC700), Color(0xffE35200)]),
};

class MyThemeData {
  final String iconName;
  final List<Color> color;

  const MyThemeData(
    this.iconName,
    this.color,
  );
}
