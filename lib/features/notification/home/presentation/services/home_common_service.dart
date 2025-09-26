import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 홈 기능에서 공통으로 사용되는 유틸리티 서비스
class HomeCommonService {
  /// 시간 포맷팅 헬퍼
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 현재 시간 문자열 생성
  static String getCurrentTimeString() {
    final now = DateTime.now();
    return formatTime(now);
  }

  /// 예약 시간까지의 차이 계산
  static Duration getTimeDifference(DateTime scheduledTime) {
    return scheduledTime.difference(DateTime.now());
  }

  /// 예약 알림 메시지 생성
  static String generateAppointmentNotification(
    AppointmentSummary appointment,
  ) {
    final timeDifference = getTimeDifference(appointment.scheduledTime);

    if (timeDifference.inHours <= 24 && timeDifference.inHours > 0) {
      return '${appointment.petName}の${appointment.type}予約が明日${formatTime(appointment.scheduledTime)}に予定されています。';
    } else if (timeDifference.inHours <= 2 && timeDifference.inHours > 0) {
      return '${appointment.petName}の${appointment.type}予約が${timeDifference.inHours}時間後にあります。';
    } else if (timeDifference.inHours <= 0 && timeDifference.inMinutes > -30) {
      return '${appointment.petName}の${appointment.type}予約が${timeDifference.inMinutes.abs()}分前に予定されていました。';
    }

    return '${appointment.petName}の${appointment.type}予約が${formatTime(appointment.scheduledTime)}に予定されています。';
  }

  /// 산책 알림 메시지 생성
  static String generateWalkNotification(WalkSummary walkSummary) {
    final now = DateTime.now();

    // 오늘 산책을 한 번도 안 했을 경우 (오후 6시 이후)
    if (walkSummary.todayWalks == 0 && now.hour >= 18) {
      return '今日はまだ散歩していません。ペットと一緒に散歩してみませんか！';
    }

    // 주간 목표 달성률이 낮을 경우
    final weeklyProgress =
        (walkSummary.weeklyProgress / walkSummary.weeklyGoal * 100);
    if (weeklyProgress < 50 && now.weekday >= 5) {
      return '今週の散歩目標達成率が${weeklyProgress.toInt()}%です。もう少し頑張ってみましょう！';
    }

    return '散歩目標達成率: ${weeklyProgress.toInt()}%';
  }

  /// 건강 알림 메시지 생성
  static String generateHealthNotification(HealthSummary healthSummary) {
    if (healthSummary.petsNeedingAttention > 0) {
      return '注意が必要なペットが${healthSummary.petsNeedingAttention}匹います。';
    }
    return 'すべてのペットが健康です。';
  }

  /// 결과 성공 여부 확인 헬퍼
  static bool isResultSuccess<T>(Result<T> result) {
    return result.isSuccess;
  }

  /// 결과 데이터 추출 헬퍼
  static T? getResultData<T>(Result<T> result) {
    return result.dataOrNull;
  }

  /// 결과 에러 메시지 추출 헬퍼
  static String? getResultError<T>(Result<T> result) {
    return result.errorOrNull;
  }

  /// 여러 결과의 성공 여부 확인
  static bool areAllResultsSuccess(List<Result> results) {
    return results.every((result) => result.isSuccess);
  }

  /// 여러 결과에서 첫 번째 실패 결과 찾기
  static Result? getFirstFailureResult(List<Result> results) {
    return results.firstWhere(
      (result) => result.isFailure,
      orElse: () => throw StateError('No failure results found'),
    );
  }

  /// 데이터 로딩 상태 확인
  static Map<String, bool> getLoadingStates({
    bool isLoadingWeather = false,
    bool isLoadingPets = false,
    bool isLoadingWalk = false,
    bool isLoadingHealth = false,
    bool isLoadingAppointments = false,
  }) {
    return {
      'weather': isLoadingWeather,
      'pets': isLoadingPets,
      'walk': isLoadingWalk,
      'health': isLoadingHealth,
      'appointments': isLoadingAppointments,
    };
  }

  /// 전체 로딩 상태 확인
  static bool isAnyLoading(Map<String, bool> loadingStates) {
    return loadingStates.values.any((isLoading) => isLoading);
  }

  /// 로딩 완료 상태 확인
  static bool isAllLoaded(Map<String, bool> loadingStates) {
    return loadingStates.values.every((isLoading) => !isLoading);
  }
}
