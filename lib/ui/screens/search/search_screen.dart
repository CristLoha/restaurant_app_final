import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/search/restaurant_search_provider.dart';
import 'package:restaurant_app_final/static/navigation_route.dart';
import 'package:restaurant_app_final/static/restaurant_search_result_state.dart';
import 'package:restaurant_app_final/ui/screens/home/widget/restaurant_card_widget.dart';
import 'package:restaurant_app_final/ui/widgets/error_card_widget.dart';
import 'package:restaurant_app_final/utils/theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Restaurant')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Cari restoran',
                border: const OutlineInputBorder(),
                fillColor: AppColors.grey,
                suffixIcon:
                    _controller.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                        : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Consumer<RestaurantSearchProvider>(
              builder: (context, value, child) {
                return switch (value.resultState) {
                  RestaurantSearchLoadingState() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  RestaurantSearchLoadedState(data: var restaurants) =>
                    ListView.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
                        return RestaurantCardWidget(
                          restaurant: restaurant,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              NavigationRoute.detailRoute.name,
                              arguments: restaurant.id,
                            );
                          },
                        );
                      },
                    ),
                  RestaurantSearchErrorState(message: var message) => Center(
                    child: ErrorCardWidget(
                      message: message,
                      onTap: () {
                        final query = _controller.text;
                        if (query.isNotEmpty) {
                          context
                              .read<RestaurantSearchProvider>()
                              .searchRestaurant(query);
                        }
                      },
                    ),
                  ),
                  _ => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Cari Restoran',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masukkan kata kunci untuk mencari restoran',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    context.read<RestaurantSearchProvider>().debouncedSearch(query);
  }

  void _clearSearch() {
    _controller.clear();
    context.read<RestaurantSearchProvider>().resetSearch();
  }
}
