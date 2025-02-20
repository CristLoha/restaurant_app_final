import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/data/model/received_notification.dart';
import 'package:restaurant_app_final/provider/navigation/navigation_provider.dart';
import 'package:restaurant_app_final/provider/scheduling/payload_provider.dart';
import 'package:restaurant_app_final/services/restaurant_notification_service.dart';
import 'package:restaurant_app_final/static/navigation_route.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) {
      if (payload != null) {
        if (mounted) {
          context.read<PayloadProvider>().payload = payload;
          Navigator.pushNamed(
            context,
            NavigationRoute.detailRoute.name,
            arguments: payload,
          );
        }
      }
    });
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((
      ReceivedNotification receivedNotification,
    ) {
      final payload = receivedNotification.payload;
      if (payload != null) {
        if (mounted) {
          context.read<PayloadProvider>().payload = payload;
          Navigator.pushNamed(
            context,
            NavigationRoute.detailRoute.name,
            arguments: payload,
          );
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _configureSelectNotificationSubject();
      _configureDidReceiveLocalNotificationSubject();
    });
  }

  @override
  void dispose() {
    selectNotificationStream.close();
    didReceiveLocalNotificationStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: navigationProvider.currentPage,
      bottomNavigationBar: SizedBox(
        height: 100,
        child: BottomNavigationBar(
          key: const Key('bottom_nav_bar'),
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationProvider.currentIndex,
          onTap: navigationProvider.setIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
