import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class CurrentDishesEvent extends Equatable {
  const CurrentDishesEvent();
}


class InitializeDataEvent extends CurrentDishesEvent{
  @override
  List<Object> get props => [];

  @override
  String toString() => 'initializes currentDishes Data';
}

class AddCanteenEvent extends CurrentDishesEvent {
  final Canteen canteen;

  const AddCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen event";
}

class DeleteCanteenEvent extends CurrentDishesEvent {
  final Canteen canteen;

  const DeleteCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete $canteen event";
}

class AddFavoriteDishEvent extends CurrentDishesEvent {
  final Dish dish;

  const AddFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites event";
}

class DeleteFavoriteDishEvent extends CurrentDishesEvent {
  final Dish dish;

  const DeleteFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites event";
}
