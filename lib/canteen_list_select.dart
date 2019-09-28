import 'package:flutter/material.dart';
import './fetch_canteens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import './generated/i18n.dart';

// creates a checkable list of all canteens
class CheckableCanteenList extends StatefulWidget {
  // Map which contains the selected location of the user.
  //final Map<String, double> latlng;

  CheckableCanteenList({Key key}) : super(key: key);

  @override
  CheckableCanteenListState createState() => CheckableCanteenListState();
}

class CheckableCanteenListState extends State<CheckableCanteenList> {
  bool booo = false;
  // TODO once loaded, save canteens to this variable to not so often access the canteen api
  List<Canteen> listOfCanteens = [];

  TextEditingController controller = new TextEditingController();

  //CheckableCanteenListState();

  @override
  build(BuildContext context) {
    // check if canteen list is empty, if it is serve a FutureBuilder while it loads
    if (listOfCanteens.isEmpty) {
      print("loaded canteenss");
      return FutureBuilder<List<Canteen>>(
        future: fetchAllCanteens(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            listOfCanteens = snapshot.data;
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).select_canteens),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: S.of(context).search,
                  onPressed: !snapshot.hasData
                      ? null
                      : () {
                          showSearch(
                              context: context,
                              delegate: CanteenSearch(items: snapshot.data));
                        },
                )
              ],
            ),
            body: snapshot.hasData
                ? ListWidget(items: snapshot.data)
                : Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).select_canteens),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: S.of(context).search,
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CanteenSearch(items: listOfCanteens));
            },
          )
        ],
      ),
      body: ListWidget(
        items: listOfCanteens,
      ),
    );
  }
}

class ListWidget extends StatefulWidget {
  final List<Canteen> items;
  ListWidget({@required this.items});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListWidgetState();
  }
}

class ListWidgetState extends State<ListWidget> {
  ListWidgetState();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<ListView>(
          future: createCheckedListView(widget.items),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data;
            } else if (snapshot.hasError) {
              if (snapshot.error.toString().contains('RangeError') ||
                  snapshot.data == null) {
                return displayNoCanteenFoundMessage(context);
              }
              return Center(child: Text("canteenListSelect build error: ${snapshot.error}"));
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<ListView> createCheckedListView(List<Canteen> canteenList) async {
    final prefs = await SharedPreferences.getInstance();
    List<CheckboxListTile> checkableCanteenList =
        getCheckableCanteenList(canteenList, prefs);

    if (canteenList.isEmpty) {
      throw Exception('No canteen found');
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd && i < canteenList.length * 2) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index < canteenList.length) {
            return checkableCanteenList[index];
          }
          return null;
        });
  }

  List<CheckboxListTile> getCheckableCanteenList(
      List<Canteen> canteens, SharedPreferences prefs) {
    List<CheckboxListTile> mList = new List<CheckboxListTile>();
    for (int index = 0; index < canteens.length; index++) {
      String canteen = json.encode(canteens[index].toJson());
      mList.add(CheckboxListTile(
          title: Text(canteens[index].name),
          value:
              checkPrefForCanteen(prefs.getStringList('selectedCanteens'), canteen),
          onChanged: (bool value) {
            setState(() {
              List<String> selectedCanteens =
                  prefs.getStringList('selectedCanteens') ?? [];
              if (value) {
                selectedCanteens.add(canteen);
                prefs.setStringList('selectedCanteens', selectedCanteens);
              } else {
                selectedCanteens.remove(canteen);
                prefs.setStringList('selectedCanteens', selectedCanteens);
              }
            });
          }));
    }
    return mList;
  }

  bool checkPrefForCanteen(List<String> canteenList, String canteenName) {
    bool ret = false;
    if (canteenList == null) {
      return false;
    } else {
      for (int i = 0; i < canteenList.length; i++) {
        if (canteenList[i].contains(canteenName)) {
          ret = true;
        }
      }
    }
    return ret;
  }
}

Widget displayNoCanteenFoundMessage(BuildContext context) {
  return Center(
      child: Column(
    children: <Widget>[
      Image.asset(
        'images/sad.png',
        width: 128.0,
        height: 128.0,
        color: Colors.grey[600],
      ),
      Text(
        S.of(context).no_canteens_found,
        style: TextStyle(color: Colors.grey[600]),
      ),
    ],
    mainAxisAlignment: MainAxisAlignment.center,
  ));
}

class CanteenSearch extends SearchDelegate<Canteen> {
  List<Canteen> items = [];
  List<Canteen> suggestion = [];

  CanteenSearch({@required this.items});

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return theme.copyWith(
        primaryColor: Colors.grey[800],
        primaryIconTheme:
            theme.primaryIconTheme.copyWith(color: Colors.grey[200]),
        primaryColorBrightness: Brightness.dark,
        primaryTextTheme: theme.textTheme,
      );
    }
    return super.appBarTheme(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    suggestion = query.isEmpty
        ? items
        : items.where((Canteen target) {
            String name = target.name.replaceAll("ß", "ss").toUpperCase();
            String input = query.replaceAll("ß", "ss").toUpperCase();
            return name.contains(input);
          }).toList();
    if (items.isEmpty) {
      return displayNoCanteenFoundMessage(context);
    }
    return ListWidget(
      items: suggestion,
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListWidget(
      items: suggestion,
    );
  }
}
