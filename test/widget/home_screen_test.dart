import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/data/model/restaurant_list_response.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app_final/ui/screens/home/home_screen.dart';

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
  });

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createTestableWidget(Widget child) {
    return ChangeNotifierProvider<RestaurantListProvider>(
      create: (_) => RestaurantListProvider(mockApiService),
      child: MaterialApp(home: child),
    );
  }

  group('Pengujian HomeScreen Widget', () {
    // Skenario 1: Menampilkan loading indicator saat pertama kali dibuka
    testWidgets(
      'Seharusnya menampilkan loading indicator saat pertama kali dibuka',
      (tester) async {
        when(() => mockApiService.getRestaurantList()).thenAnswer((_) async {
          // Buat Future yang tidak akan selesai agar loading tetap terlihat
          return Completer<RestaurantListResponse>().future;
        });

        await tester.pumpWidget(createTestableWidget(const HomeScreen()));
        await tester.pump(Duration.zero); // Trigger state change to loading

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    // Skenario 2: Menampilkan daftar restoran saat data berhasil dimuat
    testWidgets(
      'Seharusnya menampilkan daftar restoran saat data berhasil dimuat',
      (tester) async {
        final mockResponse = RestaurantListResponse(
          error: false,
          message: 'Success',
          restaurants: [
            Restaurant(
              id: 'rqdv5juczeskfw1e867',
              name: 'Melting Pot',
              description: 'Restoran terkenal dengan hidangan khas.',
              pictureId: '14',
              city: 'Medan',
              rating: 4.2,
            ),
          ],
          count: 1,
        );

        when(() => mockApiService.getRestaurantList()).thenAnswer((_) async {
          return mockResponse;
        });

        await tester.pumpWidget(createTestableWidget(const HomeScreen()));
        // pumpAndSettle can time out due to complex animations (RefreshIndicator, Hero).
        // We pump manually to step through the states.
        await tester.pump(); // Triggers loading state.
        await tester
            .pump(); // Triggers loaded state after the future completes.

        expect(find.text('Melting Pot'), findsOneWidget);
        expect(find.text('Medan'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    // Skenario 3: Menampilkan pesan error saat gagal mengambil data
    testWidgets(
      'Seharusnya menampilkan pesan error saat gagal mengambil data',
      (tester) async {
        when(
          () => mockApiService.getRestaurantList(),
        ).thenThrow(Exception('Terjadi kesalahan.'));

        await tester.pumpWidget(createTestableWidget(const HomeScreen()));
        // pumpAndSettle can time out. Pumping manually is more reliable.
        await tester.pump(); // Triggers loading state.
        await tester.pump(); // Triggers error state after the future completes.

        expect(
          find.text('Terjadi kesalahan. Coba lagi nanti.'),
          findsOneWidget,
        );
      },
    );
  });
}
