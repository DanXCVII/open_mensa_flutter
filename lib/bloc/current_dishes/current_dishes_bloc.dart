import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class CurrentdishesBloc extends Bloc<CurrentdishesEvent, CurrentdishesState> {
  @override
  CurrentdishesState get initialState => InitialCurrentdishesState();

  @override
  Stream<CurrentdishesState> mapEventToState(
    CurrentdishesEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
