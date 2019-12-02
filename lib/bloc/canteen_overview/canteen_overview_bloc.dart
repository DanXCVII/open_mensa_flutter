import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_state.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import './canteen_overview.dart';

class CanteenOverviewBloc
    extends Bloc<CanteenOverviewEvent, CanteenOverviewState> {
  MasterBloc masterBloc;
  StreamSubscription masterListener;

  CanteenOverviewBloc(this.masterBloc) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedCanteenOverviewState) {
        if (masterState is MAddCanteenState) {
          add(COAddCanteenEvent(masterState.canteen));
        } else if (masterState is MDeleteCanteenState) {
          add(CODeleteCanteenEvent(masterState.canteen));
        }
      }
    });
  }

  @override
  CanteenOverviewState get initialState => InitialCanteenOverviewState();

  @override
  Stream<CanteenOverviewState> mapEventToState(
    CanteenOverviewEvent event,
  ) async* {
    if (event is LoadCanteenOverviewEvent) {
      yield* _mapLoadCanteenOverviewEventToState(event);
    } else if (event is COAddCanteenEvent) {
      yield* _mapCOAddCanteenEventToState(event);
    } else if (event is CODeleteCanteenEvent) {
      yield* _mapCODeleteCanteenEventToState(event);
    }
  }

  Stream<CanteenOverviewState> _mapLoadCanteenOverviewEventToState(
      LoadCanteenOverviewEvent event) async* {
    final List<Canteen> selectedCanteens = HiveProvider().getSelectedCanteens();

    yield LoadedCanteenOverviewState(selectedCanteens);
  }

  Stream<CanteenOverviewState> _mapCOAddCanteenEventToState(
      COAddCanteenEvent event) async* {
    if (state is LoadedCanteenOverviewState) {
      yield LoadedCanteenOverviewState(
          (state as LoadedCanteenOverviewState).selectedCanteens
            ..add(event.canteen));
    }
  }

  Stream<CanteenOverviewState> _mapCODeleteCanteenEventToState(
      CODeleteCanteenEvent event) async* {
    if (state is LoadedCanteenOverviewState) {
      yield LoadedCanteenOverviewState(
          (state as LoadedCanteenOverviewState).selectedCanteens
            ..remove(event.canteen));
    }
  }

  @override
  void close() {
    masterListener.cancel();
    super.close();
  }
}
