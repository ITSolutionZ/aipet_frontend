import 'package:flutter/material.dart';

import '../../../../../features/daily/domain/entities/daily_health_record.dart';

/// 헬스 상태 관련 유틸리티 클래스
///
/// 헬스 상태의 텍스트 변환, 아이콘 변환 등의 기능을 제공
class HealthStatusUtils {
  HealthStatusUtils._();

  /// 헬스 상태를 표시용 텍스트로 변환
  static String getHealthStatusText(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return 'とても良い';
      case HealthStatus.good:
        return '良い';
      case HealthStatus.fair:
        return '普通';
      case HealthStatus.poor:
        return '悪い';
      case HealthStatus.critical:
        return '危険';
    }
  }

  /// 헬스 상태에 해당하는 아이콘 반환
  static IconData getHealthStatusIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return Icons.sentiment_very_satisfied;
      case HealthStatus.good:
        return Icons.sentiment_satisfied;
      case HealthStatus.fair:
        return Icons.sentiment_neutral;
      case HealthStatus.poor:
        return Icons.sentiment_dissatisfied;
      case HealthStatus.critical:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  /// 헬스 상태에 해당하는 색상 반환
  static Color getHealthStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return Colors.green;
      case HealthStatus.good:
        return Colors.lightGreen;
      case HealthStatus.fair:
        return Colors.orange;
      case HealthStatus.poor:
        return Colors.redAccent;
      case HealthStatus.critical:
        return Colors.red;
    }
  }

  /// 모든 헬스 상태 옵션을 라디오 옵션 형태로 반환
  static List<Map<String, dynamic>> getHealthStatusOptions() {
    return HealthStatus.values.map((status) {
      return {
        'value': status,
        'label': getHealthStatusText(status),
        'icon': getHealthStatusIcon(status),
        'color': getHealthStatusColor(status),
      };
    }).toList();
  }

  /// 증상 목록 반환
  static List<String> getAvailableSymptoms() {
    return [
      '食欲不振',
      '下痢',
      '嘔吐',
      '咳',
      'くしゃみ',
      '元気がない',
      '歩き方がおかしい',
      '皮膚の異常',
      '目の異常',
      '耳の異常',
    ];
  }
}
