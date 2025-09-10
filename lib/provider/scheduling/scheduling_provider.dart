import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/restaurant_notification_service.dart';

class SchedulingProvider extends ChangeNotifier {
  bool _isDailyRestaurantActive = false;
  bool get isDailyRestaurantActive => _isDailyRestaurantActive;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay get selectedTime => _selectedTime;

  bool _hasPendingNotifications = false;
  bool get hasPendingNotifications => _hasPendingNotifications;

  final RestaurantNotificationService _notificationService;

  static const String _timeKey = 'dailyRestaurantTime';

  SchedulingProvider({
    required RestaurantNotificationService notificationService,
  }) : _notificationService = notificationService {
    Future.microtask(() async {
      await _loadDailyRestaurantStatus();
      await _loadSelectedTime();
      await _checkPendingNotifications();
    });
  }

  Future<void> _loadDailyRestaurantStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyRestaurantActive =
        prefs.getBool('isDailyRestaurantActive') ?? false;
    notifyListeners();
  }

  Future<void> _loadSelectedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_timeKey);
    if (timeString != null) {
      final parts = timeString.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    notifyListeners();
  }

  Future<void> _saveSelectedTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = '${time.hour}:${time.minute}';
    await prefs.setString(_timeKey, timeString);
  }

  Future<bool> scheduledRestaurants(bool value) async {
    if (value) {
      final permissionGranted = await _notificationService.requestPermissions();
      if (permissionGranted == true) {
        await enableDailyRestaurants(true);
        return true;
      } else {
        // Izin ditolak atau terjadi error
        return false;
      }
    } else {
      // Menonaktifkan selalu dianggap berhasil
      await enableDailyRestaurants(false);
      return true;
    }
  }

  Future<void> enableDailyRestaurants(bool value) async {
    _isDailyRestaurantActive = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDailyRestaurantActive', value);
    notifyListeners();

    if (value) {
      await _notificationService.scheduleDailyNotification(
        _selectedTime.hour,
        _selectedTime.minute,
      );
    } else {
      await _notificationService.cancelAllNotifications();
    }

    await _checkPendingNotifications();
  }

  Future<void> selectTime(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (newTime != null) {
      _selectedTime = newTime;
      await _saveSelectedTime(newTime);
      notifyListeners();

      if (_isDailyRestaurantActive) {
        await _notificationService.scheduleDailyNotification(
          _selectedTime.hour,
          _selectedTime.minute,
        );
      }
    }
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
