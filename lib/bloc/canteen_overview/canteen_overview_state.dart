import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';

abstract class CanteenOverviewState extends Equatable {
  const CanteenOverviewState();

  @override
  List<Object> get props => [];
}

class InitialCanteenOverviewState extends CanteenOverviewState {}

class LoadingCanteenOverviewState extends CanteenOverviewState {}

class LoadedCanteenOverviewState extends CanteenOverviewState {
  final List<Canteen> selectedCanteens;

  LoadedCanteenOverviewState([this.selectedCanteens]);

  @override
  List<Object> get props => [this.selectedCanteens];

  @override
  String toString() =>
      'Loaded selectedCanteenOverview with canteens: $selectedCanteens';
}
