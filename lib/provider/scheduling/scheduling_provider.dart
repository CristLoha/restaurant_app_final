import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/restaurant_notification_service.dart';

class SchedulingProvider extends ChangeNotifier {
  bool _isDailyRestaurantActive = false;
  bool get isDailyRestaurantActive => _isDailyRestaurantActive;

  bool _hasPendingNotifications = false;
  bool get hasPendingNotifications => _hasPendingNotifications;

  final RestaurantNotificationService _notificationService;

  SchedulingProvider({
    required RestaurantNotificationService notificationService,
  }) : _notificationService = notificationService {
    Future.microtask(() async {
      await _loadDailyRestaurantStatus();
      await _checkPendingNotifications();
    });
  }

  Future<void> _loadDailyRestaurantStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyRestaurantActive =
        prefs.getBool('isDailyRestaurantActive') ?? false;
    notifyListeners();
  }

  Future<void> enableDailyRestaurants(bool value) async {
    _isDailyRestaurantActive = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDailyRestaurantActive', value);
    notifyListeners();

    if (value) {
      await _notificationService.scheduleDailyNotification(11, 0);
    } else {
      await _notificationService.cancelAllNotifications();
    }

    await _checkPendingNotifications();
  }

  Future<void> _checkPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    _hasPendingNotifications = pending.isNotEmpty;
    notifyListeners();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationService.getPendingNotifications();
  }
}
