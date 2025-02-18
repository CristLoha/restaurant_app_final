import 'menu_item.dart';

class Menus {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  Menus({required this.foods, required this.drinks});

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods: (json['foods'] as List).map((e) => MenuItem.fromJson(e)).toList(),
      drinks:
          (json['drinks'] as List).map((e) => MenuItem.fromJson(e)).toList(),
    );
  }
}
