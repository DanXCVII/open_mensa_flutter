import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master.dart';
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
      final List<Canteen> selectedCanteens = List<Canteen>.from(
          (state as LoadedCanteenOverviewState).selectedCanteens)
        ..add(event.canteen);
      yield LoadedCanteenOverviewState(selectedCanteens);
    }
  }

  Stream<CanteenOverviewState> _mapCODeleteCanteenEventToState(
      CODeleteCanteenEvent event) async* {
    if (state is LoadedCanteenOverviewState) {
      yield LoadedCanteenOverviewState(List<Canteen>.from(
          (state as LoadedCanteenOverviewState).selectedCanteens)
        ..remove(event.canteen));
    }
  }

  @override
  Future<void> close() async {
    print('canteen overview bloc closed');
    masterListener.cancel();
    super.close();
  }
}
