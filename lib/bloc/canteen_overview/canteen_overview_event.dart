import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';

abstract class CanteenOverviewEvent extends Equatable {
  const CanteenOverviewEvent();

  @override
  List<Object> get props => [];
}

class LoadCanteenOverviewEvent extends CanteenOverviewEvent {}

class COAddCanteenEvent extends CanteenOverviewEvent {
  final Canteen canteen;

  const COAddCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "add $canteen event";
}

class CODeleteCanteenEvent extends CanteenOverviewEvent {
  final Canteen canteen;

  const CODeleteCanteenEvent(this.canteen);

  @override
  List<Object> get props => [canteen];

  @override
  String toString() => "delete $canteen event";
}
