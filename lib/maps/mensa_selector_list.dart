import 'package:flutter/material.dart';
import '../fetch_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// creates a checkable list of mensas near a given location
class CheckableMensaList extends StatefulWidget {
  // Map which contains the selected location of the user.
  final Map<String, double> latlng;

  CheckableMensaList({Key key, @required this.latlng}) : super(key: key);

  @override
  CheckableMensaListState createState() => CheckableMensaListState(
      mensaList:
          fetchMensas(latlng['lat'].toString(), latlng['lng'].toString()));
}

class CheckableMensaListState extends State<CheckableMensaList> {
  bool booo = false;
  final Future<MensaListRawData> mensaList;

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

  Future<ListView> createCheckedListView(Future<MensaListRawData> fMensaList) async {
    MensaListRawData snapshot = await fMensaList;
    final prefs = await SharedPreferences.getInstance();
    List<CheckboxListTile> checkableMensaList = getCheckableMensaList(snapshot.mensas, prefs);

    if (snapshot.mensas.isEmpty) {
      throw Exception('No Mensa found');
    }

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd && i < snapshot.mensas.length * 2) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index < snapshot.mensas.length) {
            return checkableMensaList[index];
          }
        });
  }

  List<CheckboxListTile> getCheckableMensaList(
      List<dynamic> mensas, SharedPreferences prefs) {
    List<CheckboxListTile> mList = new List<CheckboxListTile>();
    for (int index = 0; index < mensas.length; index++)
      mList.add(CheckboxListTile(
          title: Text(mensas[index]['name']),
          value: checkPrefForMensa(
              prefs.getStringList('selectedMensas'), mensas[index]['name']),
          onChanged: (bool value) {
            setState(() {
              List<String> selectedMensas =
                  prefs.getStringList('selectedMensas') ?? [];
              if (value) {
                selectedMensas.add("${mensas[index]['id']}&" +
                    "${mensas[index]['name']}&&" +
                    "${mensas[index]['address']}&&&" +
                    "${mensas[index]['coordinates'][0]}&&&&" +
                    "${mensas[index]['coordinates'][1]}");
                prefs.setStringList('selectedMensas', selectedMensas);
              } else {
                selectedMensas.remove("${mensas[index]['id']}&" +
                    "${mensas[index]['name']}&&" +
                    "${mensas[index]['address']}&&&" +
                    "${mensas[index]['coordinates'][0]}&&&&" +
                    "${mensas[index]['coordinates'][1]}");
                prefs.setStringList('selectedMensas', selectedMensas);
              }
              
            });
          }));
          return mList;
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
