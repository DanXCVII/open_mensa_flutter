import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './generated/i18n.dart';
import 'bloc/canteen_overview/canteen_overview.dart';
import 'bloc/master/master.dart';

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
      child: BlocBuilder<CanteenOverviewBloc, CanteenOverviewState>(
        builder: (context, state) {
          if (state is LoadingCanteenOverviewState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is LoadedCanteenOverviewState) {
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
                delegate: SliverChildListDelegate(
                  state.selectedCanteens.isEmpty
                      ? [noCanteenSelectedText()]
                      : state.selectedCanteens
                          .map(
                            (canteen) => Dismissible(
                              key: Key(canteen.toString()),
                              onDismissed: (direction) {
                                setState(() {
                                  BlocProvider.of<MasterBloc>(context)
                                      .add(MDeleteCanteenEvent(canteen));
                                });
                              },
                              child: Card(
                                child: ListTile(
                                  title: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              )
            ]);
          }
        },
      ),
    );
  }

  Widget noCanteenSelectedText() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Center(
        child: Text(S.of(context).no_canteen_selected),
      ),
    );
  }
}
