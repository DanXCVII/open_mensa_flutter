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

class LoadedCurrentDishesState extends CurrentDishesState {
  final Map<int, List<Dish>> currentDishesList;
  final List<Canteen> availableCanteenList;
  final int selectedCanteenIndex;

  const LoadedCurrentDishesState(this.currentDishesList, this.availableCanteenList, this.selectedCanteenIndex);

  @override
  List<Object> get props => [ currentDishesList, availableCanteenList, selectedCanteenIndex];
}
