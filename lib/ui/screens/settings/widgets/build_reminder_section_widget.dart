import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/scheduling/scheduling_provider.dart';

class BuildDailyReminderSectionWidget extends StatefulWidget {
  const BuildDailyReminderSectionWidget({super.key});

  @override
  State<BuildDailyReminderSectionWidget> createState() =>
      _BuildDailyReminderSectionWidgetState();
}

class _BuildDailyReminderSectionWidgetState
    extends State<BuildDailyReminderSectionWidget> {
  bool _isHandlingToggle = false;

  Future<void> _handleReminderToggle(BuildContext context, bool value) async {
    // Mencegah panggilan ganda jika toggle sedang diproses
    if (_isHandlingToggle) return;

    setState(() {
      _isHandlingToggle = true;
    });

    final schedulingProvider = context.read<SchedulingProvider>();
    await schedulingProvider.scheduledRestaurants(value);

    // Pastikan widget masih ada di tree sebelum melanjutkan
    if (mounted) {
      // Selesaikan proses loading
      setState(() {
        _isHandlingToggle = false;
      });
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
              trailing:
                  _isHandlingToggle
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                      : Switch.adaptive(
                        value: provider.isDailyRestaurantActive,
                        onChanged:
                            (value) => _handleReminderToggle(context, value),
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
