import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/scheduling/scheduling_provider.dart';
import 'widgets/build_reminder_section_widget.dart';
import 'widgets/build_theme_section_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BuildThemeSectionWidget(),
          BuildDailyReminderSectionWidget(),
          Consumer<SchedulingProvider>(
            builder: (context, provider, _) {
              return Consumer<SchedulingProvider>(
                builder: (context, provider, _) {
                  return ListTile(
                    title: const Text('Cek Pending Notifications'),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.notifications_active,
                        color:
                            provider.hasPendingNotifications
                                ? Colors.red
                                : Colors.grey,
                      ),
                      onPressed: () async {
                        final pending =
                            await provider.getPendingNotifications();
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Pending Notifications'),
                                  content: Text(
                                    pending.isNotEmpty
                                        ? '${pending.length} pengingat restoran telah dijadwalkan.'
                                        : 'Saat ini tidak ada pengingat restoran yang terjadwal.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
