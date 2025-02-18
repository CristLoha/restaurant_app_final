import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/data/model/restaurant.dart';
import 'package:restaurant_app_final/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app_final/static/restaurant_list_result_state.dart';
import 'package:restaurant_app_final/ui/screens/home/home_screen.dart';
import 'package:restaurant_app_final/ui/screens/home/widget/restaurant_card_widget.dart'
    show RestaurantCardWidget;
import 'package:restaurant_app_final/ui/widgets/error_card_widget.dart';

import '../../../tests_helper.dart';

class MockRestaurantListProvider extends Mock
    implements RestaurantListProvider {}

void main() {
  late MockRestaurantListProvider mockProvider;

  setUp(() {
    mockProvider = MockRestaurantListProvider();
    HttpOverrides.global = MyHttpOverrides();
    // Mocking method fetchRestaurantList()
    when(
      () => mockProvider.fetchRestaurantList(),
    ).thenAnswer((_) async {}); // Mengembalikan Future<void>
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<RestaurantListProvider>.value(
        value: mockProvider,
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets('Menampilkan CircularProgressIndicator ketika sedang loading', (
    WidgetTester tester,
  ) async {
    when(
      () => mockProvider.resultState,
    ).thenReturn(RestaurantListLoadingState());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Menampilkan daftar restoran ketika data berhasil dimuat', (
    WidgetTester tester,
  ) async {
    when(() => mockProvider.resultState).thenReturn(
      RestaurantListLoadedState([
        Restaurant(
          id: "vfsqv0t48jkfw1e867",
          name: "Gigitan Makro",
          description:
              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.",
          pictureId: "04",

          city: "Surabaya",
          rating: 4.9,
        ),
        Restaurant(
          id: "p06p0wr8eedkfw1e867",
          name: "Run The Gun",
          description:
              "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure.",
          pictureId: "30",
          city: "Aceh",
          rating: 3.7,
        ),
      ]),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(RestaurantCardWidget), findsNWidgets(2));
  });

  testWidgets('Menampilkan pesan error ketika terjadi kesalahan', (
    WidgetTester tester,
  ) async {
    when(
      () => mockProvider.resultState,
    ).thenReturn(RestaurantListErrorState("Gagal memuat data"));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(ErrorCardWidget), findsOneWidget);
    expect(find.text("Gagal memuat data"), findsOneWidget);
  });
}
