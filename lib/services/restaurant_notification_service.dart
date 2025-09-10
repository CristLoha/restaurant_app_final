import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:restaurant_app_final/data/api/api_service.dart';
import 'package:restaurant_app_final/data/model/received_notification.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class RestaurantNotificationService {
  bool _isRequestingPermission = false;

  Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );

    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (
        int id,
        String? title,
        String? body,
        String? payload,
      ) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        log("Notifikasi ditekan! Payload: ${notificationResponse.payload}");
        final payload = notificationResponse.payload;
        if (payload != null && payload.isNotEmpty) {
          selectNotificationStream.add(payload);
        }
      },
    );
  }


  Future<bool?> requestPermissions() async {
    if (_isRequestingPermission) return null; // Prevent re-entry
    _isRequestingPermission = true;
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

        final bool? notificationPermissionGranted =
            await androidImplementation?.requestNotificationsPermission();

        // Jika izin notifikasi standar tidak diberikan, kita tidak bisa lanjut.
        if (notificationPermissionGranted != true) {
          return false;
        }

        // The exact alarm permission is implicitly requested by the system when a
        // notification is scheduled with `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle`.
        // We only need to ensure the standard notification permission is granted.
        return true;
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
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
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

  Future<void> showInstantNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    try {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "restaurant_reminder",
        "Restaurant Reminder",
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
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      log("Gagal menampilkan notifikasi instan: $e");
    }
  }
}
