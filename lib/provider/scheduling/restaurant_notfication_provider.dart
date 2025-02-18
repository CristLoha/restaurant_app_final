import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../services/restaurant_notification_service.dart';

class RestaurantNotificationProvider extends ChangeNotifier {
  final RestaurantNotificationService notificationService;

  RestaurantNotificationProvider(this.notificationService) {
    _initialize();
  }

  bool? _permission = false;

  bool? get permission => _permission;

  List<PendingNotificationRequest> pendingNotificationRequest = [];

  Future<void> requestPermission() async {
    _permission = await notificationService.requestPermissions();
    notifyListeners();
  }

  Future<void> scheduleDailyNotification(int hour, int minute) async {
    await notificationService.scheduleDailyNotification(hour, minute);
    notifyListeners();
  }

  Future<void> _initialize() async {
    await notificationService.requestPermissions();
    notifyListeners();
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
    required int hour,
    required int minute,
  }) async {
    final notificationId = hour * 100 + minute;
    await notificationService.showNotification(
      title: title,
      body: body,
      payload: payload,
      hour: hour,
      minute: minute,
      id: notificationId,
    );
    await checkPendingNotifications();
    notifyListeners();
  }

  Future<void> checkPendingNotifications() async {
    pendingNotificationRequest =
        await notificationService.getPendingNotifications();
    notifyListeners();
  }
}
