import 'package:flutter/material.dart';
import 'color.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.pointBrown,
    scaffoldBackgroundColor: AppColors.pointOffWhite,
    colorScheme: const ColorScheme.light(
      primary: AppColors.pointBrown,
      secondary: AppColors.pointGreen,
      surface: AppColors.pointCream,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.pointDark,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.pointBrown,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.pointCream,
      elevation: 2,
      shadowColor: Colors.black12,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.pointCream,
      selectedItemColor: AppColors.pointBrown,
      unselectedItemColor: AppColors.pointGray,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: TextTheme(
      bodyMedium: AppTextStyles.body,
      titleLarge: AppTextStyles.h1,
    ),
  );
}
