import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import './master.dart';

class MasterBloc extends Bloc<MasterEvent, MasterState> {
  @override
  MasterState get initialState => InitialMasterState();

  @override
  Stream<MasterState> mapEventToState(
    MasterEvent event,
  ) async* {
    if (event is MAddCanteenEvent) {
      yield* _mapAddCanteenEventToState(event);
    } else if (event is MDeleteCanteenEvent) {
      yield* _mapDeleteCanteenEventToState(event);
    } else if (event is MChangeRatedEvent) {
      yield* _mapChangeRatedEventToState(event);
    }
  }

  Stream<MasterState> _mapAddCanteenEventToState(
      MAddCanteenEvent event) async* {
    await HiveProvider().addSelectedCanteen(event.canteen);
    if (HiveProvider().getCurrentCanteen() == null) {
      await HiveProvider().setCurrentSelectedCanteen(event.canteen);
    }

    yield MAddCanteenState(event.canteen);
  }

  Stream<MasterState> _mapDeleteCanteenEventToState(
      MDeleteCanteenEvent event) async* {
    await HiveProvider().deleteCachedDataFromCanteen(event.canteen);
    await HiveProvider().removeSelectedCanteen(event.canteen);

    yield MDeleteCanteenState(event.canteen);
  }

  Stream<MasterState> _mapChangeRatedEventToState(
      MChangeRatedEvent event) async* {
    await HiveProvider().changeRatedState(event.dish, event.ratedState);

    yield MChangeRatedState(
      event.dish,
      event.ratedState,
    );
  }

  @override
  Future<void> close() {
    print('closed master bloc');
    return super.close();
  }
}
