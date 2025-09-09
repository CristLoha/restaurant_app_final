import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/scheduling/restaurant_notfication_provider.dart';
import 'package:restaurant_app_final/provider/scheduling/scheduling_provider.dart';

class BuildDailyReminderSectionWidget extends StatelessWidget {
  const BuildDailyReminderSectionWidget({super.key});

  Future<void> _handleReminderToggle(
    BuildContext context,
    bool newValue,
  ) async {
    final schedulingProvider = context.read<SchedulingProvider>();
    final notificationProvider = context.read<RestaurantNotificationProvider>();

    if (newValue) {
      final permissionGranted = await notificationProvider.requestPermission();
      if (permissionGranted == true) {
        await schedulingProvider.enableDailyRestaurants(true);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin notifikasi ditolak. Pengingat tidak dapat diaktifkan.',
              ),
            ),
          );
        }
      }
    } else {
      await schedulingProvider.enableDailyRestaurants(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchedulingProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Restaurant Reminder'),
              trailing: Switch.adaptive(
                value: provider.isDailyRestaurantActive,
                onChanged: (value) => _handleReminderToggle(context, value),
              ),
            ),
            if (provider.isDailyRestaurantActive)
              ListTile(
                title: const Text('Waktu Pengingat'),
                subtitle: Text(provider.selectedTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => provider.selectTime(context),
              ),
          ],
        );
      },
    );
  }
}
