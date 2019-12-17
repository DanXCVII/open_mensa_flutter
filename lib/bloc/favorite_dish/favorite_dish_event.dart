import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/dish.dart';

import '../../dish_card.dart';

abstract class FavoriteDishEvent extends Equatable {
  const FavoriteDishEvent();

  @override
  List<Object> get props => [];
}

class InitializeDishEvent extends FavoriteDishEvent {
  final Dish dish;

  const InitializeDishEvent(this.dish);

  @override
  List<Object> get props => [dish];
}

class ChangeRatedEvent extends FavoriteDishEvent {
  final DishRated ratedState;

  const ChangeRatedEvent(this.ratedState);

  @override
  List<Object> get props => [ratedState];
}
