import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class MasterEvent extends Equatable {
  const MasterEvent();
}

class AddCanteenEvent extends MasterEvent {
  final Canteen canteen;

  const AddCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen event";
}

class DeleteCanteenEvent extends MasterEvent {
  final Canteen canteen;

  const DeleteCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete $canteen event";
}

class AddFavoriteDishEvent extends MasterEvent {
  final Dish dish;

  const AddFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites event";
}

class DeleteFavoriteDishEvent extends MasterEvent {
  final Dish dish;

  const DeleteFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites event";
}
