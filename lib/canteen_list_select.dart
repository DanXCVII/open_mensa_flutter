import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './generated/i18n.dart';
import 'bloc/add_canteen/add_canteen.dart';
import 'models/canteen.dart';

// creates a checkable list of all canteens
class CheckableCanteenList extends StatefulWidget {
  // Map which contains the selected location of the user.
  //final Map<String, double> latlng;

  CheckableCanteenList({Key key}) : super(key: key);

  @override
  CheckableCanteenListState createState() => CheckableCanteenListState();
}

class CheckableCanteenListState extends State<CheckableCanteenList> {
  //CheckableCanteenListState();

  @override
  build(BuildContext context) {
    // check if canteen list is empty, if it is serve a FutureBuilder while it loads
    return Container(
      child: BlocBuilder<AddCanteenBloc, AddCanteenState>(
          builder: (context, state) {
        if (state is LoadingCanteenOverview) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedCanteenOverview) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).select_canteens),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: S.of(context).search,
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CanteenSearch(
                          items: state.canteens,
                          selected: state.selectedCanteens),
                    );
                  },
                )
              ],
            ),
            body: ListWidget(
              items: state.canteens,
              selectedCanteens: state.selectedCanteens,
            ),
          );
        }
      }),
    );
  }
}

class ListWidget extends StatefulWidget {
  final List<Canteen> items;
  final List<Canteen> selectedCanteens;
  ListWidget({@required this.items, @required this.selectedCanteens});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ListWidgetState();
  }
}

class ListWidgetState extends State<ListWidget> {
  ListWidgetState();

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(child: displayNoCanteenFoundMessage(context));
    }
    return Container(
      child: createCheckedListView(widget.items
          .map((canteen) => CheckboxListTile(
                title: Text(canteen.name),
                value: widget.selectedCanteens.contains(canteen),
                onChanged: (bool value) {
                  BlocProvider.of<AddCanteenBloc>(context)
                      .add(SelectCanteenEvent(canteen, value));
                },
              ))
          .toList()),
    );
  }

  ListView createCheckedListView(List<CheckboxListTile> checkableCanteenList) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd && i < checkableCanteenList.length * 2) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index < checkableCanteenList.length) {
            return checkableCanteenList[index];
          }
          return null;
        });
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
  List<Canteen> selected = [];
  List<Canteen> suggestion = [];

  CanteenSearch({@required this.items, @required this.selected});

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
      items: suggestion,
      selectedCanteens: selected,
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
      items: suggestion,
      selectedCanteens: selected,
    );
  }
}
