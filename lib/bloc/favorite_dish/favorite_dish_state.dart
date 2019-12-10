import 'package:equatable/equatable.dart';

abstract class FavoriteDishState extends Equatable {
  const FavoriteDishState();

  @override
  List<Object> get props => [];
}

class InitialFavoriteDishState extends FavoriteDishState {}

class IsFavoriteDishState extends FavoriteDishState {}

class IsNotFavoriteDishState extends FavoriteDishState {}
