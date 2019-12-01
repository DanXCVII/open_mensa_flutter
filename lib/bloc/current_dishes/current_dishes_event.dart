import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class CurrentDishesEvent extends Equatable {
  const CurrentDishesEvent();
}

class InitializeDataEvent extends CurrentDishesEvent {
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

class ChangeSelectedCanteenEvent extends CurrentDishesEvent {
  final Canteen canteen;

  const ChangeSelectedCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "change selected canteen to $canteen";
}
