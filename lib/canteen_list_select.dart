import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './generated/i18n.dart';
import 'bloc/add_canteen/add_canteen.dart';
import 'models/canteen.dart';

class CheckableCanteenListBlocArgs {
  final BuildContext masterBlocContext;

  CheckableCanteenListBlocArgs(this.masterBlocContext);
}

class CheckableCanteenList extends StatelessWidget {
  //CheckableCanteenListState();

  @override
  build(BuildContext context) {
    // check if canteen list is empty, if it is serve a FutureBuilder while it loads
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).select_canteens),
        actions: <Widget>[
          BlocBuilder(
              bloc: BlocProvider.of<AddCanteenBloc>(context),
              condition: (oldState, newState) {
                if (oldState is LoadedCanteenOverview &&
                    newState is LoadedCanteenOverview) {
                  return false;
                }
                return true;
              },
              builder: (context, state) {
                if (state is LoadingCanteenOverview) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is LoadedCanteenOverview) {
                  return IconButton(
                    icon: Icon(Icons.search),
                    tooltip: S.of(context).search,
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: CanteenSearch(
                          items: state.canteens,
                          addCanteenBloc:
                              BlocProvider.of<AddCanteenBloc>(context),
                        ),
                      );
                    },
                  );
                } else {
                  return Text(state.toString());
                }
              })
        ],
      ),
      body: ListWidget(
        addCanteenBloc: BlocProvider.of<AddCanteenBloc>(context),
      ),
    ));
  }
}

class ListWidget extends StatelessWidget {
  final List<Canteen> canteens;
  final AddCanteenBloc addCanteenBloc;

  const ListWidget({
    this.canteens,
    @required this.addCanteenBloc,
  });

  @override
  Widget build(BuildContext context) {
    if (canteens == null || canteens.isNotEmpty) {
      return Container(
          child: BlocBuilder(
              bloc: addCanteenBloc,
              builder: (context, state) {
                if (state is LoadingCanteenOverview) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is LoadedCanteenOverview) {
                  List<Canteen> selectedCanteens =
                      canteens == null ? state.canteens : canteens;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (BuildContext _context, int i) {
                      if (i.isOdd && i < selectedCanteens.length * 2) {
                        return const Divider();
                      }
                      final int index = i ~/ 2;
                      if (index < selectedCanteens.length) {
                        return CheckboxListTile(
                          title: Text(selectedCanteens[index].name),
                          value: state.selectedCanteens
                              .contains(selectedCanteens[index]),
                          onChanged: (bool value) {
                            BlocProvider.of<AddCanteenBloc>(context).add(
                                SelectCanteenEvent(
                                    selectedCanteens[index], value));
                          },
                        );
                      }
                      return null;
                    },
                  );
                } else {
                  return Text(state.toString());
                }
              }));
    } else if (canteens.isEmpty) {
      return Container(child: displayNoCanteenFoundMessage(context));
    }
    return Text("Fatal Error. Debug");
  }
}

Widget displayNoCanteenFoundMessage(BuildContext context) {
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
        S.of(context).no_canteens_found,
        style: TextStyle(color: Colors.grey[600]),
      ),
    ],
    mainAxisAlignment: MainAxisAlignment.center,
  ));
}

class CanteenSearch extends SearchDelegate<Canteen> {
  List<Canteen> items = [];
  List<Canteen> suggestion = [];
  AddCanteenBloc addCanteenBloc;

  CanteenSearch({
    @required this.items,
    @required this.addCanteenBloc,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) {
      return theme.copyWith(
        primaryColor: Colors.grey[800],
        primaryIconTheme:
            theme.primaryIconTheme.copyWith(color: Colors.grey[200]),
        primaryColorBrightness: Brightness.dark,
        primaryTextTheme: theme.textTheme,
      );
    }
    return super.appBarTheme(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    suggestion = query.isEmpty
        ? items
        : items.where((Canteen target) {
            String name = target.name.replaceAll("ß", "ss").toUpperCase();
            String input = query.replaceAll("ß", "ss").toUpperCase();
            return name.contains(input);
          }).toList();
    if (items.isEmpty) {
      return displayNoCanteenFoundMessage(context);
    }
    return ListWidget(
      canteens: suggestion,
      addCanteenBloc: addCanteenBloc,
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListWidget(
      canteens: suggestion,
      addCanteenBloc: addCanteenBloc,
    );
  }
}
