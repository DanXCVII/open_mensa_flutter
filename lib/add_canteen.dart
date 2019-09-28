import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './fetch_canteens.dart';
import 'dart:convert';
import './generated/i18n.dart';

class AddCanteen extends StatefulWidget {
  @override
  _AddCanteenState createState() {
    return _AddCanteenState();
  }
}

/// TODO: add initState method to not always reload the data. E.g. add
/// a class variable of the output of the async method and call setState()
/// when a new canteen has been added.

class _AddCanteenState extends State<AddCanteen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff3F3B35),
      child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> canteens =
                  snapshot.data.getStringList('selectedCanteens');
              bool noCanteenSelected = canteens == null || canteens.length == 0;

              canteens = snapshot.data.getStringList('selectedCanteens');

              return CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background:
                        Image.asset('images/earth.jpg', fit: BoxFit.cover),
                    title: Text(S.of(context).selected_canteens),
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate(noCanteenSelected
                        ? [noCanteenSelectedText()]
                        : getCanteenList(snapshot.data, canteens)))
              ]);
            } else if (snapshot.hasError) {
              return Text('add_canteen build Error: ${snapshot.error}');
            }
            return (Center(
              child: CircularProgressIndicator(),
            ));
          }),
    );
  }

  List<Widget> getCanteenList(SharedPreferences prefs, canteens) {
    List<Widget> canteenWidgetList = [];
    for (int i = 0; i < canteens.length; i++) {
      Canteen canteen = Canteen.fromJson(json.decode(canteens[i]));
      canteenWidgetList.add(Dismissible(
        key: Key(canteens[i]),
        onDismissed: (direction) {
          setState(() {
            List<String> tmp = prefs.getStringList('selectedCanteens');
            tmp.remove(canteens[i]);
            prefs.setStringList('selectedCanteens', tmp);
          });
        },
        child: Card(
          child: ListTile(
            title: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(canteen.name)),
            subtitle: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(canteen.address)),
            trailing: IconButton(
              icon: Icon(Icons.directions),
              onPressed: () {
                // TODO: Add Directions to Canteen
              },
            ),
          ),
        ),
        background: Container(
          color: Colors.red[800],
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 18.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  )),
              Padding(
                  padding: EdgeInsets.only(right: 18.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ));
    }
    print(canteenWidgetList.toString());
    return canteenWidgetList;
  }

  CustomScrollView canteenList(SharedPreferences prefs, canteens) {
    if (canteens == null || canteens.length == 0) {
      return noCanteenSelectedText();
    } else {
      return CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset('images/earth.jpg', fit: BoxFit.cover),
            title: Text(S.of(context).selected_canteens),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate(getCanteenList(prefs, canteens)))
      ]);
    }
  }

  String getCanteenAddress(String fullCanteenInfo) {
    return fullCanteenInfo.split('&&')[1].split('&&&')[0];
  }

  Widget noCanteenSelectedText() {
    return Container(
        height: MediaQuery.of(context).size.height / 2,
        child: Center(
          child: Text(S.of(context).no_canteen_selected),
        ));
  }
}

String getCanteenName(String fullCanteenInfo) {
  return fullCanteenInfo.split('&&')[0].split('&')[1];
}

String getCanteenId(String fullCanteenInfo) {
  return fullCanteenInfo.split('&')[0];
}
