import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class MasterEvent extends Equatable {
  const MasterEvent();
}

class MAddCanteenEvent extends MasterEvent {
  final Canteen canteen;

  const MAddCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen event";
}

class MDeleteCanteenEvent extends MasterEvent {
  final Canteen canteen;

  const MDeleteCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete $canteen event";
}

class MAddFavoriteDishEvent extends MasterEvent {
  final Dish dish;

  const MAddFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites event";
}

class MDeleteFavoriteDishEvent extends MasterEvent {
  final Dish dish;

  const MDeleteFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites event";
}
