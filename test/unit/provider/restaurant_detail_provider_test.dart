import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/data/model/add_review_responde.dart';
import 'package:restaurant_app_final/data/model/customer_review.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/data/model/restaurant_detail_response.dart';
import 'package:restaurant_app_final/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app_final/static/restaurant_detail_result_state.dart';
import 'package:restaurant_app_final/static/restaurant_review_result_state.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late RestaurantDetailProvider provider;

  final tRestaurantId = '1';
  final tRestaurant = Restaurant(
    id: '1',
    name: 'Test Restaurant',
    description: 'Test Description',
    city: 'Test City',
    address: 'Test Address',
    pictureId: '123',
    rating: 4.5,
    customerReviews: [],
  );

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantDetailProvider(mockApiService);
  });

  group('Pengujian RestaurantDetailProvider', () {
    test('Seharusnya state awal adalah RestaurantDetailNoneState', () {
      expect(provider.resultState, isA<RestaurantDetailNoneState>());
      expect(provider.reviewState, isA<RestaurantReviewNoneState>());
    });

    group('fetchRestaurantDetail', () {
      test(
        'Seharusnya mengembalikan RestaurantDetailLoadedState ketika API berhasil',
        () async {
          // Arrange
          when(
            () => mockApiService.getRestaurantDetail(tRestaurantId),
          ).thenAnswer(
            (_) async => RestaurantDetailResponse(
              error: false,
              message: 'Success',
              restaurant: tRestaurant,
            ),
          );

          // Act
          await provider.fetchRestaurantDetail(tRestaurantId);

          // Assert
          expect(provider.resultState, isA<RestaurantDetailLoadedState>());
          final loadedState =
              provider.resultState as RestaurantDetailLoadedState;
          expect(loadedState.data, tRestaurant);
        },
      );

      test(
        'Seharusnya mengembalikan RestaurantDetailErrorState ketika API gagal',
        () async {
          // Arrange
          when(
            () => mockApiService.getRestaurantDetail(tRestaurantId),
          ).thenThrow(Exception('API Error'));

          // Act
          await provider.fetchRestaurantDetail(tRestaurantId);

          // Assert
          expect(provider.resultState, isA<RestaurantDetailErrorState>());
          final errorState = provider.resultState as RestaurantDetailErrorState;
          expect(errorState.message, 'Terjadi kesalahan. Coba lagi nanti.');
        },
      );
    });

    group('addReview', () {
      final tNewReview = CustomerReview(
        name: 'Tester',
        review: 'Good',
        date: 'Today',
      );

      test(
        'Seharusnya berhasil menambahkan review dan memperbarui state',
        () async {
          // Arrange
          // 1. Mock respons untuk fetch detail awal
          when(
            () => mockApiService.getRestaurantDetail(tRestaurantId),
          ).thenAnswer(
            (_) async => RestaurantDetailResponse(
              error: false,
              message: 'Success',
              restaurant: tRestaurant,
            ),
          );
          // 2. Mock respons untuk add review
          when(
            () => mockApiService.addReview(tRestaurantId, 'Tester', 'Good'),
          ).thenAnswer(
            (_) async => AddReviewResponse(
              error: false,
              message: 'Success',
              customerReviews: [tNewReview],
            ),
          );

          // Act
          // 1. Panggil fetch detail untuk menempatkan provider di state 'loaded'
          await provider.fetchRestaurantDetail(tRestaurantId);
          // 2. Panggil add review
          await provider.addReview(tRestaurantId, 'Tester', 'Good');

          // Assert
          expect(provider.reviewState, isA<RestaurantReviewSuccessState>());
          expect(provider.isSubmitting, isFalse);

          // Cek apakah state detail utama diperbarui dengan review baru
          expect(provider.resultState, isA<RestaurantDetailLoadedState>());
          final loadedState =
              provider.resultState as RestaurantDetailLoadedState;
          expect(loadedState.data.customerReviews, [tNewReview]);
        },
      );

      test(
        'Seharusnya mengembalikan RestaurantReviewErrorState ketika API gagal',
        () async {
          // Arrange
          when(
            () => mockApiService.addReview(tRestaurantId, 'Tester', 'Good'),
          ).thenThrow(Exception('API Error'));

          // Act
          await provider.addReview(tRestaurantId, 'Tester', 'Good');

          // Assert
          expect(provider.reviewState, isA<RestaurantReviewErrorState>());
          expect(provider.isSubmitting, isFalse);
        },
      );
    });
  });
}
