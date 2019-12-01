import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/fetch_data.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';
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

  Stream<CurrentDishesState> _mapInitializeDataEventToState(
      InitializeDataEvent event) async* {
    final List<Canteen> canteens = HiveProvider().getSelectedCanteens();
    final Canteen selectedCanteen = HiveProvider().getCurrentCanteen();
    Map<DateTime, List<Dish>> currentDishes = {};

    if (selectedCanteen != null) {
      DateTime latestDate = HiveProvider().getDateOfLatestDish(selectedCanteen);
      if (latestDate != null) {
        if (latestDate.day == DateTime.now().day &&
            latestDate.month == DateTime.now().month &&
            latestDate.year == DateTime.now().year) {
          currentDishes =
              HiveProvider().getCachedDataOfCanteen(selectedCanteen);
        } else {
          HiveProvider().deleteCachedDataFromCanteen(selectedCanteen);
          currentDishes = await fetchMeals(selectedCanteen.id);
        }
      } else {
        currentDishes = await fetchMeals(selectedCanteen.id);
      }
    }

    yield LoadedCurrentDishesState(currentDishes, canteens, selectedCanteen);
  }

  Stream<CurrentDishesState> _mapAddcanteenEventToState(
      AddCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      yield LoadedCurrentDishesState(
        (state as LoadedCurrentDishesState).currentDishesList,
        (state as LoadedCurrentDishesState).availableCanteenList
          ..add(event.canteen),
        (state as LoadedCurrentDishesState).selectedCanteen,
      );
    }
  }

  Stream<CurrentDishesState> _mapDeleteCanteenEventToState(
      DeleteCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      yield LoadedCurrentDishesState(
        (state as LoadedCurrentDishesState).currentDishesList,
        (state as LoadedCurrentDishesState).availableCanteenList
          ..remove(event.canteen),
        (state as LoadedCurrentDishesState).selectedCanteen,
      );
    }
  }

  Stream<CurrentDishesState> _mapAddFavouriteDishEventToState(
      AddFavoriteDishEvent event) async* {}

  Stream<CurrentDishesState> _mapDeleteFavouriteDishEventToState(
      DeleteFavoriteDishEvent event) async* {}
}
