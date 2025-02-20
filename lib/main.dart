import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/api/api_service.dart';
import 'data/local/local_database_service.dart';
import 'provider/detail/restaurant_detail_provider.dart';
import 'provider/favorite/local_database_provider.dart';
import 'provider/home/restaurant_list_provider.dart';
import 'provider/navigation/navigation_provider.dart';
import 'provider/scheduling/payload_provider.dart';
import 'provider/scheduling/restaurant_notfication_provider.dart';
import 'provider/scheduling/scheduling_provider.dart';
import 'provider/search/restaurant_search_provider.dart';
import 'provider/theme/theme_provider.dart';
import 'services/restaurant_notification_service.dart';
import 'static/navigation_route.dart';
import 'ui/screens/detail/detail_screen.dart';
import 'ui/screens/navigation/navigation_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String route = NavigationRoute.mainRoute.name;
  String? payload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = NavigationRoute.detailRoute.name;
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
          routes: {
            NavigationRoute.mainRoute.name:
                (context) => const NavigationScreen(),
            NavigationRoute.detailRoute.name: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              return DetailScreen(tourismId: args is String ? args : '');
            },
          },
        );
      },
    );
  }
}
