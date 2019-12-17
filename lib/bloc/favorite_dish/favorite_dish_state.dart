import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/dish_card.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class FavoriteDishState extends Equatable {
  const FavoriteDishState();

  @override
  List<Object> get props => [];
}

class LoadingRatedState extends FavoriteDishState {}

class LoadedRatedState extends FavoriteDishState {
  final DishRated ratedState;

  const LoadedRatedState(this.ratedState);

  @override
  List<Object> get props => [ratedState];
}
