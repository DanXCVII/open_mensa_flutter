import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_state.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/fetch_data.dart';
import 'package:open_mensa_flutter/generated/i18n.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import './current_dishes.dart';

class CurrentDishesBloc extends Bloc<CurrentDishesEvent, CurrentDishesState> {
  final MasterBloc masterBloc;
  StreamSubscription masterListener;

  CurrentDishesBloc(this.masterBloc) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedCurrentDishesState) {
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

    if (selectedCanteen != null) {
      Map<DateTime, List<Dish>> dishes =
          await getDishesOfCanteen(selectedCanteen);
      currentDishes = _getWeekDayMap(dishes);
    }

    yield LoadedCurrentDishesState(currentDishes, canteens, selectedCanteen);
  }

  Stream<CurrentDishesState> _mapAddCanteenEventToState(
      AddCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      yield LoadedCurrentDishesState(
        (state as LoadedCurrentDishesState).currentDishesList,
        (state as LoadedCurrentDishesState).availableCanteenList
          ..add(event.canteen),

        /// if we haven't selected any canteen, we set the newly added canteen
        /// as currently selected one
        (state as LoadedCurrentDishesState).selectedCanteen == null
            ? event.canteen
            : (state as LoadedCurrentDishesState).selectedCanteen,
      );
    }
  }

  Stream<CurrentDishesState> _mapDeleteCanteenEventToState(
      DeleteCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      final Canteen previousSelectedCanteen =
          (state as LoadedCurrentDishesState).selectedCanteen;
      final List<Canteen> newCanteenList = (state as LoadedCurrentDishesState)
          .availableCanteenList
        ..remove(event.canteen);
      Map<int, List<Dish>> currentDishes = {};

      Canteen selectedCanteen;
      // if the selected canteen is equal to the deleted canteen ..
      if (previousSelectedCanteen == event.canteen) {
        // .. check if the canteenlist without the deleted canteen is not empty
        if (newCanteenList.isNotEmpty) {
          /// and set the first canteen of the other canteens to the selected canteens
          HiveProvider().setCurrentSelectedCanteen(newCanteenList.first);
          selectedCanteen = newCanteenList.first;
          Map<DateTime, List<Dish>> dishes =
              await getDishesOfCanteen(selectedCanteen);
          currentDishes = _getWeekDayMap(dishes);
        } else {
          // if we have no canteens anymore, set the selected canteen to null
          HiveProvider().setCurrentSelectedCanteen(null);
          yield NoDataToLoadState();
          return;
        }
      } else {
        // if the deleted canteen is not equal to the selected canteen
        selectedCanteen = previousSelectedCanteen;
        currentDishes = (state as LoadedCurrentDishesState).currentDishesList;
      }

      yield LoadedCurrentDishesState(
        currentDishes,
        newCanteenList,
        selectedCanteen,
      );
    }
  }

  Stream<CurrentDishesState> _mapChangeSelectedCanteenEventToState(
      ChangeSelectedCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      yield LoadingCurrentDishesForCanteenState(
        (state as LoadedCurrentDishesState).availableCanteenList,
        event.canteen,
      );

      await HiveProvider().setCurrentSelectedCanteen(event.canteen);

      Map<DateTime, List<Dish>> dishes =
          await getDishesOfCanteen(event.canteen);
      Map<int, List<Dish>> currentDishes = _getWeekDayMap(dishes);

      yield LoadedCurrentDishesState(
        currentDishes,
        (state as LoadedCurrentDishesState).availableCanteenList,
        event.canteen,
      );
    }
  }

  /// gets the dishes out of the hive database or network depending on whether current
  /// data is cached or not. If it is not cached, it caches the fetched data in hive.
  /// if cached data of the canteen in hive is outdated, it deletes it
  Future<Map<DateTime, List<Dish>>> getDishesOfCanteen(Canteen canteen) async {
    DateTime latestDate = HiveProvider().getDateOfLatestDish(canteen);
    if (latestDate != null) {
      if (latestDate.day == DateTime.now().day &&
          latestDate.month == DateTime.now().month &&
          latestDate.year == DateTime.now().year) {
        return HiveProvider().getCachedDataOfCanteen(canteen);
      } else {
        HiveProvider().deleteCachedDataFromCanteen(canteen);
        Map<DateTime, List<Dish>> currentDishes = await fetchMeals(canteen.id);
        await HiveProvider().cacheDataOfCanteen(canteen, currentDishes);
        return currentDishes;
      }
    } else {
      Map<DateTime, List<Dish>> currentDishes = await fetchMeals(canteen.id);
      await HiveProvider().cacheDataOfCanteen(canteen, currentDishes);

      return currentDishes;
    }
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
    masterListener.cancel();
    super.close();
  }
}
