import 'package:flutter/material.dart';
import './fetch_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

// creates a checkable list of all canteens
class CheckableMensaList extends StatefulWidget {
  // Map which contains the selected location of the user.
  //final Map<String, double> latlng;

  CheckableMensaList({Key key}) : super(key: key);

  @override
  CheckableMensaListState createState() => CheckableMensaListState();
}

class CheckableMensaListState extends State<CheckableMensaList> {
  bool booo = false;
  // TODO once loaded, save canteens to this variable to not so often access the mensa api
  List<Canteen> listOfCanteens = [];

  // final Future<List<Canteen>> mensaList;
  TextEditingController controller = new TextEditingController();

  //CheckableMensaListState();

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
              title: Text('Select your Canteens'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Search',
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
        title: Text('Select your Canteens'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CanteenSearch(items: listOfCanteens));
            },
          )
        ],
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
                return displayNoMensaFoundMessage(context);
              }
              return Center(child: Text("Fehlermeldung: ${snapshot.error}"));
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<ListView> createCheckedListView(List<Canteen> canteenList) async {
    final prefs = await SharedPreferences.getInstance();
    List<CheckboxListTile> checkableMensaList =
        getCheckableMensaList(canteenList, prefs);

    if (canteenList.isEmpty) {
      throw Exception('No Mensa found');
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd && i < canteenList.length * 2) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index < canteenList.length) {
            return checkableMensaList[index];
          }
        });
  }

  List<CheckboxListTile> getCheckableMensaList(
      List<Canteen> mensas, SharedPreferences prefs) {
    List<CheckboxListTile> mList = new List<CheckboxListTile>();
    for (int index = 0; index < mensas.length; index++) {
      String canteen = json.encode(mensas[index].toJson());
      mList.add(CheckboxListTile(
          title: Text(mensas[index].name),
          value:
              checkPrefForMensa(prefs.getStringList('selectedMensas'), canteen),
          onChanged: (bool value) {
            setState(() {
              List<String> selectedMensas =
                  prefs.getStringList('selectedMensas') ?? [];
              if (value) {
                selectedMensas.add(canteen);
                prefs.setStringList('selectedMensas', selectedMensas);
              } else {
                selectedMensas.remove(canteen);
                prefs.setStringList('selectedMensas', selectedMensas);
              }
            });
          }));
    }
    return mList;
  }

  bool checkPrefForMensa(List<String> mensaList, String mensaName) {
    bool ret = false;
    if (mensaList == null) {
      return false;
    } else {
      for (int i = 0; i < mensaList.length; i++) {
        if (mensaList[i].contains(mensaName)) {
          ret = true;
        }
      }
    }
    return ret;
  }
}

Widget displayNoMensaFoundMessage(BuildContext context) {
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
        'Unfortunately no mensas found',
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
        : items.where((Canteen target) => target.name.contains(query)).toList();
    if (items.isEmpty) {
      return displayNoMensaFoundMessage(context);
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
