import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './fetch_data.dart';
import 'dart:convert';

import './main.dart';

class AddMensa extends StatefulWidget {
  final Drawer myDrawer;

  AddMensa({Key key, @required this.myDrawer}) : super(key: key);

  @override
  _AddMensaState createState() {
    return _AddMensaState(myDrawer: myDrawer);
  }
}

/// TODO: add initState method to not always reload the data. E.g. add
/// a class variable of the output of the async method and call setState()
/// when a new mensa has been added.

class _AddMensaState extends State<AddMensa> {
  List<String> mensas;
  Drawer myDrawer;

  _AddMensaState({@required this.myDrawer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange[700],
          onPressed: () {
            Navigator.pushNamed(context, '/mensa_list');
          },
          child: Icon(Icons.add),
),
      body: FutureBuilder<SharedPreferences>(
              future: getPrefs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.getStringList('selectedMensas') == null ||
                      snapshot.data.getStringList('selectedMensas').length == 0) {
                    print('data ist null!!!');
                    return noMensaSelected();
                  } else {
                    mensas = snapshot.data.getStringList('selectedMensas');
                    return mensaList(snapshot.data);
                  }
                } else if (snapshot.hasError) {
                  return Text('Fehlermeldung${snapshot.error}');
                }
                return (Center(
                  child: CircularProgressIndicator(),
                ));
              }),
    );
  }

  List<Widget> getMensaList(SharedPreferences prefs) {
    List<Widget> mensaWidgetList = [];
    for (int i = 0; i < mensas.length; i++) {
      Canteen canteen = Canteen.fromJson(json.decode(mensas[i]));
      mensaWidgetList.add(Dismissible(
        key: Key(mensas[i]),
        onDismissed: (direction) {
          setState(() {
            List<String> tmp = prefs.getStringList('selectedMensas');
            tmp.remove(mensas[i]);
            prefs.setStringList('selectedMensas', tmp);
          });
        },
        child: Card(
          child: ListTile(
            title: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(canteen.name)
            ),
            subtitle: Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(canteen.address)
            ),
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
    if (mensas == null || mensas.length == 0) {
      return noMensaSelected();
    } else {
      return CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset('images/earth.png', fit: BoxFit.fitWidth),
            title: Text("Current Dishes"),
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
      drawer: myDrawer,
      body: Center(
          child: Text(
        'You haven\'t selected any mensa yet',
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
