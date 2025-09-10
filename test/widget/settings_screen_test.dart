import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/scheduling/scheduling_provider.dart';
import 'package:restaurant_app_final/provider/theme/theme_provider.dart';
import 'package:restaurant_app_final/ui/screens/settings/settings_screen.dart';

class MockSchedulingProvider extends Mock implements SchedulingProvider {}

class MockThemeProvider extends Mock implements ThemeProvider {}

void main() {
  late MockSchedulingProvider mockSchedulingProvider;
  late MockThemeProvider mockThemeProvider;

  setUp(() {
    mockSchedulingProvider = MockSchedulingProvider();
    mockThemeProvider = MockThemeProvider();

    // Register fallback values for any() matcher
    registerFallbackValue(ThemeMode.system);

    // Provide default values for providers to prevent null errors during build.
    // These can be overridden in individual tests if needed.
    when(
      () => mockSchedulingProvider.isDailyRestaurantActive,
    ).thenReturn(false);
    when(
      () => mockSchedulingProvider.selectedTime,
    ).thenReturn(const TimeOfDay(hour: 11, minute: 00));
    when(() => mockThemeProvider.themeMode).thenReturn(ThemeMode.system);
  });

  Widget createTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SchedulingProvider>.value(
          value: mockSchedulingProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('Pengujian SettingsScreen Widget', () {
    testWidgets(
      'Seharusnya switch reminder dalam keadaan ON jika provider menyatakannya',
      (tester) async {
        // Arrange
        when(
          () => mockSchedulingProvider.isDailyRestaurantActive,
        ).thenReturn(true);

        // Act
        await tester.pumpWidget(createTestableWidget(const SettingsScreen()));

        // Assert
        final reminderSwitch = tester.widget<Switch>(find.byType(Switch));
        expect(reminderSwitch.value, isTrue);
      },
    );

    testWidgets(
      'Seharusnya memanggil scheduledRestaurants saat switch di-tap',
      (tester) async {
        // Arrange
        when(
          () => mockSchedulingProvider.scheduledRestaurants(any()),
        ).thenAnswer((_) async => true);

        // Act
        await tester.pumpWidget(createTestableWidget(const SettingsScreen()));
        await tester.tap(find.byType(Switch));
        await tester.pump();

        // Assert
        verify(
          () => mockSchedulingProvider.scheduledRestaurants(true),
        ).called(1);
      },
    );

    testWidgets(
      'Seharusnya memanggil setTheme saat radio button "Light" di-tap',
      (tester) async {
        // Arrange
        when(() => mockThemeProvider.themeMode).thenReturn(ThemeMode.dark);
        when(() => mockThemeProvider.setTheme(any())).thenAnswer((_) async {});

        // Act
        await tester.pumpWidget(createTestableWidget(const SettingsScreen()));
        await tester.tap(find.byKey(const Key('light_theme_radio')));
        await tester.pump();

        // Assert
        verify(() => mockThemeProvider.setTheme(ThemeMode.light)).called(1);
      },
    );
  });
}
