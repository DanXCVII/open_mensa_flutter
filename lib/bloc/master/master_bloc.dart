import 'dart:async';
import 'package:bloc/bloc.dart';
import './master.dart';

class MasterBloc extends Bloc<MasterEvent, MasterState> {
  @override
  MasterState get initialState => InitialMasterState();

  @override
  Stream<MasterState> mapEventToState(
    MasterEvent event,
  ) async* {
    if (event is AddCanteenEvent) {
      yield* _mapAddcanteenEventToState(event);
    } else if (event is DeleteCanteenEvent) {
      yield* _mapDeleteCanteenEventToState(event);
    } else if (event is AddFavoriteDishEvent) {
      yield* _mapAddFavouriteDishEventToState(event);
    } else if (event is DeleteFavoriteDishEvent) {
      yield* _mapDeleteFavouriteDishEventToState(event);
    }
  }

  Stream<MasterState> _mapAddcanteenEventToState(AddCanteenEvent event) async* {
    
    yield AddCanteenState(event.canteen);
  }

  Stream<MasterState> _mapDeleteCanteenEventToState(DeleteCanteenEvent event) async* {
    
    yield DeleteCanteenState(event.canteen);
  }

  Stream<MasterState> _mapAddFavouriteDishEventToState(AddFavoriteDishEvent event) async* {
    
    yield AddFavoriteDishState(event.dish);
  }

  Stream<MasterState> _mapDeleteFavouriteDishEventToState(DeleteFavoriteDishEvent event) async* {
    
    yield DeleteFavoriteDishState(event.dish);
  }
}
