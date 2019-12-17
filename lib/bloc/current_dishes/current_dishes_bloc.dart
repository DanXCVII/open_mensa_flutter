import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/favorite_dish/favorite_dish.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_state.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/fetch_data.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import './current_dishes.dart';

class CurrentDishesBloc extends Bloc<CurrentDishesEvent, CurrentDishesState> {
  final MasterBloc masterBloc;
  StreamSubscription masterListener;

  CurrentDishesBloc(this.masterBloc) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedCurrentDishesState || state is NoDataToLoadState) {
        if (masterState is MDeleteCanteenState) {
          add(DeleteCanteenEvent(masterState.canteen));
        } else if (masterState is MAddCanteenState) {
          add(AddCanteenEvent(masterState.canteen));
        }
      }
    });
  }

  @override
  CurrentDishesState get initialState => InitialCurrentDishesState();

  @override
  Stream<CurrentDishesState> mapEventToState(
    CurrentDishesEvent event,
  ) async* {
    if (event is InitializeDataEvent) {
      yield* _mapInitializeDataEventToState(event);
    } else if (event is AddCanteenEvent) {
      yield* _mapAddCanteenEventToState(event);
    } else if (event is DeleteCanteenEvent) {
      yield* _mapDeleteCanteenEventToState(event);
    } else if (event is ChangeSelectedCanteenEvent) {
      yield* _mapChangeSelectedCanteenEventToState(event);
    }
  }

  Stream<CurrentDishesState> _mapInitializeDataEventToState(
      InitializeDataEvent event) async* {
    final List<Canteen> canteens = HiveProvider().getSelectedCanteens();
    final Canteen selectedCanteen = HiveProvider().getCurrentCanteen();
    Map<int, List<Dish>> currentDishes = {};
    Map<Dish, FavoriteDishBloc> favoriteDishBlocs = {};

    if (selectedCanteen != null) {
      Map<DateTime, List<Dish>> dishes =
          await getDishesOfCanteen(selectedCanteen);
      if (dishes == null) {
        yield NoInternetConnectionState(
          canteens,
          selectedCanteen,
        );
        return;
      }
      currentDishes = _getWeekDayMap(dishes);
      favoriteDishBlocs = _getFavoriteDishBlocs(currentDishes);
    }
    if (selectedCanteen == null) {
      yield NoDataToLoadState();
    } else {
      yield LoadedCurrentDishesState(
        currentDishes,
        favoriteDishBlocs,
        canteens,
        selectedCanteen,
      );
    }
  }

  Stream<CurrentDishesState> _mapAddCanteenEventToState(
      AddCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      yield LoadedCurrentDishesState(
        (state as LoadedCurrentDishesState).currentDishesList,
        (state as LoadedCurrentDishesState).favoriteBlocs,
        List<Canteen>.from(
            (state as LoadedCurrentDishesState).availableCanteenList)
          ..add(event.canteen),
        (state as LoadedCurrentDishesState).selectedCanteen,
      );
    } else if (state is NoDataToLoadState) {
      add(InitializeDataEvent());
    }
  }

  Stream<CurrentDishesState> _mapDeleteCanteenEventToState(
      DeleteCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      final Canteen previousSelectedCanteen =
          (state as LoadedCurrentDishesState).selectedCanteen;
      final List<Canteen> newCanteenList = List<Canteen>.from(
          (state as LoadedCurrentDishesState).availableCanteenList)
        ..remove(event.canteen);
      Map<int, List<Dish>> currentDishes = {};
      Map<Dish, FavoriteDishBloc> favoriteDishBlocs = {};

      Canteen selectedCanteen;
      // if the selected canteen is equal to the deleted canteen ..
      if (previousSelectedCanteen == event.canteen) {
        // .. check if the canteenlist without the deleted canteen is not empty
        if (newCanteenList.isNotEmpty) {
          /// and set the first canteen of the other canteens to the selected canteens
          await HiveProvider().setCurrentSelectedCanteen(newCanteenList.first);
          selectedCanteen = newCanteenList.first;
          Map<DateTime, List<Dish>> dishes =
              await getDishesOfCanteen(newCanteenList.first);
          if (dishes == null) {
            yield NoInternetConnectionState(
              newCanteenList,
              event.canteen,
            );
            return;
          }
          currentDishes = _getWeekDayMap(dishes);
          favoriteDishBlocs = _getFavoriteDishBlocs(currentDishes);
        } else {
          // if we have no canteens anymore, delete the selected canteen
          await HiveProvider().deleteCurrentSelectedCanteen();
          yield NoDataToLoadState();
          return;
        }
      } else {
        // if the deleted canteen is not equal to the selected canteen
        selectedCanteen = previousSelectedCanteen;
        currentDishes = (state as LoadedCurrentDishesState).currentDishesList;
        favoriteDishBlocs = (state as LoadedCurrentDishesState).favoriteBlocs;
      }

      yield LoadedCurrentDishesState(
        currentDishes,
        favoriteDishBlocs,
        newCanteenList,
        selectedCanteen,
      );
    }
  }

  Stream<CurrentDishesState> _mapChangeSelectedCanteenEventToState(
      ChangeSelectedCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      List<Canteen> availabeCanteenList =
          (state as LoadedCurrentDishesState).availableCanteenList;

      yield LoadingCurrentDishesForCanteenState(
        (state as LoadedCurrentDishesState).availableCanteenList,
        event.canteen,
      );

      await HiveProvider().setCurrentSelectedCanteen(event.canteen);

      Map<DateTime, List<Dish>> dishes =
          await getDishesOfCanteen(event.canteen);
      if (dishes == null) {
        yield NoInternetConnectionState(
          availabeCanteenList,
          event.canteen,
        );
        return;
      }
      Map<int, List<Dish>> currentDishes = _getWeekDayMap(dishes);
      Map<Dish, FavoriteDishBloc> favoriteDishBlocs =
          _getFavoriteDishBlocs(currentDishes);

      yield LoadedCurrentDishesState(
        currentDishes,
        favoriteDishBlocs,
        availabeCanteenList,
        event.canteen,
      );
    }
  }

  /// gets the dishes out of the hive database or network depending on whether current
  /// data is cached or not. If it is not cached, it caches the fetched data in hive.
  /// if cached data of the canteen in hive is outdated, it deletes it
  Future<Map<DateTime, List<Dish>>> getDishesOfCanteen(Canteen canteen) async {
    List<DateTime> dateRange = HiveProvider().getDateRangeOfCache(canteen);
    DateTime today = DateTime.now();
    if (dateRange != null) {
      // dont fetch data again if the latest entry is today
      if (dateRange[0].day >= today.day &&
          dateRange[0].month >= today.month &&
          dateRange[0].year >= today.year) {
        return HiveProvider().getCachedDataOfCanteen(canteen);
      } else {
        // else fetch the data: data is thus refreshed once every day
        Map<DateTime, List<Dish>> currentDishes = await fetchMeals(canteen.id);
        // no connection or other error: check if 'today' is included in the cash
        // if today is not included, delete the old data from the db and return null
        if (currentDishes == null &&
            dateRange[1].day >= today.day &&
            dateRange[1].month >= today.month &&
            dateRange[1].year >= today.year) {
          // if not remove the older entries
          return HiveProvider().getCachedDataOfCanteen(canteen)
            ..removeWhere((k, v) =>
                k.day < today.day &&
                k.month <= today.month &&
                k.year <= today.year);
        }
        HiveProvider().deleteCachedDataFromCanteen(canteen);
        if (currentDishes == null) return null;
        await HiveProvider().cacheDataOfCanteen(canteen, currentDishes);
      }
    } else {
      Map<DateTime, List<Dish>> currentDishes = await fetchMeals(canteen.id);
      if (currentDishes == null) return null;
      await HiveProvider().cacheDataOfCanteen(canteen, currentDishes);

      return currentDishes;
    }
  }

  Map<Dish, FavoriteDishBloc> _getFavoriteDishBlocs(
      Map<int, List<Dish>> currentDishes) {
    Map<Dish, FavoriteDishBloc> output = {};

    for (int key in currentDishes.keys) {
      for (Dish dish in currentDishes[key]) {
        output.addAll({
          dish: FavoriteDishBloc(masterBloc, dish)
            ..add(InitializeDishEvent(dish))
        });
      }
    }

    return output;
  }

  Map<int, List<Dish>> _getWeekDayMap(Map<DateTime, List<Dish>> currentDishes) {
    Map<int, List<Dish>> weekDayMap = {};

    for (DateTime key in currentDishes.keys) {
      weekDayMap.addAll({key.weekday: currentDishes[key]});
    }

    return weekDayMap;
  }

  @override
  Future<void> close() async {
    print('current dishes bloc closed');
    masterListener.cancel();
    super.close();
  }
}
