import 'package:flutter/material.dart';
import '../../ui/screens/favorites/favorite_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/search/search_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoriteScreen(),
    const SettingsScreen(),
  ];

  void setIndex(int index) {
    if (index < 0 || index >= pages.length) {
      throw Exception('Invalid index: $index');
    }
    _currentIndex = index;
    notifyListeners();
  }

  Widget get currentPage => pages[_currentIndex];
}
