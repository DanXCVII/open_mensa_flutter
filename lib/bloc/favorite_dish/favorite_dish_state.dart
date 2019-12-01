import 'package:equatable/equatable.dart';

abstract class FavoritedishState extends Equatable {
  const FavoritedishState();

  @override
  List<Object> get props => [];
}

class InitialFavoritedishState extends FavoritedishState {}

class IsFavoriteDishState extends FavoritedishState {}

class IsNotFavoriteDishState extends FavoritedishState {}
