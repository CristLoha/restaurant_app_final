import 'dart:io';
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
  late RestaurantListProvider provider;

  setUpAll(() {
    HttpOverrides.global = TestImageHttpOverrides();
  });

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantListProvider(mockApiService);
  });

  Widget createTestableWidget(Widget child) {
    return ChangeNotifierProvider<RestaurantListProvider>.value(
      value: provider,
      child: MaterialApp(home: child),
    );
  }

  group('Pengujian HomeScreen Widget', () {
    // Skenario 1: Menampilkan loading indicator saat pertama kali dibuka
    testWidgets(
      'Seharusnya menampilkan loading indicator saat pertama kali dibuka',
      (tester) async {
        debugPrint('Mock API: Memulai permintaan data');
        when(() => mockApiService.getRestaurantList()).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return RestaurantListResponse(
            error: false,
            message: 'Success',
            restaurants: [],
            count: 0,
          );
        });

        await tester.pumpWidget(createTestableWidget(const HomeScreen()));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle();
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
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        debugPrint('Memeriksa apakah daftar restoran muncul di UI...');
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
        await tester.pump();
        await tester.pumpAndSettle();

        expect(
          find.text('Terjadi kesalahan. Coba lagi nanti.'),
          findsOneWidget,
        );
      },
    );
  });
}
