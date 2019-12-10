import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_event.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/fetch_canteens.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import './add_canteen.dart';

class AddCanteenBloc extends Bloc<AddCanteenEvent, AddCanteenState> {
  MasterBloc masterBloc;

  AddCanteenBloc(this.masterBloc);

  @override
  AddCanteenState get initialState => InitialAddCanteenState();

  @override
  Stream<AddCanteenState> mapEventToState(
    AddCanteenEvent event,
  ) async* {
    if (event is LoadCanteenOverview) {
      yield* _mapLoadCanteenOverviewToState(event);
    } else if (event is SelectCanteenEvent) {
      yield* _mapSelectCanteenToState(event);
    }
  }

  Stream<AddCanteenState> _mapLoadCanteenOverviewToState(
      LoadCanteenOverview event) async* {
    yield LoadingCanteenOverview();

    List<Canteen> canteens = await fetchAllCanteens();
    List<Canteen> selectedCanteens = HiveProvider().getSelectedCanteens();

    yield LoadedCanteenOverview(canteens, selectedCanteens);
  }

  Stream<AddCanteenState> _mapSelectCanteenToState(SelectCanteenEvent event) async* {
    if (state is LoadedCanteenOverview) {
      List<Canteen> selectedCanteens =
          (state as LoadedCanteenOverview).selectedCanteens;
      if (event.selected) {
        selectedCanteens.add(event.canteen);
        masterBloc.add(MAddCanteenEvent(event.canteen));
      } else {
        masterBloc.add(MDeleteCanteenEvent(event.canteen));
        selectedCanteens.remove(event.canteen);
      }

      yield LoadedCanteenOverview(
        (state as LoadedCanteenOverview).canteens,
        selectedCanteens,
      );
    }
  }
}
