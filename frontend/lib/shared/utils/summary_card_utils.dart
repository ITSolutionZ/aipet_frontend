import 'package:flutter/material.dart';

/// 🎯 Summary Card 데이터 처리 유틸리티
///
/// 모든 summary card에서 공통으로 사용하는 데이터 처리 로직
class SummaryCardUtils {
  /// 완료된 항목 수와 전체 항목 수를 포맷팅
  ///
  /// 예: completed=2, total=3 → "2/3"
  static String formatProgress(int completed, int total) {
    return '$completed/$total';
  }

  /// 퍼센트 값을 포맷팅
  ///
  /// 예: 0.75 → "75%"
  static String formatPercentage(double value) {
    return '${(value * 100).round()}%';
  }

  /// 거리 값을 포맷팅
  ///
  /// 예: 3.2 → "3.2 km"
  static String formatDistance(double distance) {
    return '${distance.toStringAsFixed(1)} km';
  }

  /// 체중 값을 포맷팅
  ///
  /// 예: 15.5 → "15.5 kg"
  static String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// 변화량을 포맷팅 (양수/음수 표시)
  ///
  /// 예: 0.5 → "+0.5", -0.3 → "-0.3"
  static String formatChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}';
  }

  /// 시간을 포맷팅
  ///
  /// 예: DateTime.now() → "14:30"
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 상대 시간을 포맷팅
  ///
  /// 예: DateTime.now().add(Duration(hours: 2)) → "2時間後"
  static String formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}日後';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間後';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分後';
    } else {
      return '今すぐ';
    }
  }

  /// 진행률에 따른 색상 반환
  ///
  /// 0.8 이상: 녹색, 0.6 이상: 주황색, 그 외: 빨간색
  static Color getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.orange;
    return Colors.red;
  }

  /// 변화량에 따른 색상 반환
  ///
  /// 양수: 녹색, 음수: 빨간색, 0: 회색
  static Color getChangeColor(double change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  /// 변화량에 따른 아이콘 반환
  ///
  /// 양수: 위쪽 화살표, 음수: 아래쪽 화살표, 0: 대시
  static IconData getChangeIcon(double change) {
    if (change > 0) return Icons.trending_up;
    if (change < 0) return Icons.trending_down;
    return Icons.remove;
  }

  /// 안전한 숫자 변환
  ///
  /// null이거나 변환 불가능한 경우 기본값 반환
  static double safeDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// 안전한 정수 변환
  ///
  /// null이거나 변환 불가능한 경우 기본값 반환
  static int safeInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// 안전한 문자열 변환
  ///
  /// null이거나 빈 문자열인 경우 기본값 반환
  static String safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString().isEmpty ? defaultValue : value.toString();
  }
}
