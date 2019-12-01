import 'package:equatable/equatable.dart';

abstract class MasterState extends Equatable {
  const MasterState();
}

class InitialMasterState extends MasterState {
  @override
  List<Object> get props => [];
}
