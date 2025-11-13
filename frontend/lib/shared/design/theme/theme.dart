import 'package:aipet_frontend/shared/design/text_styles.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent, // 새로운 그라데이션 AppBar는 투명 배경 사용
      foregroundColor: const Color(0xFF5B4034), // 다크 브라운 텍스트
      elevation: 1.0, // 가벼운 elevation
      shadowColor: Colors.black.withValues(alpha: 0.08), // 가벼운 그림자
      systemOverlayStyle: SystemUiOverlayStyle.dark, // 다크 상태바 아이콘
      iconTheme: const IconThemeData(
        color: Color(0xFF5B4034), // 다크 브라운 아이콘
      ),
      titleTextStyle: AppTextStyles.h1.copyWith(
        color: const Color(0xFF5B4034),
        fontWeight: FontWeight.w500,
      ),
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
