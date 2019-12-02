import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class CurrentDishesState extends Equatable {
  const CurrentDishesState();

  @override
  List<Object> get props => [];
}

class InitialCurrentDishesState extends CurrentDishesState {}

class LoadingCurrentDishesState extends CurrentDishesState {}

class NoDataToLoadState extends CurrentDishesState {
  @override
  String toString() => 'no canteen selected';
}

class LoadingCurrentDishesForCanteenState extends CurrentDishesState {
  final List<Canteen> availableCanteenList;
  final Canteen selectedCanteen;

  const LoadingCurrentDishesForCanteenState(
    this.availableCanteenList,
    this.selectedCanteen,
  );

  @override
  List<Object> get props => [
        availableCanteenList,
        selectedCanteen,
      ];

  @override
  String toString() => 'Loading currentDishes for canteen: $selectedCanteen';
}

class LoadedCurrentDishesState extends CurrentDishesState {
  final Map<int, List<Dish>> currentDishesList;
  final List<Canteen> availableCanteenList;
  final Canteen selectedCanteen;

  const LoadedCurrentDishesState(
    this.currentDishesList,
    this.availableCanteenList,
    this.selectedCanteen,
  );

  @override
  List<Object> get props => [
        currentDishesList,
        availableCanteenList,
        selectedCanteen,
      ];

  @override
  String toString() => 'Loaded currentDishes for index $selectedCanteen';
}
