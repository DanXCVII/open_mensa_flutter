import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import './bloc.dart';

class FavoriteDishesBloc
    extends Bloc<FavoriteDishesEvent, FavoriteDishesState> {
  MasterBloc masterBloc;
  StreamSubscription masterListener;

  FavoriteDishesBloc(this.masterBloc) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedFavoriteDishes) {
        if (masterState is MAddFavoriteDishState) {
          add(FAddFavoriteDishEvent(masterState.dish));
        } else if (masterState is MDeleteFavoriteDishEvent) {
          add(FDeleteFavoriteDishEvent(
              (masterState as MDeleteFavoriteDishEvent).dish));
        }
      }
    });
  }

  @override
  FavoriteDishesState get initialState => InitialFavoriteDishesState();

  @override
  Stream<FavoriteDishesState> mapEventToState(
    FavoriteDishesEvent event,
  ) async* {
    if (event is LoadFavoriteDishes) {
      yield* _mapLoadFavoriteDishesToState(event);
    } else if (event is FAddFavoriteDishEvent) {
      yield* _mapFAddFavoriteDishEventToState(event);
    } else if (event is FDeleteFavoriteDishEvent) {
      yield* _mapFDeleteFavoriteDishEventToState(event);
    }
  }

  Stream<FavoriteDishesState> _mapFAddFavoriteDishEventToState(
      FAddFavoriteDishEvent event) async* {
    if (state is LoadedFavoriteDishes) {
      yield LoadedFavoriteDishes(
          (state as LoadedFavoriteDishes).favoriteDishes..add(event.dish));
    }
  }

  Stream<FavoriteDishesState> _mapFDeleteFavoriteDishEventToState(
      FDeleteFavoriteDishEvent event) async* {
    if (state is LoadedFavoriteDishes) {
      yield LoadedFavoriteDishes(
          (state as LoadedFavoriteDishes).favoriteDishes..remove(event.dish));
    }
  }

  Stream<FavoriteDishesState> _mapLoadFavoriteDishesToState(
      FavoriteDishesEvent event) async* {
    final List<Dish> favoriteDishes = HiveProvider().getFavoriteDishes();

    yield LoadedFavoriteDishes(favoriteDishes);
  }

  @override
  void close() {
    masterListener.cancel();
    super.close();
  }
}
