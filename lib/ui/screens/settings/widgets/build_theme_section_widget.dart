import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app_final/provider/theme/theme_provider.dart';
import 'package:restaurant_app_final/utils/theme.dart';


class BuildThemeSectionWidget extends StatelessWidget {
  const BuildThemeSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Theme',
                style: AppTextStyles.textThemeCustom.bodyMedium!.copyWith(
                  fontSize: 18,
                ),
              ),
            ),
            RadioListTile(
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
              title: Text('Light Mode'),
            ),
            RadioListTile(
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
              title: Text('Dark Mode'),
            ),
            RadioListTile(
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) => themeProvider.setTheme(value!),
              title: Text('System Mode'),
            ),
          ],
        );
      },
    );
  }
}
