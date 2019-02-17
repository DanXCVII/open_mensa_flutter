import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        backgroundColor: Colors.grey[100],
        body: ListView(children: <Widget>[
          createDishCard(
              '2019-02-15',
              'Spaghetti mit Schinken-Käse-Sahnesoße und Reibekäse',
              'Angebote',
              {'students': 2.25, 'pupils': 5.00, 'others': 5.00},
              ['enthält Schweinefleisch', 'vegetarisch'],
              context),
          createDishCard(
              '2019-02-15',
              'Spaghetti mit Schinken-Käse-Sahnesoße und Reibekäse',
              'Angebote',
              {'students': 2.25, 'pupils': 5.00, 'others': 5.00},
              ['enthält Schweinefleisch', 'vegetarisch'],
              context),
        ]));
  }
}

Widget createDishCard(String date, String dishName, String category,
    Map<String, double> prices, List<String> notes, BuildContext context) {
  double width = MediaQuery.of(context).size.width;

  return Stack(children: <Widget>[
    Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 50),
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
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                    begin: FractionalOffset.topLeft,
                    end: FractionalOffset.bottomRight,
                    stops: [0.0, 1.0],
                  )),
              width: width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.favorite_border,
                          color: Colors
                              .white), // TODO: If saved to favourites: Icon is favorite and not only border
                      onPressed: () {}),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            // TODO: Center properly. When device in landscape mode, it's not correctly centered right now
                            dishName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    'students:',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  Text(
                                    '2.30€',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 28,
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor))),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'students:',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  Text(
                                    '2.30€',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 28,
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Theme.of(context)
                                                .dividerColor))),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'students:',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  Text(
                                    '2.30€',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 5.0),
                            child: Text('Angebote',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle
                                        .italic)), // TODO: Unten rechts.
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    Padding(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/fish.svg',
            semanticsLabel: 'Acme Logo',
            height: 80,
          ),
        ],
      ),
    ),
  ]);
}
