import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/dish_card.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class FavoriteDishesEvent extends Equatable {
  const FavoriteDishesEvent();
}

class FLoadFavoriteDishesEvent extends FavoriteDishesEvent {
  @override
  // TODO: implement props
  List<Object> get props => [];

  @override
  String toString() => "loading favorite dishes";
}

class FChangeRatedEvent extends FavoriteDishesEvent {
  final DishRated ratedState;
  final Dish dish;

  const FChangeRatedEvent(
    this.dish,
    this.ratedState,
  );

  @override
  List<Object> get props => [
        dish,
        ratedState,
      ];
}
