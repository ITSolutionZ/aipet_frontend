import 'package:flutter/material.dart';

/// Mock Data 공통 상수
///
/// 모든 Mock Data 서비스에서 공통으로 사용되는 상수들을 정의합니다.
class MockDataConstants {
  // ==================== 기본 이미지 경로 ====================

  /// 기본 플레이스홀더 이미지
  static const String placeholderImage = 'assets/images/placeholder.png';

  /// 기본 펫 이미지들
  static const Map<String, String> defaultPetImages = {
    'dog': 'assets/images/dogs/shiba.png',
    'cat': 'assets/images/cats/cats.png',
    'golden': 'assets/images/dogs/golden.png',
  };

  // ==================== 기본 색상 ====================

  /// 기본 브랜드 색상
  static const Color primaryColor = Color(0xFF8B5A2B);
  static const Color secondaryColor = Color(0xFF6B4423);
  static const Color accentColor = Color(0xFFF2A65A);

  // ==================== 기본 텍스트 ====================

  /// 기본 펫 이름들
  static const List<String> defaultPetNames = ['マックス', 'ルナ', 'バディ', 'ココ', 'モモ'];

  /// 기본 품종들
  static const Map<String, List<String>> defaultBreeds = {
    'dog': ['ゴールデンレトリバー', '柴犬', 'プードル', 'ラブラドール', 'ブルドッグ'],
    'cat': ['ペルシャ', 'メインクーン', 'シャム', 'ラグドール', 'ブリティッシュショートヘア'],
  };

  // ==================== 기본 시간 설정 ====================

  /// 기본 식사 시간들
  static const List<String> defaultMealTimes = [
    '08:00', // 아침
    '12:00', // 점심
    '18:00', // 저녁
  ];

  /// 기본 산책 시간들
  static const List<String> defaultWalkTimes = [
    '07:00', // 아침 산책
    '17:00', // 저녁 산책
  ];

  // ==================== 기본 수량 설정 ====================

  /// 기본 급여량 (g)
  static const Map<String, int> defaultFeedingAmounts = {
    'small': 80, // 소형
    'medium': 150, // 중형
    'large': 250, // 대형
  };

  /// 기본 산책 거리 (km)
  static const Map<String, double> defaultWalkDistances = {
    'small': 1.0, // 소형
    'medium': 2.0, // 중형
    'large': 3.0, // 대형
  };

  // ==================== 기본 상태값 ====================

  /// 기본 건강 상태들
  static const List<String> defaultHealthStatuses = [
    '健康',
    '疲れている',
    '食欲不振',
    '活発',
  ];

  /// 기본 식사 상태들
  static const List<String> defaultFeedingStatuses = ['完食', '残食', '拒食', '食欲旺盛'];

  // ==================== 기본 메시지 ====================

  /// 기본 성공 메시지
  static const String defaultSuccessMessage = '正常に処理されました';

  /// 기본 에러 메시지
  static const String defaultErrorMessage = 'エラーが発生しました';

  /// 기본 로딩 메시지
  static const String defaultLoadingMessage = '読み込み中...';

  // ==================== 기본 설정값 ====================

  /// 기본 페이지 크기
  static const int defaultPageSize = 20;

  /// 기본 새로고침 간격 (초)
  static const int defaultRefreshInterval = 30;

  /// 기본 캐시 유효 시간 (분)
  static const int defaultCacheExpiration = 60;
}
