import 'package:flutter/material.dart';

/// 산책 추천 엔티티
class WalkRecommendationEntity {
  /// 최소 권장 시간 (분)
  final int minMinutes;

  /// 최대 권장 시간 (분)
  final int maxMinutes;

  /// 위험 레벨 (0: safe, 1: low, 2: medium, 3: high, 4: extreme)
  final int riskLevel;

  /// 위험 레벨 텍스트
  final String riskLevelText;

  /// 사용자에게 보여줄 메시지
  final String message;

  /// 추가 주의사항
  final List<String> warnings;

  /// 계산에 사용된 요소들
  final Map<String, dynamic> calculationDetails;

  const WalkRecommendationEntity({
    required this.minMinutes,
    required this.maxMinutes,
    required this.riskLevel,
    required this.riskLevelText,
    required this.message,
    this.warnings = const [],
    this.calculationDetails = const {},
  });

  /// 권장 시간 범위 문자열
  String get timeRangeText => '$minMinutes〜$maxMinutes分';

  /// 안전 여부
  bool get isSafe => riskLevel <= 1;

  /// 위험 여부
  bool get isDangerous => riskLevel >= 3;

  /// 위험 레벨 색상
  Color get riskColor {
    switch (riskLevel) {
      case 0:
        return const Color(0xFF4CAF50); // safe - 초록
      case 1:
        return const Color(0xFF8BC34A); // low - 연두
      case 2:
        return const Color(0xFFFFC107); // medium - 노랑
      case 3:
        return const Color(0xFFFF9800); // high - 오렌지
      case 4:
        return const Color(0xFFF44336); // extreme - 빨강
      default:
        return const Color(0xFF9E9E9E); // 회색
    }
  }

  /// 위험 레벨 아이콘
  IconData get riskIcon {
    switch (riskLevel) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.info;
      case 2:
        return Icons.warning;
      case 3:
        return Icons.error;
      case 4:
        return Icons.dangerous;
      default:
        return Icons.help;
    }
  }

  /// 추천 이모지
  String get recommendationEmoji {
    switch (riskLevel) {
      case 0:
        return '✅';
      case 1:
        return 'ℹ️';
      case 2:
        return '⚠️';
      case 3:
        return '🚨';
      case 4:
        return '🛑';
      default:
        return '❓';
    }
  }

  WalkRecommendationEntity copyWith({
    int? minMinutes,
    int? maxMinutes,
    int? riskLevel,
    String? riskLevelText,
    String? message,
    List<String>? warnings,
    Map<String, dynamic>? calculationDetails,
  }) {
    return WalkRecommendationEntity(
      minMinutes: minMinutes ?? this.minMinutes,
      maxMinutes: maxMinutes ?? this.maxMinutes,
      riskLevel: riskLevel ?? this.riskLevel,
      riskLevelText: riskLevelText ?? this.riskLevelText,
      message: message ?? this.message,
      warnings: warnings ?? this.warnings,
      calculationDetails: calculationDetails ?? this.calculationDetails,
    );
  }
}
