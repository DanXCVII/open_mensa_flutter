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
}

class MDeleteCanteenState extends MasterState {
  final Canteen canteen;

  const MDeleteCanteenState(this.canteen);

  @override
  List<Object> get props => [canteen];
}

class MChangeRatedState extends MasterState {
  final DishRated ratedState;
  final Dish dish;

  MChangeRatedState(
    this.dish,
    this.ratedState,
  );

  @override
  List<Object> get props => [
        dish,
        ratedState,
      ];
}
