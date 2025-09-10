import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/static/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantListProvider(this._apiService);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurantList() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners(); // Notify UI to show loading state
      final result = await _apiService.getRestaurantList();

      if (result.error) {
        _resultState = RestaurantListErrorState(result.message);
      } else if (result.restaurants.isEmpty) {
        _resultState = RestaurantListErrorState(
          'Tidak ada restoran yang tersedia.',
        );
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants);
      }
    } catch (e, stacktrace) {
      log('Error fetching restaurant list: $e', stackTrace: stacktrace);
      _resultState = RestaurantListErrorState(
        e is String ? e : 'Terjadi kesalahan. Coba lagi nanti.',
      );
    } finally {
      notifyListeners(); // Notify UI of the final state
    }
  }
}
