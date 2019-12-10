import 'package:equatable/equatable.dart';

abstract class FavoriteDishEvent extends Equatable {
  const FavoriteDishEvent();

  @override
  List<Object> get props => [];
}

class AddFavoriteDishEvent extends FavoriteDishEvent {}

class DeleteFavoriteDishEvent extends FavoriteDishEvent {}
