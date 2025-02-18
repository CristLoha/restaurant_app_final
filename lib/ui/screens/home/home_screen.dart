import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/home/restaurant_list_provider.dart';
import '../../../static/navigation_route.dart';
import '../../../static/restaurant_list_result_state.dart';
import '../../../utils/theme.dart';
import '../../widgets/error_card_widget.dart';
import 'widget/restaurant_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<RestaurantListProvider>().fetchRestaurantList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant',
              style: AppTextStyles.textThemeCustom.headlineMedium,
            ),
            Text(
              'Recommendation restaurant for you!',
              style: AppTextStyles.textThemeCustom.bodyLarge,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      body: Consumer<RestaurantListProvider>(
        builder: (context, value, child) {
          return switch (value.resultState) {
            RestaurantListLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            RestaurantListLoadedState(data: var restaurantList) =>
              ListView.builder(
                itemCount: restaurantList.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurantList[index];
                  return RestaurantCardWidget(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        NavigationRoute.detailRoute.name,
                        arguments: restaurant.id,
                      );
                    },
                    restaurant: restaurant,
                  );
                },
              ),
            RestaurantListErrorState(message: var message) => Center(
              child: ErrorCardWidget(
                message: message,
                onTap: () {
                  context.read<RestaurantListProvider>().fetchRestaurantList();
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
