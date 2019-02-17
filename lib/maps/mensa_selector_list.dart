import 'package:flutter/material.dart';
import '../fetch_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class CheckableMensaList extends StatefulWidget {
  // Map which contains the selected location of the user.
  final Map<String, double> latlng;

  CheckableMensaList({Key key, @required this.latlng}) : super(key: key);

  @override
  CheckableMensaListState createState() => CheckableMensaListState(
      mensaList: fetchPost(latlng['lat'].toString(), latlng['lng'].toString()));
}

class CheckableMensaListState extends State<CheckableMensaList> {
  bool booo = false;
  final Future<MensaList> mensaList;

  CheckableMensaListState({@required this.mensaList});

  @override
  build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select your Mensas'),
          backgroundColor: Colors.black87,
          actions: <Widget>[
            FlatButton(
              child: Text(
                'confirm',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            )
          ],
        ),
        body: FutureBuilder<ListView>(
            future: createCheckedListView(mensaList),
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
            }));
  }

  Future<ListView> createCheckedListView(Future<MensaList> fMensaList) async {
    MensaList snapshot = await fMensaList;
    final prefs = await SharedPreferences.getInstance();

    if (snapshot.mensas.isEmpty || snapshot.mensas == null) {
      throw Exception('No Mensa found');
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          print('OMGGGGG');
          if (i.isOdd && i < snapshot.mensas.length * 2) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index < snapshot.mensas.length) {
            return CheckboxListTile(
                title: Text(snapshot.mensas[index]['name']),
                value: checkPrefForMensa(prefs.getStringList('selectedMensas'),
                    snapshot.mensas[index]['name']),
                onChanged: (bool value) {
                  setState(() {
                    List<String> selectedMensas =
                        prefs.getStringList('selectedMensas') ?? [];
                    if (value) {
                      selectedMensas.add("${snapshot.mensas[index]['id']}&" +
                          "${snapshot.mensas[index]['name']}&&" +
                          "${snapshot.mensas[index]['address']}&&&" +
                          "${snapshot.mensas[index]['coordinates'][0]}&&&&" +
                          "${snapshot.mensas[index]['coordinates'][1]}");
                      prefs.setStringList('selectedMensas', selectedMensas);
                    } else {
                      selectedMensas.remove("${snapshot.mensas[index]['id']}&" +
                          "${snapshot.mensas[index]['name']}&&" +
                          "${snapshot.mensas[index]['address']}&&&" +
                          "${snapshot.mensas[index]['coordinates'][0]}&&&&" +
                          "${snapshot.mensas[index]['coordinates'][1]}");
                      prefs.setStringList('selectedMensas', selectedMensas);
                    }
                  });
                });
          }
        });
  }

  Widget displayNoMensaFoundMessage(BuildContext context) {
    print('Dekorierung gestartet');
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
