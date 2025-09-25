import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/features/home/presentation/services/home_common_service.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 리팩토링된 홈 알림 컨트롤러
///
/// HomeCommonService를 사용하여 중복 코드를 제거하고
/// 일관된 알림 처리를 제공합니다.
class RefactoredHomeNotificationController extends BaseController {
  final GetDashboardDataUseCase _getDashboardDataUseCase;

  RefactoredHomeNotificationController(
    super.ref, {
    HomeRepository? repository,
    GetDashboardDataUseCase? getDashboardDataUseCase,
  }) : _getDashboardDataUseCase =
           getDashboardDataUseCase ??
           GetDashboardDataUseCase(repository ?? HomeRepositoryImpl());

  /// 알림 처리 (리팩토링된 버전)
  Future<Result<List<String>>> handleNotification() async {
    try {
      final notifications = <String>[];

      // 대시보드 데이터 가져오기
      final result = await _getDashboardDataUseCase.call();
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

      return ResultFactory.success(notifications, '通知が処理されました');
    } catch (error) {
      handleError(error);
      return ResultFactory.failure(getUserFriendlyErrorMessage(error));
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
      final result = await _getDashboardDataUseCase.call();
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

      return ResultFactory.success(notifications, '선택된 알림이 처리되었습니다');
    } catch (error) {
      handleError(error);
      return ResultFactory.failure(getUserFriendlyErrorMessage(error));
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

    return [
      ...appointmentNotifications,
      ...healthNotifications,
      ...walkNotifications,
    ];
  }
}
