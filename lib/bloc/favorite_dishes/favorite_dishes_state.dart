import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/bloc/favorite_dish/favorite_dish_bloc.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class FavoriteDishesState extends Equatable {
  const FavoriteDishesState();

  @override
  List<Object> get props => [];
}

class InitialFavoriteDishesState extends FavoriteDishesState {}

class LoadingFavoriteDishesState extends FavoriteDishesState {}

class LoadedFavoriteDishes extends FavoriteDishesState {
  final List<Dish> dislikedDishes;
  final List<Dish> likedDishes;
  final List<Dish> favoriteDishes;
  final Map<Dish, FavoriteDishBloc> favoriteDishBlocs;

  LoadedFavoriteDishes([
    this.dislikedDishes,
    this.likedDishes,
    this.favoriteDishes,
    this.favoriteDishBlocs,
  ]);

  @override
  List<Object> get props => [
        dislikedDishes,
        likedDishes,
        favoriteDishes,
      ];

  @override
  String toString() => "loaded favorite dishes $favoriteDishes";
}
