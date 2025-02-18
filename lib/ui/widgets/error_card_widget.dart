import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ErrorCardWidget extends StatelessWidget {
  final String message;
  final Function() onTap;
  const ErrorCardWidget({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Oops!',
          style: AppTextStyles.textThemeCustom.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.textThemeCustom.bodyLarge,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onTap,
          child: const Text('Coba Lagi'),
        ),
      ],
    );
  }
}
