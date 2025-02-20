import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/scheduling/restaurant_notfication_provider.dart';
import 'package:restaurant_app_final/provider/scheduling/scheduling_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildDailyReminderSectionWidget extends StatelessWidget {
  const BuildDailyReminderSectionWidget({super.key});

  Future<void> _handleReminderToggle(
    BuildContext context,
    bool newValue,
  ) async {
    final schedulingProvider = context.read<SchedulingProvider>();
    final notificationProvider = context.read<RestaurantNotificationProvider>();

    if (newValue) {
      final prefs = await SharedPreferences.getInstance();
      bool hasRequestedPermission =
          prefs.getBool('hasRequestedPermission') ?? false;

      if (!hasRequestedPermission) {
        await notificationProvider.requestPermission();
        await prefs.setBool('hasRequestedPermission', true);
      }
    }

    schedulingProvider.enableDailyRestaurants(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchedulingProvider>(
      builder: (context, provider, _) {
        return ListTile(
          title: const Text('Restaurant Reminder'),
          trailing: Switch.adaptive(
            value: provider.isDailyRestaurantActive,
            onChanged: (value) => _handleReminderToggle(context, value),
          ),
        );
      },
    );
  }
}
