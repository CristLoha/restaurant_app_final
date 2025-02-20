import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/data/model/restaurant_list_response.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app_final/static/restaurant_list_result_state.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late RestaurantListProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantListProvider(mockApiService);
  });

  group('Pengujian RestaurantListProvider', () {
    // Skenario 1: Memastikan state awal provider harus didefinisikan
    test(
      'Seharusnya mengembalikan state awal sebagai RestaurantListNoneState',
      () {
        expect(provider.resultState, isA<RestaurantListNoneState>());
      },
    );

    // Skenario 2: Memastikan harus mengembalikan daftar restoran ketika pengambilan data API berhasil
    test(
      'Seharusnya mengembalikan RestaurantListLoadedState ketika API berhasil mengambil data restoran',
      () async {
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

        when(
          () => mockApiService.getRestaurantList(),
        ).thenAnswer((_) async => mockResponse);

        await provider.fetchRestaurantList();

        expect(provider.resultState, isA<RestaurantListLoadedState>());

        final loadedState = provider.resultState as RestaurantListLoadedState;
        expect(loadedState.data.length, 1);
        expect(loadedState.data.first.name, 'Melting Pot');
      },
    );

    // Skenario 3: Memastikan harus mengembalikan kesalahan ketika pengambilan data API gagal
    test(
      'Seharusnya mengembalikan RestaurantListErrorState ketika API gagal mengambil data restoran',
      () async {
        when(
          () => mockApiService.getRestaurantList(),
        ).thenThrow(Exception('Terjadi kesalahan.'));

        await provider.fetchRestaurantList();

        expect(provider.resultState, isA<RestaurantListErrorState>());

        final errorState = provider.resultState as RestaurantListErrorState;
        expect(errorState.message, 'Terjadi kesalahan. Coba lagi nanti.');
      },
    );

    // Skenario Tambahan: Memastikan harus mengembalikan pesan khusus ketika daftar restoran kosong
    test(
      'Seharusnya mengembalikan RestaurantListErrorState dengan pesan khusus ketika API mengembalikan daftar restoran kosong',
      () async {
        final mockResponse = RestaurantListResponse(
          error: false,
          message: 'Success',
          restaurants: [],
          count: 0,
        );

        when(
          () => mockApiService.getRestaurantList(),
        ).thenAnswer((_) async => mockResponse);

        await provider.fetchRestaurantList();

        expect(provider.resultState, isA<RestaurantListErrorState>());

        final errorState = provider.resultState as RestaurantListErrorState;
        expect(errorState.message, 'Tidak ada restoran yang tersedia.');
      },
    );
  });
}
