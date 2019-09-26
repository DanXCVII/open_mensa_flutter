import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './fetch_canteens.dart';
import 'dart:convert';

class AddMensa extends StatefulWidget {

  @override
  _AddMensaState createState() {
    return _AddMensaState();
  }
}

/// TODO: add initState method to not always reload the data. E.g. add
/// a class variable of the output of the async method and call setState()
/// when a new mensa has been added.

class _AddMensaState extends State<AddMensa> {
  List<String> canteens;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff3F3B35),
      child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.getStringList('selectedMensas') == null ||
                  snapshot.data.getStringList('selectedMensas').length == 0) {
                return noMensaSelected();
              } else {
                canteens = snapshot.data.getStringList('selectedMensas');
                return mensaList(snapshot.data);
              }
            } else if (snapshot.hasError) {
              return Text('add_mensa build Error: ${snapshot.error}');
            }
            return (Center(
              child: CircularProgressIndicator(),
            ));
          }),
    );
  }

  List<Widget> getMensaList(SharedPreferences prefs) {
    List<Widget> mensaWidgetList = [];
    for (int i = 0; i < canteens.length; i++) {
      Canteen canteen = Canteen.fromJson(json.decode(canteens[i]));
      mensaWidgetList.add(Dismissible(
        key: Key(canteens[i]),
        onDismissed: (direction) {
          setState(() {
            List<String> tmp = prefs.getStringList('selectedMensas');
            tmp.remove(canteens[i]);
            prefs.setStringList('selectedMensas', tmp);
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
                // TODO: Add Directions to Mensa
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
    print(mensaWidgetList.toString());
    return mensaWidgetList;
  }

  CustomScrollView mensaList(SharedPreferences prefs) {
    if (canteens == null || canteens.length == 0) {
      return noMensaSelected();
    } else {
      return CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset('images/earth.jpg', fit: BoxFit.cover),
            title: Text("Selected Canteens"),
          ),
        ),
        SliverList(delegate: SliverChildListDelegate(getMensaList(prefs)))
      ]);
    }
  }

  String getMensaAddress(String fullMensaInfo) {
    return fullMensaInfo.split('&&')[1].split('&&&')[0];
  }

  Widget noMensaSelected() {
    return Scaffold(
      appBar: AppBar(title: Text("Add Mensa")),
      body: Center(
          child: Text(
        'You haven\'t selected any canteen yet',
        style: TextStyle(color: Colors.grey[700]),
      )),
    );
  }
}

String getMensaName(String fullMensaInfo) {
  return fullMensaInfo.split('&&')[0].split('&')[1];
}

String getMensaId(String fullMensaInfo) {
  return fullMensaInfo.split('&')[0];
}
