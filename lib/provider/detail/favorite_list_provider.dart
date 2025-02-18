import 'package:flutter/material.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';

class FavoriteListProvider extends ChangeNotifier {
  final List<Restaurant> _favoriteList = [];

  List<Restaurant> get favoriteList => _favoriteList;

  void addFavorite(Restaurant value) {
    _favoriteList.add(value);
    notifyListeners();
  }

  void removeFavorite(Restaurant value) {
    _favoriteList.removeWhere((element) => element.id == value.id);
    notifyListeners();
  }

  bool checkItemFavorite(Restaurant value) {
    final restaurantList = _favoriteList.where(
      (element) => element.id == value.id,
    );
    notifyListeners();
    return restaurantList.isNotEmpty;
  }
}
