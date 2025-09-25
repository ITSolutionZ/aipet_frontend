import 'package:aipet_frontend/features/home/data/providers/home_usecase_providers.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/features/home/presentation/services/home_common_service.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_home_notification_controller.g.dart';

/// Riverpod 기반 홈 알림 컨트롤러
@riverpod
class RiverpodHomeNotificationController
    extends _$RiverpodHomeNotificationController {
  @override
  List<String> build() {
    return [];
  }

  /// 알림 처리 (리팩토링된 버전)
  Future<Result<List<String>>> handleNotification() async {
    try {
      final notifications = <String>[];

      // 대시보드 데이터 가져오기
      final getDashboardDataUseCase = ref.read(getDashboardDataUseCaseProvider);
      final result = await getDashboardDataUseCase.call();

      if (result.isFailure) {
        return ResultFactory.failure(result.errorOrNull ?? 'エラーが発生しました');
      }

      final dashboardData = result.dataOrNull;
      if (dashboardData == null) {
        return ResultFactory.failure('ダッシュボードデータがありません');
      }

      // 예정된 예약 알림 확인
      _addAppointmentNotifications(
        notifications,
        dashboardData.upcomingAppointments,
      );

      // 건강 상태 알림 확인
      _addHealthNotifications(notifications, dashboardData.petHealthSummary);

      // 산책 알림 확인
      _addWalkNotifications(notifications, dashboardData.walkSummary);

      // 상태 업데이트
      state = notifications;

      return ResultFactory.success(notifications, '通知が処理されました');
    } catch (error) {
      return ResultFactory.failure('알림 처리 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// 예약 알림 추가
  void _addAppointmentNotifications(
    List<String> notifications,
    List<AppointmentSummary> appointments,
  ) {
    for (final appointment in appointments) {
      final timeDifference = HomeCommonService.getTimeDifference(
        appointment.scheduledTime,
      );

      // 24시간 이내 예약 알림
      if (timeDifference.inHours <= 24 && timeDifference.inHours > 0) {
        notifications.add(
          HomeCommonService.generateAppointmentNotification(appointment),
        );
      }
      // 2시간 이내 예약 알림
      else if (timeDifference.inHours <= 2 && timeDifference.inHours > 0) {
        notifications.add(
          HomeCommonService.generateAppointmentNotification(appointment),
        );
      }
    }
  }

  /// 건강 알림 추가
  void _addHealthNotifications(
    List<String> notifications,
    HealthSummary healthSummary,
  ) {
    // 건강 상태 알림
    final healthNotification = HomeCommonService.generateHealthNotification(
      healthSummary,
    );
    if (healthNotification.isNotEmpty) {
      notifications.add(healthNotification);
    }

    // 건강 알림 확인
    for (final alert in healthSummary.alerts) {
      notifications.add('${alert.petName}: ${alert.message}');
    }
  }

  /// 산책 알림 추가
  void _addWalkNotifications(
    List<String> notifications,
    WalkSummary walkSummary,
  ) {
    final walkNotification = HomeCommonService.generateWalkNotification(
      walkSummary,
    );
    if (walkNotification.isNotEmpty) {
      notifications.add(walkNotification);
    }
  }

  /// 특정 타입의 알림만 처리
  Future<Result<List<String>>> handleSpecificNotification({
    bool includeAppointments = true,
    bool includeHealth = true,
    bool includeWalk = true,
  }) async {
    try {
      final notifications = <String>[];

      // 대시보드 데이터 가져오기
      final getDashboardDataUseCase = ref.read(getDashboardDataUseCaseProvider);
      final result = await getDashboardDataUseCase.call();

      if (result.isFailure) {
        return ResultFactory.failure(result.errorOrNull ?? 'エラーが発生しました');
      }

      final dashboardData = result.dataOrNull;
      if (dashboardData == null) {
        return ResultFactory.failure('ダッシュボードデータがありません');
      }

      // 선택된 알림 타입만 처리
      if (includeAppointments) {
        _addAppointmentNotifications(
          notifications,
          dashboardData.upcomingAppointments,
        );
      }

      if (includeHealth) {
        _addHealthNotifications(notifications, dashboardData.petHealthSummary);
      }

      if (includeWalk) {
        _addWalkNotifications(notifications, dashboardData.walkSummary);
      }

      // 상태 업데이트
      state = notifications;

      return ResultFactory.success(notifications, '선택된 알림이 처리되었습니다');
    } catch (error) {
      return ResultFactory.failure('알림 처리 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// 알림 우선순위 정렬
  List<String> sortNotificationsByPriority(List<String> notifications) {
    // 우선순위: 예약 > 건강 > 산책
    final appointmentNotifications = notifications
        .where((n) => n.contains('予約'))
        .toList();
    final healthNotifications = notifications
        .where((n) => n.contains('注意') || n.contains('健康'))
        .toList();
    final walkNotifications = notifications
        .where((n) => n.contains('散歩'))
        .toList();

    final sortedNotifications = [
      ...appointmentNotifications,
      ...healthNotifications,
      ...walkNotifications,
    ];

    // 상태 업데이트
    state = sortedNotifications;

    return sortedNotifications;
  }

  /// 알림 클리어
  void clearNotifications() {
    state = [];
  }

  /// 알림 추가
  void addNotification(String notification) {
    state = [...state, notification];
  }

  /// 알림 제거
  void removeNotification(String notification) {
    state = state.where((n) => n != notification).toList();
  }
}
