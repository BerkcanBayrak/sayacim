import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      fontFamily: 'Lexend',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 32.0),
        headlineMedium: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 24.0),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16.0),
        bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF6F8F6),
      cardColor: Colors.white,
      fontFamily: 'Lexend',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFF112117), fontWeight: FontWeight.bold, fontSize: 32.0),
        headlineMedium: TextStyle(color: Color(0xFF112117), fontWeight: FontWeight.bold, fontSize: 24.0),
        bodyLarge: TextStyle(color: Color(0xFF112117), fontSize: 16.0),
        bodyMedium: TextStyle(color: Color(0xFF6b7280), fontSize: 14.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF112117),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8F6),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Color(0xFF112117),
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
      ),
    );
  }
}
