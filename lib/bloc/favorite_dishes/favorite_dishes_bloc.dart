import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:open_mensa_flutter/bloc/favorite_dish/favorite_dish_bloc.dart';
import 'package:open_mensa_flutter/bloc/favorite_dish/favorite_dish_event.dart';
import 'package:open_mensa_flutter/bloc/master/master.dart';
import 'package:open_mensa_flutter/data/hive.dart';
import 'package:open_mensa_flutter/models/dish.dart';
import '../../dish_card.dart';
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
        (state as LoadedFavoriteDishes).favoriteDishBlocs,
      );
    }
  }

  Stream<FavoriteDishesState> _mapLoadFavoriteDishesToState(
      FavoriteDishesEvent event) async* {
    final List<Dish> favoriteDishes = HiveProvider().getFavoriteDishes();
    final List<Dish> likedDishes = HiveProvider().getLikedDishes();
    final List<Dish> dislikedDishes = HiveProvider().getDislikedDishes();

    Map<Dish, FavoriteDishBloc> dishBlocs = {};

    for (Dish dish in favoriteDishes) {
      dishBlocs.addAll({
        dish: FavoriteDishBloc(masterBloc, dish)..add(InitializeDishEvent(dish))
      });
    }
    for (Dish dish in likedDishes) {
      dishBlocs.addAll({
        dish: FavoriteDishBloc(masterBloc, dish)..add(InitializeDishEvent(dish))
      });
    }
    for (Dish dish in dislikedDishes) {
      dishBlocs.addAll({
        dish: FavoriteDishBloc(masterBloc, dish)..add(InitializeDishEvent(dish))
      });
    }

    yield LoadedFavoriteDishes(
      dislikedDishes,
      likedDishes,
      favoriteDishes,
      dishBlocs,
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

      Map<Dish, FavoriteDishBloc> favBlocs =
          (state as LoadedFavoriteDishes).favoriteDishBlocs;
      if (!favBlocs.containsKey(event.dish)) {
        favBlocs.addAll({
          event.dish: FavoriteDishBloc(masterBloc, event.dish)
            ..add(InitializeDishEvent(event.dish))
        });
      }

      yield LoadedFavoriteDishes(
        dislikedDishes,
        likedDishes,
        favoriteDishes,
        (state as LoadedFavoriteDishes).favoriteDishBlocs,
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
