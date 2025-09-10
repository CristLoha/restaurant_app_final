import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app_final/static/navigation_route.dart';
import 'package:restaurant_app_final/static/restaurant_list_result_state.dart';
import 'package:restaurant_app_final/ui/widgets/error_card_widget.dart';
import 'package:restaurant_app_final/utils/theme.dart';
import 'widget/restaurant_card_widget.dart';
import 'widget/restaurant_card_shimmer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<RestaurantListProvider>().fetchRestaurantList(),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<RestaurantListProvider>().fetchRestaurantList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: Column(
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
                    ],
                  ),
                ),
              ),
            ),
            Consumer<RestaurantListProvider>(
              builder: (context, value, child) {
                return switch (value.resultState) {
                  RestaurantListLoadingState() => _buildShimmerList(),
                  RestaurantListLoadedState(data: var restaurantList) =>
                    _buildRestaurantList(restaurantList),
                  RestaurantListErrorState(message: var message) =>
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ErrorCardWidget(
                          message: message,
                          onTap: _onRefresh,
                        ),
                      ),
                    ),
                  _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> restaurantList) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final restaurant = restaurantList[index];
        final heroTag = 'home_${restaurant.id}';
        return RestaurantCardWidget(
          onTap: () {
            Navigator.pushNamed(
              context,
              NavigationRoute.detailRoute,
              arguments: {'id': restaurant.id, 'heroTag': heroTag},
            );
          },
          restaurant: restaurant,
          heroTag: heroTag,
        );
      }, childCount: restaurantList.length),
    );
  }

  Widget _buildShimmerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const RestaurantCardShimmerWidget(),
        childCount: 5,
      ),
    );
  }
}
