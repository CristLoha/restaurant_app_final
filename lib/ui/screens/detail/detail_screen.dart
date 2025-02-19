import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/detail/favorite_icon_provider.dart';
import 'package:restaurant_app_final/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app_final/static/restaurant_detail_result_state.dart';
import 'package:restaurant_app_final/ui/widgets/error_card_widget.dart';
import 'widgets/content_detail_widget.dart';
import 'widgets/favorite_icon_widget.dart';

class DetailScreen extends StatefulWidget {
  final String tourismId;
  const DetailScreen({super.key, required this.tourismId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<RestaurantDetailProvider>().fetchRestaurantDetail(
          widget.tourismId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (AppBar(
        title: Text('Detail Restoran'),
        actions: [
          ChangeNotifierProvider(
            create: (context) => FavoriteIconProvider(),
            child: Consumer<RestaurantDetailProvider>(
              builder: (context, value, child) {
                return switch (value.resultState) {
                  RestaurantDetailLoadedState(data: var restaurant) =>
                    FavoriteIconWidget(restaurant: restaurant),
                  _ => const SizedBox(),
                };
              },
            ),
          ),
        ],
      )),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, value, child) {
          return switch (value.resultState) {
            RestaurantDetailLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            RestaurantDetailLoadedState(data: var restaurant) =>
              ContentDetailWidget(restaurantDetail: restaurant),
            RestaurantDetailErrorState(message: var message) => Center(
              child: ErrorCardWidget(
                message: message,
                onTap: () {
                  context
                      .read<RestaurantDetailProvider>()
                      .fetchRestaurantDetail(widget.tourismId);
                },
              ),
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
