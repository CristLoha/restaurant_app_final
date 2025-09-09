import 'package:flutter/material.dart';

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
          const BuildThemeSectionWidget(),
          const BuildDailyReminderSectionWidget(),
        ],
      ),
    );
  }
}
