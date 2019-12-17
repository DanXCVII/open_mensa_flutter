import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/dish_card.dart';
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
}

class MDeleteCanteenEvent extends MasterEvent {
  final Canteen canteen;

  const MDeleteCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];
}

class MChangeRatedEvent extends MasterEvent {
  final DishRated ratedState;
  final Dish dish;

  const MChangeRatedEvent(
    this.dish,
    this.ratedState,
  );

  @override
  List<Object> get props => [
        dish,
        ratedState,
      ];
}
