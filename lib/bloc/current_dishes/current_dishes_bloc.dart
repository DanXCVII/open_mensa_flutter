import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_state.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/fetch_data.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import './current_dishes.dart';

class CurrentdishesBloc extends Bloc<CurrentDishesEvent, CurrentDishesState> {
  final MasterBloc masterBloc;
  StreamSubscription masterListener;

  CurrentdishesBloc(this.masterBloc) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedCurrentDishesState) {
        if (masterState is DeleteCanteenState) {
          add(DeleteCanteenEvent(masterState.canteen));
        } else if (masterState is AddCanteenState) {
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
    Map<DateTime, List<Dish>> currentDishes = {};

    if (selectedCanteen != null) {
      currentDishes = await getDishesOfCanteen(selectedCanteen);
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
      Map<DateTime, List<Dish>> currentDishes = {};

      Canteen selectedCanteen;
      if (previousSelectedCanteen == event.canteen) {
        if (newCanteenList.isNotEmpty) {
          HiveProvider().setCurrentSelectedCanteen(newCanteenList.first);
          selectedCanteen = newCanteenList.first;
          currentDishes = await getDishesOfCanteen(selectedCanteen);
        }
      } else {
        await HiveProvider().setCurrentSelectedCanteen(previousSelectedCanteen);
        selectedCanteen = previousSelectedCanteen;
        currentDishes = (state as LoadedCurrentDishesState).currentDishesList;
      }

      if (state is LoadedCurrentDishesState) {
        yield LoadedCurrentDishesState(
          currentDishes,
          newCanteenList,
          selectedCanteen,
        );
      }
    }
  }

  Stream<CurrentDishesState> _mapChangeSelectedCanteenEventToState(
      ChangeSelectedCanteenEvent event) async* {
    if (state is LoadedCurrentDishesState) {
      await HiveProvider().setCurrentSelectedCanteen(event.canteen);

      yield LoadedCurrentDishesState(
        (state as LoadedCurrentDishesState).currentDishesList,
        (state as LoadedCurrentDishesState).availableCanteenList,
        event.canteen,
      );
    }
  }

  Future<Map<DateTime, List<Dish>>> getDishesOfCanteen(Canteen canteen) async {
    DateTime latestDate = HiveProvider().getDateOfLatestDish(canteen);
    if (latestDate != null) {
      if (latestDate.day == DateTime.now().day &&
          latestDate.month == DateTime.now().month &&
          latestDate.year == DateTime.now().year) {
        return HiveProvider().getCachedDataOfCanteen(canteen);
      } else {
        HiveProvider().deleteCachedDataFromCanteen(canteen);
        return await fetchMeals(canteen.id);
      }
    } else {
      return await fetchMeals(canteen.id);
    }
  }

  @override
  void close() {
    masterListener.cancel();
    super.close();
  }
}
