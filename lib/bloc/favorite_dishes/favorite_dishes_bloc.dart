import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/master/master.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import './favorite_dishes.dart';

class FavoriteDishesBloc
    extends Bloc<FavoriteDishesEvent, FavoriteDishesState> {
  MasterBloc masterBloc;
  StreamSubscription masterListener;

  FavoriteDishesBloc(this.masterBloc) {
    masterListener = masterBloc.listen((masterState) {
      if (state is LoadedFavoriteDishes) {
        if (masterState is MChangeRatedState) {
          add(FChangeRatedEvent(masterState.dish, masterState.ratedState));
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
    if (event is FLoadFavoriteDishesEvent) {
      yield* _mapLoadFavoriteDishesToState(event);
    } else if (event is FChangeRatedEvent) {
      yield* _mapFChangeRatedEventToState(event);
    }
  }

  Stream<FavoriteDishesState> _mapFAddFavoriteDishEventToState(
      FChangeRatedEvent event) async* {
    if (state is LoadedFavoriteDishes) {
      List<Dish> favoriteDishes =
          List<Dish>.from((state as LoadedFavoriteDishes).favoriteDishes)
            ..add(event.dish);
      yield LoadedFavoriteDishes(
        (state as LoadedFavoriteDishes).dislikedDishes,
        (state as LoadedFavoriteDishes).likedDishes,
        favoriteDishes,
      );
    }
  }

  Stream<FavoriteDishesState> _mapLoadFavoriteDishesToState(
      FavoriteDishesEvent event) async* {
    final List<Dish> favoriteDishes = HiveProvider().getFavoriteDishes();
    final List<Dish> likedDishes = HiveProvider().getLikedDishes();
    final List<Dish> dislikedDishes = HiveProvider().getDislikedDishes();

    yield LoadedFavoriteDishes(
      dislikedDishes,
      likedDishes,
      favoriteDishes,
    );
  }

  Stream<FavoriteDishesState> _mapFChangeRatedEventToState(
      FChangeRatedEvent event) async* {
    if (state is LoadedFavoriteDishes) {
      List<Dish> dislikedDishes =
          List<Dish>.from((state as LoadedFavoriteDishes).dislikedDishes)
            ..remove(event.dish);
      List<Dish> likedDishes =
          List<Dish>.from((state as LoadedFavoriteDishes).likedDishes)
            ..remove(event.dish);
      List<Dish> favoriteDishes =
          List<Dish>.from((state as LoadedFavoriteDishes).favoriteDishes)
            ..remove(event.dish);

      switch (event.ratedState) {
        case DishRated.Favorite:
          favoriteDishes.add(event.dish);
          break;
        case DishRated.Liked:
          likedDishes.add(event.dish);
          break;
        case DishRated.Disliked:
          dislikedDishes.add(event.dish);
          break;
        default:
          break;
      }

      yield LoadedFavoriteDishes(
        dislikedDishes,
        likedDishes,
        favoriteDishes,
      );
    }
  }

  @override
  Future<void> close() async {
    print('favorite dishes bloc closed');
    masterListener.cancel();
    super.close();
  }
}
