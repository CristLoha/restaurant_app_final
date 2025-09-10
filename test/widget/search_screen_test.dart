import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/data/model/restaurant_search_response.dart';
import 'package:restaurant_app_final/provider/search/restaurant_search_provider.dart';
import 'package:restaurant_app_final/ui/screens/home/widget/restaurant_card_widget.dart';
import 'package:restaurant_app_final/ui/screens/search/search_screen.dart';

class MockApiService extends Mock implements ApiService {}

class TestImageHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  late MockApiService mockApiService;

  setUpAll(() {
    HttpOverrides.global = TestImageHttpOverrides();
    registerFallbackValue('a');
  });

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createTestableWidget(Widget child) {
    return ChangeNotifierProvider<RestaurantSearchProvider>(
      create: (_) => RestaurantSearchProvider(mockApiService),
      child: MaterialApp(home: child),
    );
  }

  group('Pengujian SearchScreen Widget', () {
    testWidgets('Seharusnya menampilkan daftar restoran saat pencarian berhasil', (
      tester,
    ) async {
      final mockRestaurants = [
        Restaurant(
          id: '1',
          name: 'Test Cafe',
          description: 'Desc',
          pictureId: '1',
          city: 'City',
          rating: 4.5,
        ),
      ];
      when(() => mockApiService.searchRestaurant(any())).thenAnswer(
        (_) async => RestaurantSearchResponse(
          error: false,
          founded: 1,
          restaurants: mockRestaurants,
        ),
      );

      await tester.pumpWidget(createTestableWidget(const SearchScreen()));

      await tester.enterText(find.byType(TextField), 'test');
      // pumpAndSettle can time out if there are ongoing animations (like a loading spinner).
      // We pump for the debounce duration, then pump again to render the result.
      await tester.pump(const Duration(milliseconds: 501));
      await tester.pump();

      expect(find.byType(RestaurantCardWidget), findsOneWidget);
      expect(find.text('Test Cafe'), findsOneWidget);
    });

    testWidgets('Seharusnya menampilkan pesan error saat tidak ada hasil', (
      tester,
    ) async {
      when(() => mockApiService.searchRestaurant(any())).thenAnswer(
        (_) async =>
            RestaurantSearchResponse(error: false, founded: 0, restaurants: []),
      );

      await tester.pumpWidget(createTestableWidget(const SearchScreen()));

      await tester.enterText(find.byType(TextField), 'xyz');
      // pumpAndSettle can time out.
      await tester.pump(const Duration(milliseconds: 501));
      await tester.pump();

      expect(find.text('Restoran tidak ditemukan.'), findsOneWidget);
    });
  });
}
