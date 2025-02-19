import 'package:flutter/material.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/static/restaurant_detail_result_state.dart';
import 'package:restaurant_app_final/static/restaurant_review_result_state.dart';


class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService _apiService;
  RestaurantDetailProvider(this._apiService);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();
  RestaurantDetailResultState get resultState => _resultState;

  RestaurantReviewResultState _reviewState = RestaurantReviewNoneState();
  RestaurantReviewResultState get reviewState => _reviewState;
  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiService.getRestaurantDetail(id);
      if (result.error) {
        _resultState = RestaurantDetailErrorState(result.message);
        notifyListeners();
      } else {
        _resultState = RestaurantDetailLoadedState(result.restaurant);
        notifyListeners();
      }
    } catch (e) {
      _resultState = RestaurantDetailErrorState(
        e is String ? e : 'Terjadi kesalahan. Coba lagi nanti.',
      );
      notifyListeners();
    }
  }

  Future<void> addReview(
    String restaurantId,
    String name,
    String review,
  ) async {
    try {
      _reviewState = RestaurantReviewLoadingState();
      notifyListeners();

      final result = await _apiService.addReview(restaurantId, name, review);

      if (_resultState is RestaurantDetailLoadedState) {
        final currentState = _resultState as RestaurantDetailLoadedState;
        final updateRestaurant = currentState.data.copyWith(
          customerReviews: result.customerReviews,
        );
        _resultState = RestaurantDetailLoadedState(updateRestaurant);
      }
      _reviewState = RestaurantReviewSuccessState(result.message);
      notifyListeners();
    } catch (e) {
      _reviewState = RestaurantReviewErrorState('Gagal menambahkan review: $e');
      notifyListeners();
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _reviewState = RestaurantReviewNoneState();
        notifyListeners();
      });
    }
  }
}
