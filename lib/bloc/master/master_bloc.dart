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
    if (event is AddCanteenEvent) {
      yield* _mapAddCanteenEventToState(event);
    } else if (event is DeleteCanteenEvent) {
      yield* _mapDeleteCanteenEventToState(event);
    } else if (event is AddFavoriteDishEvent) {
      yield* _mapAddFavouriteDishEventToState(event);
    } else if (event is DeleteFavoriteDishEvent) {
      yield* _mapDeleteFavouriteDishEventToState(event);
    }
  }

  Stream<MasterState> _mapAddCanteenEventToState(AddCanteenEvent event) async* {
    await HiveProvider().addSelectedCanteen(event.canteen);

    yield AddCanteenState(event.canteen);
  }

  Stream<MasterState> _mapDeleteCanteenEventToState(
      DeleteCanteenEvent event) async* {
    await HiveProvider().deleteCachedDataFromCanteen(event.canteen);

    yield DeleteCanteenState(event.canteen);
  }

  Stream<MasterState> _mapAddFavouriteDishEventToState(
      AddFavoriteDishEvent event) async* {
    HiveProvider().addFavoriteDish(event.dish);

    yield AddFavoriteDishState(event.dish);
  }

  Stream<MasterState> _mapDeleteFavouriteDishEventToState(
      DeleteFavoriteDishEvent event) async* {
    HiveProvider().deleteFavoriteDish(event.dish);

    yield DeleteFavoriteDishState(event.dish);
  }
}
