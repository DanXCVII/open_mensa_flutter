import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_state.dart';
import './favorite_dish.dart';

class FavoritedishBloc extends Bloc<FavoriteDishEvent, FavoriteDishState> {
  MasterBloc masterBloc;
  StreamSubscription masterListener;

  FavoritedishBloc(this.masterBloc) {
    masterListener = masterBloc.listen((state) {
      if (state is MAddFavoriteDishState) {
        add(AddFavoriteDishEvent());
      } else if (state is MDeleteFavoriteDishState) {
        add(DeleteFavoriteDishEvent());
      }
    });
  }

  @override
  FavoriteDishState get initialState => InitialFavoriteDishState();

  @override
  Stream<FavoriteDishState> mapEventToState(
    FavoriteDishEvent event,
  ) async* {
    if (state is AddFavoriteDishEvent) {
      _mapAddFavouriteDishEventToState(event);
    } else if (state is DeleteFavoriteDishEvent) {
      _mapDeleteFavouriteDishEventToState(event);
    }
  }

  Stream<FavoriteDishState> _mapAddFavouriteDishEventToState(
      AddFavoriteDishEvent event) async* {
    yield IsFavoriteDishState();
  }

  Stream<FavoriteDishState> _mapDeleteFavouriteDishEventToState(
      DeleteFavoriteDishEvent event) async* {
    yield IsNotFavoriteDishState();
  }

  @override
  Future<void> close() async {
    masterListener.cancel();
    super.close();
  }
}
