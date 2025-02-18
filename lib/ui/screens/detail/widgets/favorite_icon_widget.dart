import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/model/restaurant.dart';
import '../../../../provider/detail/favorite_icon_provider.dart';
import '../../../../provider/favorite/local_database_provider.dart';
import '../../../../utils/theme.dart';

class FavoriteIconWidget extends StatefulWidget {
  final Restaurant restaurant;
  const FavoriteIconWidget({super.key, required this.restaurant});

  @override
  State<FavoriteIconWidget> createState() => _FavoriteIconWidgetState();
}

class _FavoriteIconWidgetState extends State<FavoriteIconWidget> {
  @override
  void initState() {
    final localDatabaseProvider = context.read<LocalDatabaseProvider>();
    final favoriteIconProider = context.read<FavoriteIconProvider>();

    Future.microtask(() async {
      await localDatabaseProvider.loadRestaurantById(widget.restaurant.id);
      final value = localDatabaseProvider.checkItemFavorite(
        widget.restaurant.id,
      );

      favoriteIconProider.isFavorite = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final localDatabaseProvider = context.read<LocalDatabaseProvider>();
        final favoriteIconProvider = context.read<FavoriteIconProvider>();
        final isFavorite = favoriteIconProvider.isFavorite;

        if (!isFavorite) {
          await localDatabaseProvider.saveRestaurant(widget.restaurant);
        } else {
          await localDatabaseProvider.removeRestaurantById(
            widget.restaurant.id,
          );
        }
        favoriteIconProvider.isFavorite = !isFavorite;
        localDatabaseProvider.loadAllRestaurant();
      },
      icon: Icon(
        context.watch<FavoriteIconProvider>().isFavorite
            ? Icons.favorite
            : Icons.favorite_outline,
        color: AppColors.primary,
      ),
    );
  }
}
