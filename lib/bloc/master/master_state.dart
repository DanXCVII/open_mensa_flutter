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

class MAddCanteenState extends MasterState {
  final Canteen canteen;

  const MAddCanteenState(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen";
}

class MDeleteCanteenState extends MasterState {
  final Canteen canteen;

  const MDeleteCanteenState(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete state $canteen state";
}

class MAddFavoriteDishState extends MasterState {
  final Dish dish;

  MAddFavoriteDishState(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites state";
}

class MDeleteFavoriteDishState extends MasterState {
  final Dish dish;

  const MDeleteFavoriteDishState(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites state";
}
