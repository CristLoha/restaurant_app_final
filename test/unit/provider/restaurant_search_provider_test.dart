import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/data/model/restaurant_search_response.dart';
import 'package:restaurant_app_final/provider/search/restaurant_search_provider.dart';
import 'package:restaurant_app_final/static/restaurant_search_result_state.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late RestaurantSearchProvider provider;

  final tQuery = 'melting';
  final tRestaurant = Restaurant(
    id: '1',
    name: 'Melting Pot',
    description: 'Desc',
    city: 'City',
    pictureId: '123',
    rating: 4.0,
  );

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantSearchProvider(mockApiService);
  });

  group('Pengujian RestaurantSearchProvider', () {
    test('Seharusnya state awal adalah RestaurantSearchNoneState', () {
      expect(provider.resultState, isA<RestaurantSearchNoneState>());
    });

    test(
        'Seharusnya mengembalikan RestaurantSearchLoadedState ketika pencarian berhasil',
        () async {
      // Arrange
      when(() => mockApiService.searchRestaurant(tQuery)).thenAnswer((_) async =>
          RestaurantSearchResponse(
              error: false, founded: 1, restaurants: [tRestaurant]));

      // Act
      await provider.searchRestaurant(tQuery);

      // Assert
      expect(provider.resultState, isA<RestaurantSearchLoadedState>());
      final loadedState = provider.resultState as RestaurantSearchLoadedState;
      expect(loadedState.data.first, tRestaurant);
    });

    test(
        'Seharusnya mengembalikan RestaurantSearchErrorState ketika tidak ada hasil',
        () async {
      // Arrange
      when(() => mockApiService.searchRestaurant(tQuery)).thenAnswer((_) async =>
          RestaurantSearchResponse(error: false, founded: 0, restaurants: []));

      // Act
      await provider.searchRestaurant(tQuery);

      // Assert
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
      final errorState = provider.resultState as RestaurantSearchErrorState;
      expect(errorState.message, 'Restoran tidak ditemukan.');
    });

    test('Seharusnya mengembalikan RestaurantSearchErrorState ketika API gagal',
        () async {
      // Arrange
      when(() => mockApiService.searchRestaurant(tQuery))
          .thenThrow(Exception('API Error'));

      // Act
      await provider.searchRestaurant(tQuery);

      // Assert
      expect(provider.resultState, isA<RestaurantSearchErrorState>());
    });

    test(
        'resetSearch seharusnya mengembalikan state ke RestaurantSearchNoneState',
        () {
      // Act
      provider.resetSearch();

      // Assert
      expect(provider.resultState, isA<RestaurantSearchNoneState>());
    });
  });
}
