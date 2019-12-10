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
    } else if (event is MAddFavoriteDishEvent) {
      yield* _mapAddFavouriteDishEventToState(event);
    } else if (event is MDeleteFavoriteDishEvent) {
      yield* _mapDeleteFavouriteDishEventToState(event);
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

  Stream<MasterState> _mapAddFavouriteDishEventToState(
      MAddFavoriteDishEvent event) async* {
    HiveProvider().addFavoriteDish(event.dish);

    yield MAddFavoriteDishState(event.dish);
  }

  Stream<MasterState> _mapDeleteFavouriteDishEventToState(
      MDeleteFavoriteDishEvent event) async* {
    HiveProvider().deleteFavoriteDish(event.dish);

    yield MDeleteFavoriteDishState(event.dish);
  }
}
