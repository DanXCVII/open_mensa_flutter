import 'dart:async';
import 'package:bloc/bloc.dart';
import './master.dart';

class MasterBloc extends Bloc<MasterEvent, MasterState> {
  @override
  MasterState get initialState => InitialMasterState();

  @override
  Stream<MasterState> mapEventToState(
    MasterEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
