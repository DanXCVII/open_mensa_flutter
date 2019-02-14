import 'package:flutter/material.dart';
import '../fetch_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckableMensaList extends StatefulWidget {
  // Map which contains the selected location of the user.
  final Map<String, double> latlng;

  CheckableMensaList({Key key, @required this.latlng}) : super(key: key);

  @override
  CheckableMensaListState createState() => new CheckableMensaListState(
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
        ),
        body: FutureBuilder<ListView>(
            future: createCheckedListView(mensaList),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data;
              } else if (snapshot.hasError) {
                if (snapshot.error.toString().contains('RangeError')) {
                  return displayNoMensaFoundMessage(context);
                }
                return Center(child: Text("Fehlermeldung: ${snapshot.error}"));
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Future<ListView> createCheckedListView(Future<MensaList> fMensaList) async {
    MensaList snapshot = await fMensaList; // TODO: catch error.
    final prefs = await SharedPreferences.getInstance();

    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
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
                      selectedMensas.add(snapshot.mensas[index]['name']);
                      prefs.setStringList('selectedMensas', selectedMensas);
                    } else {
                      selectedMensas.remove(snapshot.mensas[index]['name']);
                      prefs.setStringList('selectedMensas', selectedMensas);
                    }
                  });
                });
          }
        });
  }

  Widget displayNoMensaFoundMessage(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        Text(
          '😕', // TODO: Change emoji to a more material one ;)
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 5.0),
        ),
        Text('Unfortunately no mensas found'),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    ));
  }

  bool checkPrefForMensa(List<String> mensaList, String mensaName) {
    if (mensaList == null) {
      return false;
    } else {
      return mensaList.contains(mensaName);
    }
  }
}
