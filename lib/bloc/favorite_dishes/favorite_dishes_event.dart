import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class FavoriteDishesEvent extends Equatable {
  const FavoriteDishesEvent();
}

class FAddFavoriteDishEvent extends FavoriteDishesEvent {
  final Dish dish;

  const FAddFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "add $dish from favourites event";
}

class FDeleteFavoriteDishEvent extends FavoriteDishesEvent {
  final Dish dish;

  const FDeleteFavoriteDishEvent(this.dish);

  @override
  List<Object> get props => [dish];

  @override
  String toString() => "delete $dish from favourites event";
}
