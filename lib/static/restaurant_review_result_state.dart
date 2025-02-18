sealed class RestaurantReviewResultState {}

class RestaurantReviewNoneState extends RestaurantReviewResultState {}

class RestaurantReviewLoadingState extends RestaurantReviewResultState {}

class RestaurantReviewSuccessState extends RestaurantReviewResultState {
  final String message;
  RestaurantReviewSuccessState(this.message);
}

class RestaurantReviewErrorState extends RestaurantReviewResultState {
  final String message;
  RestaurantReviewErrorState(this.message);
}
