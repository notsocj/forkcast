import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        primary: AppColors.primaryAccent,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.primaryBackground,
      fontFamily: 'Lato',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: AppColors.blackText,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: AppColors.blackText,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppColors.blackText,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Lato',
          fontSize: 16,
          color: AppColors.blackText,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Lato',
          fontSize: 14,
          color: AppColors.grayText,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12,
          color: AppColors.grayText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  // Prevent instantiation
  AppTheme._();
}