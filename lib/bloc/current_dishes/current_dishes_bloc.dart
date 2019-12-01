import 'dart:async';
import 'package:bloc/bloc.dart';
import './current_dishes.dart';

class CurrentdishesBloc extends Bloc<CurrentDishesEvent, CurrentDishesState> {
  @override
  CurrentDishesState get initialState => InitialCurrentDishesState();

  @override
  Stream<CurrentDishesState> mapEventToState(
    CurrentDishesEvent event,
  ) async* {
    if (event is InitializeDataEvent) {
      yield* _mapInitializeDataEventToState(event);
    } else if (event is AddCanteenEvent) {
      yield* _mapAddcanteenEventToState(event);
    } else if (event is DeleteCanteenEvent) {
      yield* _mapDeleteCanteenEventToState(event);
    } else if (event is AddFavoriteDishEvent) {
      yield* _mapAddFavouriteDishEventToState(event);
    } else if (event is DeleteFavoriteDishEvent) {
      yield* _mapDeleteFavouriteDishEventToState(event);
    }
  }

  Stream<CurrentDishesState> _mapAddcanteenEventToState(
      AddCanteenEvent event) async* {}

  Stream<CurrentDishesState> _mapDeleteCanteenEventToState(
      DeleteCanteenEvent event) async* {}

  Stream<CurrentDishesState> _mapAddFavouriteDishEventToState(
      AddFavoriteDishEvent event) async* {}

  Stream<CurrentDishesState> _mapDeleteFavouriteDishEventToState(
      DeleteFavoriteDishEvent event) async* {}

  Stream<CurrentDishesState> _mapInitializeDataEventToState(InitializeDataEvent event) async* {
    
  }
}
