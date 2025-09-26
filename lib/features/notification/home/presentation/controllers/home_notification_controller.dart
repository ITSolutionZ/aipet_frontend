import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';

class HomeNotificationController extends BaseController {
  final GetDashboardDataUseCase _getDashboardDataUseCase;

  HomeNotificationController(
    super.ref, {
    HomeRepository? repository,
    GetDashboardDataUseCase? getDashboardDataUseCase,
  }) : _getDashboardDataUseCase =
           getDashboardDataUseCase ??
           GetDashboardDataUseCase(repository ?? HomeRepositoryImpl());

  /// 알림 처리
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
      final upcomingAppointments = dashboardData.upcomingAppointments;
      for (final appointment in upcomingAppointments) {
        final timeDifference = appointment.scheduledTime.difference(
          DateTime.now(),
        );

        // 24시간 이내 예약 알림
        if (timeDifference.inHours <= 24 && timeDifference.inHours > 0) {
          notifications.add(
            '${appointment.petName}の${appointment.type}予約が明日${_formatTime(appointment.scheduledTime)}に予定されています。',
          );
        }
        // 2시간 이내 예약 알림
        else if (timeDifference.inHours <= 2 && timeDifference.inHours > 0) {
          notifications.add(
            '${appointment.petName}の${appointment.type}予約が${timeDifference.inHours}時間後にあります。',
          );
        }
      }

      // 건강 상태 알림 확인
      final healthSummary = dashboardData.petHealthSummary;
      if (healthSummary.petsNeedingAttention > 0) {
        notifications.add(
          '注意が必要なペットが${healthSummary.petsNeedingAttention}匹います。',
        );
      }

      // 건강 알림 확인
      for (final alert in healthSummary.alerts) {
        notifications.add('${alert.petName}: ${alert.message}');
      }

      // 산책 알림 확인
      final walkSummary = dashboardData.walkSummary;
      final now = DateTime.now();

      // 오늘 산책을 한 번도 안 했을 경우 (오후 6시 이후)
      if (walkSummary.todayWalks == 0 && now.hour >= 18) {
        notifications.add('今日はまだ散歩していません。ペットと一緒に散歩してみませんか！');
      }

      // 주간 목표 달성률이 낮을 경우
      final weeklyProgress =
          (walkSummary.weeklyProgress / walkSummary.weeklyGoal * 100);
      if (weeklyProgress < 50 && now.weekday >= 5) {
        // 금요일 이후
        notifications.add(
          '今週の散歩目標達成率が${weeklyProgress.toInt()}%です。もう少し頑張ってみましょう！',
        );
      }

      return ResultFactory.success(notifications, '通知が処理されました');
    } catch (error) {
      handleError(error);
      return ResultFactory.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 시간 포맷팅 헬퍼 메서드
  String _formatTime(DateTime dateTime) {
    return DateTimeUtils.formatTime(dateTime);
  }
}
