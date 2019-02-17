import 'package:flutter/material.dart';
import './maps/static_map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMensa extends StatefulWidget {
  AddMensa({Key key}) : super(key: key);

  @override
  _AddMensaState createState() {
    return _AddMensaState();
  }
}

/// TODO: add initState method to not always reload the data. E.g. add
/// a class variable of the output of the async method and call setState()
/// when a new mensa has been added.

class _AddMensaState extends State<AddMensa> {
  List<String> mensas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[700],
          onPressed: () {
            Navigator.pushNamed(context, '/mensa_selector');
          },
          child: Icon(Icons.add),
        ),
        body: FutureBuilder<SharedPreferences>(
            future: getPrefs(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null) {
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
            }));
  }

  Widget mensaList(SharedPreferences prefs) {
    if (mensas == null || mensas.length == 0) {
      return noMensaSelected();
    } else {
      return ListView.builder(
          itemCount: mensas.length,
          itemBuilder: (BuildContext _context, int i) {
            return Dismissible(
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
                      child: Text(getMensaName(mensas[i]))),
                  subtitle: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(getMensaAddress(mensas[i]))),
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
                child: Padding(
                    padding: EdgeInsets.only(right: 18.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    )),
              ),
            );
          });
    }
  }

  String getMensaName(String fullMensaInfo) {
    return fullMensaInfo.split('&&')[0].split('&')[1];
  }

  String getMensaAddress(String fullMensaInfo) {
    return fullMensaInfo.split('&&')[1].split('&&&')[0];
  }

  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Widget noMensaSelected() {
    return Center(
        child: Text(
      'You haven\'t selected any mensa yet',
      style: TextStyle(color: Colors.grey[700]),
    ));
  }
}
