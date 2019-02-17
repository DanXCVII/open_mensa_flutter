import 'package:flutter/material.dart';

class CurrentDishes extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CurrentDishesState();
  }
}

class CurrentDishesState extends State<CurrentDishes> {
  @override
  Widget build(BuildContext context) {
    print('CurrentDishesState');
    return Scaffold(
        body: createDishCard(
            '2019-02-15',
            'Spaghetti mit Schinken-Käse-Sahnesoße und Reibekäse',
            'Angebote',
            {'students': 2.25, 'pupils': 5.00, 'others': 5.00},
            ['enthält Schweinefleisch', 'vegetarisch'],
            context));
  }
}

Widget createDishCard(String date, String dishName, String category,
    Map<String, double> prices, List<String> notes, BuildContext context) {
  double width = MediaQuery.of(context).size.width;

  return Stack(children: <Widget>[
    ListView(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 100),
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 20.0,
                spreadRadius: 5.0,
                offset: Offset(10.0, 10.0),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0), color: Colors.white),
            width: width * 0.9,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 18.0, left: 12.0, right: 12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      dishName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[Text('students:'), Text('2.30')],
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Theme.of(context).dividerColor))),
                        ),
                        Column(
                          children: <Widget>[Text('students:'), Text('2.30')],
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Theme.of(context).dividerColor))),
                        ),
                        Column(
                          children: <Widget>[Text('students:'), Text('2.30')],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                      child: Text('Angebote'), // TODO: Unten rechts.
                    ),
                  ]),
            ),
          ),
        ),
      ),
      Text('213')
    ]),
  ]);
}
