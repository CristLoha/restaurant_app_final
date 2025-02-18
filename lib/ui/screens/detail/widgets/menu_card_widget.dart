import 'package:flutter/material.dart';
import '../../../../utils/theme.dart';

class MenuCardWidget extends StatelessWidget {
  final String menuName;

  const MenuCardWidget({
    super.key,
    required this.menuName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          menuName,
          style: AppTextStyles.textThemeCustom.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
