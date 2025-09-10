import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/utils/image.util.dart';
import 'package:restaurant_app_final/utils/theme.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantCardWidget extends StatelessWidget {
  final Restaurant restaurant;
  final Function() onTap;
  final String heroTag;

  const RestaurantCardWidget({
    super.key,
    required this.restaurant,
    required this.onTap,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: heroTag,
                  child: CachedNetworkImage(
                    imageUrl: getRestaurantImageUrl(restaurant.pictureId),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 80,
                    placeholder:
                        (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                    errorWidget:
                        (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    restaurant.name,
                    style: AppTextStyles.textThemeCustom.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 16,
                      ),
                      Text(
                        restaurant.city,
                        style: AppTextStyles.textThemeCustom.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(
                        restaurant.rating.toString(),
                        style: AppTextStyles.textThemeCustom.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
