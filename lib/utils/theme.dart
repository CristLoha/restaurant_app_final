import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: AppColors.surface,
      onSurface: Colors.black,
      error: AppColors.error,
      onError: Colors.white,
      primaryContainer: AppColors.primaryVariant,
      onPrimaryContainer: Colors.white,
      secondaryContainer: AppColors.secondaryVariant,
      onSecondaryContainer: Colors.white,
    ),
    textTheme: AppTextStyles.textThemeCustom,
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTextStyles.textThemeCustom,
    useMaterial3: true,
  );
}

class AppColors {
  static const Color primary = Color(0xFFE53935);
  static const Color primaryVariant = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFF1E88E5);
  static const Color secondaryVariant = Color(0xFF1976D2);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color yellow = Color(0xFFFFD600);
}

class AppTextStyles {
  static final TextTheme textThemeCustom = TextTheme(
    displayLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 57,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 45,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 32,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),

    titleLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 22,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );
}
