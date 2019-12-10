import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class FavoriteDishesState extends Equatable {
  const FavoriteDishesState();

  @override
  List<Object> get props => [];
}

class InitialFavoriteDishesState extends FavoriteDishesState {}

class LoadingFavoriteDishesState extends FavoriteDishesState {}

class LoadedFavoriteDishes extends FavoriteDishesState {
  final List<Dish> favoriteDishes;

  LoadedFavoriteDishes([this.favoriteDishes]);

  @override
  List<Object> get props => [favoriteDishes];

  @override
  String toString() => "loaded favorite dishes $favoriteDishes";
}
