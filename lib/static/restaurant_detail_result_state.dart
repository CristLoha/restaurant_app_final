import '../data/model/restaurant.dart';

sealed class RestaurantDetailResultState {}

class RestaurantDetailNoneState extends RestaurantDetailResultState {}

class RestaurantDetailLoadingState extends RestaurantDetailResultState {}

class RestaurantDetailErrorState extends RestaurantDetailResultState {
  final String message;

  RestaurantDetailErrorState(this.message);
}

class RestaurantDetailLoadedState extends RestaurantDetailResultState {
  final Restaurant data;

  RestaurantDetailLoadedState(this.data);
}
