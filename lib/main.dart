import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/api/api_service.dart';
import 'data/local/local_database_service.dart';
import 'provider/detail/restaurant_detail_provider.dart';
import 'provider/favorite/local_database_provider.dart'
    show LocalDatabaseProvider;
import 'provider/home/restaurant_list_provider.dart';
import 'provider/navigation/navigation_provider.dart' show NavigationProvider;
import 'provider/scheduling/payload_provider.dart' show PayloadProvider;
import 'provider/scheduling/restaurant_notfication_provider.dart';
import 'provider/scheduling/scheduling_provider.dart';
import 'provider/search/restaurant_search_provider.dart';
import 'provider/theme/theme_provider.dart';
import 'services/restaurant_notification_service.dart';
import 'static/navigation_route.dart';
import 'ui/screens/detail/detail_screen.dart';
import 'ui/screens/navigation/navigation_screen.dart';
import 'utils/theme.dart' show AppTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  String? payload;
  String route = NavigationRoute.mainRoute.name;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = NavigationRoute.detailRoute.name;
    payload = notificationResponse?.payload;
  }
  runApp(
    MultiProvider(
      providers: [
        // Provider untuk layanan utama (tanpa dependencies)
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<LocalDatabaseService>(create: (_) => LocalDatabaseService()),

        Provider<RestaurantNotificationService>(
          lazy: false, // Agar langsung diinisialisasi
          create: (context) {
            final service = RestaurantNotificationService();
            service.init();
            service.configureLocalTimeZone();
            return service;
          },
        ),

        // Provider yang bergantung pada layanan di atas
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        ChangeNotifierProvider(
          create:
              (context) => RestaurantListProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => RestaurantDetailProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) =>
                  LocalDatabaseProvider(context.read<LocalDatabaseService>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => RestaurantSearchProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..loadTheme(),
        ),
        ChangeNotifierProvider(
          create:
              (context) => RestaurantNotificationProvider(
                context.read<RestaurantNotificationService>(),
              ),
        ),
        ChangeNotifierProvider(
          create:
              (context) => SchedulingProvider(
                notificationService:
                    context.read<RestaurantNotificationService>(),
              ),
        ),

        ChangeNotifierProvider(
          create: (context) => PayloadProvider(payload: payload),
        ),
      ],
      child: RestaurantApp(initialRoute: route),
    ),
  );
}

class RestaurantApp extends StatelessWidget {
  final String initialRoute;
  const RestaurantApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Restaurant App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: initialRoute,
          routes: {
            NavigationRoute.mainRoute.name:
                (context) => const NavigationScreen(),
            NavigationRoute.detailRoute.name:
                (context) => DetailScreen(
                  tourismId:
                      ModalRoute.of(context)?.settings.arguments as String,
                ),
          },
        );
      },
    );
  }
}
