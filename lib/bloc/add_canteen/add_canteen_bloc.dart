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
  AddCanteenState get initialState => LoadingCanteenOverview();

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
    List<Canteen> canteens = await fetchAllCanteens();
    List<Canteen> selectedCanteens = HiveProvider().getSelectedCanteens();
    print(
        'fetched canteens: $canteens and selectedCanteens: $selectedCanteens');

    yield LoadedCanteenOverview(canteens, selectedCanteens);
  }

  Stream<AddCanteenState> _mapSelectCanteenToState(
      SelectCanteenEvent event) async* {
    if (state is LoadedCanteenOverview) {
      if (event.selected) {
        final List<Canteen> selectedCanteens = List<Canteen>.from(
            (state as LoadedCanteenOverview).selectedCanteens)
          ..add(event.canteen);
        masterBloc.add(MAddCanteenEvent(event.canteen));

        yield LoadedCanteenOverview(
          (state as LoadedCanteenOverview).canteens,
          selectedCanteens,
        );
      } else {
        masterBloc.add(MDeleteCanteenEvent(event.canteen));
        final List<Canteen> selectedCanteens = List<Canteen>.from(
            (state as LoadedCanteenOverview).selectedCanteens)
          ..remove(event.canteen);

        yield LoadedCanteenOverview(
          (state as LoadedCanteenOverview).canteens,
          selectedCanteens,
        );
      }
    }
  }
}
