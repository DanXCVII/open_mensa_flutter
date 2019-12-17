import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master_state.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import './favorite_dish.dart';

class FavoriteDishBloc extends Bloc<FavoriteDishEvent, FavoriteDishState> {
  MasterBloc masterBloc;
  final Dish dish;
  StreamSubscription masterListener;

  FavoriteDishBloc(this.masterBloc, this.dish) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedRatedState) {
        if (masterState is MChangeRatedState) {
          if (masterState.dish == dish) {
            add(ChangeRatedEvent(masterState.ratedState));
          }
        }
      }
    });
  }

  @override
  FavoriteDishState get initialState => LoadingRatedState();

  @override
  Stream<FavoriteDishState> mapEventToState(
    FavoriteDishEvent event,
  ) async* {
    if (event is InitializeDishEvent) {
      yield* _mapInitializeDishEventToState(event);
    } else if (event is ChangeRatedEvent) {
      yield* _mapChangeRatedEventToState(event);
    }
  }

  Stream<FavoriteDishState> _mapInitializeDishEventToState(
      InitializeDishEvent event) async* {
    if (HiveProvider().getDislikedDishes().contains(dish)) {
      yield LoadedRatedState(DishRated.Disliked);
    } else if (HiveProvider().getLikedDishes().contains(dish)) {
      yield LoadedRatedState(DishRated.Liked);
    } else if (HiveProvider().getFavoriteDishes().contains(dish)) {
      yield LoadedRatedState(DishRated.Favorite);
    } else {
      yield LoadedRatedState(DishRated.Undecided);
    }
  }

  Stream<FavoriteDishState> _mapChangeRatedEventToState(
      ChangeRatedEvent event) async* {
    DishRated r = event.ratedState;

    yield LoadedRatedState(event.ratedState);
  }

  @override
  Future<void> close() async {
    masterListener.cancel();
    super.close();
  }
}
