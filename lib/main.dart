import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/api/api_service.dart';
import 'data/local/local_database_service.dart';
import 'provider/detail/restaurant_detail_provider.dart';
import 'provider/favorite/local_database_provider.dart';
import 'provider/home/restaurant_list_provider.dart';
import 'provider/navigation/navigation_provider.dart';
import 'provider/scheduling/payload_provider.dart';
import 'provider/scheduling/scheduling_provider.dart';
import 'provider/search/restaurant_search_provider.dart';
import 'provider/theme/theme_provider.dart';
import 'services/restaurant_notification_service.dart';
import 'static/navigation_route.dart';
import 'ui/screens/detail/detail_screen.dart';
import 'ui/screens/navigation/navigation_screen.dart';
import 'utils/theme.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String route = NavigationRoute.mainRoute; // Sekarang ini adalah String
  String? payload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = NavigationRoute.detailRoute; // Sekarang ini adalah String
    payload = notificationResponse?.payload;
  }

  runApp(AppEntry(initialRoute: route, payload: payload));
}

class AppEntry extends StatelessWidget {
  final String initialRoute;
  final String? payload;

  const AppEntry({super.key, required this.initialRoute, this.payload});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => LocalDatabaseService()),
        Provider(
          create:
              (_) =>
                  RestaurantNotificationService()
                    ..init()
                    ..configureLocalTimeZone(),
        ),
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
        // ChangeNotifierProvider(
        //   create:
        //       (context) => RestaurantNotificationProvider(
        //         context.read<RestaurantNotificationService>(),
        //       ),
        // ),
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
      child: RestaurantApp(initialRoute: initialRoute),
    );
  }
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
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case NavigationRoute
                  .mainRoute: // Sekarang ini adalah const String
                return MaterialPageRoute(
                  builder: (_) => const NavigationScreen(),
                );
              case NavigationRoute
                  .detailRoute: // Sekarang ini adalah const String
                final args = settings.arguments;
                if (args is Map<String, String>) {
                  // Navigasi dari Home, Search, atau Favorite
                  return MaterialPageRoute(
                    builder:
                        (_) => DetailScreen(
                          restaurantId: args['id']!,
                          heroTag: args['heroTag']!,
                        ),
                  );
                } else if (args is String) {
                  // Navigasi dari Notifikasi
                  return MaterialPageRoute(
                    builder:
                        (_) => DetailScreen(
                          restaurantId: args,
                          heroTag: 'notification_$args',
                        ),
                  );
                }
            }
            // Jika route tidak ditemukan atau argumen tidak valid
            return null;
          },
        );
      },
    );
  }
}
