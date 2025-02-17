import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class RestaurantNotificationService {
  bool _isRequestingPermission = false;

  Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );

    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        false;
  }

  Future<bool?> requestPermissions() async {
    if (_isRequestingPermission) return null;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iOSImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >();
        return await iOSImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        final requestNotificationPermission =
            await androidImplementation?.requestNotificationsPermission();
        final notificationEnabled = await _isAndroidPermissionGranted();
        final requestAlarmEnabled = await _requestExactAlarmsPermission();

        return (requestNotificationPermission ?? false) &&
            notificationEnabled &&
            requestAlarmEnabled;
      } else {
        return false;
      }
    } catch (e) {
      log('Error requesting permissions: $e');
    } finally {
      _isRequestingPermission = false;
    }
    return null;
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones(); // Inisialisasi zona waktu dari package timezone
    final String timeZoneName =
        await FlutterTimezone.getLocalTimezone(); // Ambil zona waktu perangkat
    tz.setLocalLocation(
      tz.getLocation(timeZoneName),
    ); // Set lokasi zona waktu yang sesuai
  }

  Future<bool> _requestExactAlarmsPermission() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestExactAlarmsPermission() ??
        false;
  }

  Future<void> scheduleDailyNotification(int hour, int minute) async {
    await configureLocalTimeZone();

    final apiService = ApiService();
    final randomRestaurant = await apiService.getRandomRestaurant();

    if (randomRestaurant == null) {
      log('Tidak ada restoran yang tersedia.');
      return;
    }

    final notificationId = hour * 100 + minute;

    await showNotification(
      id: notificationId,
      title: randomRestaurant.name,
      body: "Rekomendasi Restoran untuk kamu",
      payload: randomRestaurant.id,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required int hour,
    required int minute,
    String channelId = "restaurant_reminder",
    String channelName = "Restaurant Reminder",
  }) async {
    try {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          );

      final notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log("Notifikasi berhasil dijadwalkan untuk $hour:$minute");
    } catch (e, stackTrace) {
      log(
        "Error menjadwalkan notifikasi: $e",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<bool> isNotificationScheduled() async {
    final pendingNotifications = await getPendingNotifications();
    return pendingNotifications.isNotEmpty;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
