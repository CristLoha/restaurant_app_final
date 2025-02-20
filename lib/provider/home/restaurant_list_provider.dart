import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../static/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantListProvider(this._apiService);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurantList() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();
      final result = await _apiService.getRestaurantList();

      if (result.error) {
        _resultState = RestaurantListErrorState(result.message);
        notifyListeners();
      } else if (result.restaurants.isEmpty) {
        _resultState = RestaurantListErrorState(
          'Tidak ada restoran yang tersedia.',
        );
        notifyListeners();
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants);
        notifyListeners();
      }
    } catch (e) {
      _resultState = RestaurantListErrorState(
        e is String ? e : 'Terjadi kesalahan. Coba lagi nanti.',
      );
      notifyListeners();
    }
  }
}
