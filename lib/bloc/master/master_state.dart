import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class MasterState extends Equatable {
  const MasterState();
}

class InitialMasterState extends MasterState {
  @override
  List<Object> get props => [];
}

class AddCanteenState extends MasterState {
  final Canteen canteen;

  const AddCanteenState(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen";
}

class DeleteCanteenState extends MasterState {
  final Canteen canteen;

  const DeleteCanteenState(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete state $canteen state";
}

class AddFavoriteDishState extends MasterState {
  final Dish dish;

  AddFavoriteDishState(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites state";
}

class DeleteFavoriteDishState extends MasterState {
  final Dish dish;

  const DeleteFavoriteDishState(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites state";
}
