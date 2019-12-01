import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class MasterEvent extends Equatable {
  const MasterEvent();
}

class AddCanteen extends MasterEvent{
  final Canteen canteen;

  const AddCanteen(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen";
}

class DeleteCanteen extends MasterEvent{
  final Canteen canteen;

  const DeleteCanteen(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete $canteen";
}

class AddFavouriteDish extends MasterEvent{
  final Dish dish;

  const AddFavouriteDish(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites";
}

class DeleteFavouriteDish extends MasterEvent{
  final Dish dish;

  const DeleteFavouriteDish(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites";
}