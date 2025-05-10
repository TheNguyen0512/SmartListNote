import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

class AppTheme {
  // Theme sáng
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true, // Kích hoạt Material 3
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: AppSizes.fontMedium,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: AppSizes.fontSmall,
        color: AppColors.textSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        textStyle: TextStyle(fontSize: AppSizes.fontMedium),
        minimumSize: const Size(
          150,
          48,
        ), // Kích thước cố định, điều chỉnh trong widget nếu cần responsive
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(AppSizes.paddingSmall),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.textSecondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondary),
      contentPadding: EdgeInsets.all(AppSizes.paddingSmall),
    ),
  );

  // Theme tối
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true, // Kích hoạt Material 3
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: AppSizes.fontTitle,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: AppSizes.fontMedium, color: Colors.white),
      bodyMedium: TextStyle(
        fontSize: AppSizes.fontSmall,
        color: Colors.grey[400],
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingSmall,
        ),
        textStyle: TextStyle(fontSize: AppSizes.fontMedium),
        minimumSize: const Size(150, 48), // Kích thước cố định
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.grey[800],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(AppSizes.paddingSmall),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[600]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey[400]),
      contentPadding: EdgeInsets.all(AppSizes.paddingSmall),
    ),
  );

  ThemeData getTheme(BuildContext context) {
    final hour = DateTime.now().hour;
    return hour >= 18 ? darkTheme : lightTheme;
  }
}
