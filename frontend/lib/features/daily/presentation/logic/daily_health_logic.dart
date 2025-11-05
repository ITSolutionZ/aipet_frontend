import 'package:aipet_frontend/shared/core/services/date_format_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../features/daily/domain/entities/daily_health_record.dart';

/// Daily Health Logic
///
/// **역할**: 일일 건강 화면의 UI 로직 및 헬퍼 함수 모음
/// - 화면 네비게이션 (GoRouter)
/// - UI 상수 및 메시지
/// - 빠른 액션 데이터 생성
///
/// **특징**:
/// - 상태를 가지지 않는 순수 함수 중심
/// - UI 표시와 관련된 로직만 포함
/// - 비즈니스 로직은 DailyHealthController에서 처리
/// - 날짜/시간 포맷팅은 shared/DateFormatService 사용
///
/// **사용 위치**: DailyHealthScreen에서 사용
/// **관련 파일**: DailyHealthController (상태 관리 및 비즈니스 로직)
class DailyHealthLogic {
  DailyHealthLogic();

  /// 앱바 제목
  String get appBarTitle => '';

  /// 펫 선택 초기화 로직
  String? initializePetSelection(List<dynamic>? pets) {
    if (pets != null && pets.isNotEmpty) {
      return pets.first.id;
    }
    return null;
  }

  /// 날짜 포맷팅 (shared 서비스 사용)
  String formatDate(DateTime date) {
    return DateFormatService.formatDateJapanese(date);
  }

  /// 요일 이름 가져오기 (shared 서비스 사용)
  String getWeekdayName(int weekday) {
    return DateFormatService.getWeekdayNameJapanese(weekday);
  }

  /// 퀵 액션 데이터 생성
  List<QuickActionData> getQuickActions({
    required VoidCallback onTemperatureRecord,
    required VoidCallback onSymptomRecord,
    required VoidCallback onMedicationRecord,
    required VoidCallback onHospitalBooking,
  }) {
    return [
      QuickActionData(
        title: '体温記録',
        icon: Icons.thermostat,
        color: const Color(0xFFE74C3C),
        onTap: onTemperatureRecord,
      ),
      QuickActionData(
        title: '症状記録',
        icon: Icons.medical_services,
        color: const Color(0xFFFF9500),
        onTap: onSymptomRecord,
      ),
      QuickActionData(
        title: '薬の記録',
        icon: Icons.medication,
        color: const Color(0xFF007AFF),
        onTap: onMedicationRecord,
      ),
      QuickActionData(
        title: '病院予約',
        icon: Icons.local_hospital,
        color: const Color(0xFF34C759),
        onTap: onHospitalBooking,
      ),
    ];
  }

  /// 건강 기록 입력 화면으로 네비게이션
  void navigateToHealthInput(BuildContext context, DailyHealthRecord? record) {
    context.push('/home/daily/input', extra: record);
  }

  /// 히스토리 화면으로 네비게이션
  void navigateToHistoryScreen(BuildContext context) {
    context.push('/home/daily/history');
  }

  /// 캘린더 화면으로 네비게이션
  void navigateToCalendarScreen(BuildContext context) {
    context.push('/facility-calendar');
  }

  /// 병원 검색 화면으로 네비게이션
  void navigateToHospitalSearch(BuildContext context) {
    context.push('/home/calendar');
  }

  /// 펫 등록 화면으로 네비게이션
  void navigateToPetRegistration(BuildContext context) {
    context.push('/daily-pet-registration');
  }

  /// 에러 메시지 생성
  String getErrorMessage(Object error) {
    return 'エラーが発生しました: $error';
  }

  /// 로딩 메시지
  String get loadingMessage => '健康データを読み込み中...';

  /// 빈 상태 제목
  String get emptyStateTitle => 'ペットを選択してください';

  /// 빈 상태 부제목
  String get emptyStateSubtitle => '健康記録を確인するペットを選択してください';

  /// 빈 상태 액션 텍스트
  String get emptyStateActionText => 'ペットを追加';
}

/// 퀵 액션 데이터 클래스
class QuickActionData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
