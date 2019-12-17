import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';

abstract class AddCanteenState extends Equatable {
  const AddCanteenState();

  @override
  List<Object> get props => [];
}

class InitialAddCanteenState extends AddCanteenState {}

class LoadingCanteenOverview extends AddCanteenState {}

class LoadedCanteenOverview extends AddCanteenState {
  final List<Canteen> canteens;
  final List<Canteen> selectedCanteens;
  final bool refreshed;

  LoadedCanteenOverview([this.canteens, this.selectedCanteens, this.refreshed=false]);

  @override
  List<Object> get props => [canteens, selectedCanteens];

  @override
  String toString() =>
      "Loaded canteen overview : $canteens with user selected canteens: $selectedCanteens";
}
