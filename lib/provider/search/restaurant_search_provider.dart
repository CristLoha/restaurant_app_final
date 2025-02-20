import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/static/restaurant_search_result_state.dart';

class RestaurantSearchProvider extends ChangeNotifier {
  final ApiService _apiService;
  Timer? _debounce;

  RestaurantSearchProvider(this._apiService);

  RestaurantSearchResultState _resultState = RestaurantSearchNoneState();
  RestaurantSearchResultState get resultState => _resultState;

  void debouncedSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchRestaurant(query);
    });
  }

  Future<void> searchRestaurant(String query) async {
    try {
      _resultState = RestaurantSearchLoadingState();
      notifyListeners();
      final result = await _apiService.searchRestaurant(query);
      if (result.restaurants.isEmpty) {
        _resultState = RestaurantSearchErrorState('Restoran tidak ditemukan.');
      } else {
        _resultState = RestaurantSearchLoadedState(result.restaurants);
      }
    } catch (e) {
      _resultState = RestaurantSearchErrorState(
        e is String ? e : 'Terjadi kesalahan. Coba lagi nanti.',
      );
    }
    notifyListeners();
  }

  void resetSearch() {
    _resultState = RestaurantSearchNoneState();
    notifyListeners();
  }
}
