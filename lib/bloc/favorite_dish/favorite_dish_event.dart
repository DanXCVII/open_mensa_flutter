import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/dish.dart';

abstract class FavoriteDishEvent extends Equatable {
  const FavoriteDishEvent();

  @override
  List<Object> get props => [];
}

class AddFavoriteDishEvent extends FavoriteDishEvent {}

class DeleteFavoriteDishEvent extends FavoriteDishEvent {}
