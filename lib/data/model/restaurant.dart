import 'category.dart';
import 'customer_review.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String city;
  final String? address;
  final String pictureId;
  final List<Category>? categories;
  final Menus? menus;
  final double rating;
  final List<CustomerReview>? customerReviews;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    this.address,
    required this.pictureId,
    this.categories,
    this.menus,
    required this.rating,
    this.customerReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      address: json['address'],
      pictureId: json['pictureId'],
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((e) => Category.fromJson(e))
              .toList()
          : null,
      menus: json['menus'] != null ? Menus.fromJson(json['menus']) : null,
      rating: (json['rating'] as num).toDouble(),
      customerReviews: json['customerReviews'] != null
          ? (json['customerReviews'] as List)
              .map((e) => CustomerReview.fromJson(e))
              .toList()
          : null,
    );
  }
  factory Restaurant.fromSearchJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      city: json['city'],
      pictureId: json['pictureId'],
      rating: (json['rating'] as num).toDouble(),
      address: null,
      categories: null,
      menus: null,
      customerReviews: null,
    );
  }
  Restaurant copyWith({
    List<CustomerReview>? customerReviews,
  }) {
    return Restaurant(
      id: id,
      name: name,
      description: description,
      city: city,
      address: address,
      pictureId: pictureId,
      categories: categories,
      menus: menus,
      rating: rating,
      customerReviews: customerReviews ?? this.customerReviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'address': address,
      'pictureId': pictureId,
      'rating': rating,
    };
  }
}
