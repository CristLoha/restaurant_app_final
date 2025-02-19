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

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiService.getRestaurantDetail(id);
      if (result.error) {
        _resultState = RestaurantDetailErrorState(result.message);
      } else {
        _resultState = RestaurantDetailLoadedState(result.restaurant);
      }
    } catch (e) {
      _resultState = RestaurantDetailErrorState(
        e is String ? e : 'Terjadi kesalahan. Coba lagi nanti.',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> addReview(
    String restaurantId,
    String name,
    String review,
  ) async {
    if (name.isEmpty || review.isEmpty) return;
    
    try {
      _isSubmitting = true;
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
    } catch (e) {
      _reviewState = RestaurantReviewErrorState('Gagal menambahkan review: $e');
    } finally {
      _isSubmitting = false;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _reviewState = RestaurantReviewNoneState();
        notifyListeners();
      });
    }
  }
}
