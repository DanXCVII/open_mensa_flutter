import 'package:equatable/equatable.dart';
import 'package:open_mensa_flutter/models/canteen.dart';

abstract class AddCanteenEvent extends Equatable {
  const AddCanteenEvent();
}

class LoadCanteenOverview extends AddCanteenEvent {
  final bool refresh;
  const LoadCanteenOverview(
    {this.refresh = false}
  );

  @override
  List<Object> get props => [];
}


class RefreshAvailableCanteensEvent extends AddCanteenEvent {
  @override
  List<Object> get props => [];
}

class SelectCanteenEvent extends AddCanteenEvent {
  final Canteen canteen;
  final bool selected;

  const SelectCanteenEvent(
    this.canteen,
    this.selected,
  );

  @override
  List<Object> get props => [canteen, selected];

  @override
  String toString() => "add $canteen event with status $selected";
}
