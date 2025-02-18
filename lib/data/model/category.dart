import 'menu_item.dart';

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name']);
  }
}

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
