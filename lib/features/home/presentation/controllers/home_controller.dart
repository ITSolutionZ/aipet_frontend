import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class HomeResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const HomeResult._(this.isSuccess, this.message, this.data);

  factory HomeResult.success(String message, [dynamic data]) =>
      HomeResult._(true, message, data);
  factory HomeResult.failure(String message) =>
      HomeResult._(false, message, null);
}

class HomeController extends BaseController {
  HomeController(super.ref);

  // Repository 및 UseCase 인스턴스
  late final HomeRepository _repository = HomeRepositoryImpl();
  late final GetDashboardDataUseCase _getDashboardDataUseCase =
      GetDashboardDataUseCase(_repository);

  HomeStateData get currentState => ref.read(homeStateProvider);

  void setSelectedIndex(int index) {
    ref.read(homeStateProvider.notifier).setSelectedIndex(index);
  }

  void updateCurrentTime(String time) {
    ref.read(homeStateProvider.notifier).updateCurrentTime(time);
  }

  /// 홈 화면 초기화
  Future<HomeResult> initializeHome() async {
    try {
      final dashboardData = await _getDashboardDataUseCase.call();
      return HomeResult.success('홈 화면이 로드되었습니다', dashboardData);
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 펫 목록 확인
  Future<bool> hasPets() async {
    try {
      final petProfiles = await _repository.getPetProfiles();
      return petProfiles.isNotEmpty;
    } catch (error) {
      handleError(error);
      return false;
    }
  }

  /// 알림 처리
  Future<HomeResult> handleNotification() async {
    try {
      final notifications = <String>[];

      // 대시보드 데이터 가져오기
      final dashboardData = await _getDashboardDataUseCase.call();

      // 예정된 예약 알림 확인
      final upcomingAppointments = dashboardData.upcomingAppointments;
      for (final appointment in upcomingAppointments) {
        final timeDifference = appointment.scheduledTime.difference(
          DateTime.now(),
        );

        // 24시간 이내 예약 알림
        if (timeDifference.inHours <= 24 && timeDifference.inHours > 0) {
          notifications.add(
            '${appointment.petName}의 ${appointment.type} 예약이 내일 ${_formatTime(appointment.scheduledTime)}에 예정되어 있습니다.',
          );
        }
        // 2시간 이내 예약 알림
        else if (timeDifference.inHours <= 2 && timeDifference.inHours > 0) {
          notifications.add(
            '${appointment.petName}의 ${appointment.type} 예약이 ${timeDifference.inHours}시간 후에 있습니다.',
          );
        }
      }

      // 건강 상태 알림 확인
      final healthSummary = dashboardData.petHealthSummary;
      if (healthSummary.petsNeedingAttention > 0) {
        notifications.add(
          '주의가 필요한 펫이 ${healthSummary.petsNeedingAttention}마리 있습니다.',
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
        notifications.add('오늘 아직 산책을 하지 않았습니다. 반려동물과 함께 산책을 해보세요!');
      }

      // 주간 목표 달성률이 낮을 경우
      final weeklyProgress =
          (walkSummary.weeklyProgress / walkSummary.weeklyGoal * 100);
      if (weeklyProgress < 50 && now.weekday >= 5) {
        // 금요일 이후
        notifications.add(
          '이번 주 산책 목표 달성률이 ${weeklyProgress.toInt()}%입니다. 조금 더 노력해보세요!',
        );
      }

      return HomeResult.success(
        notifications.isEmpty
            ? '새로운 알림이 없습니다'
            : '${notifications.length}개의 알림이 있습니다',
        notifications,
      );
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 시간 포맷팅 헬퍼 메서드
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 프로필 업데이트
  Future<HomeResult> updateProfile() async {
    try {
      // 펫 프로필 정보를 다시 로드하여 최신 상태로 업데이트
      final petProfiles = await _repository.getPetProfiles();
      final dashboardData = await _getDashboardDataUseCase.call();

      // 프로필 업데이트 성공 메시지와 함께 업데이트된 데이터 반환
      return HomeResult.success(
        '프로필이 업데이트되었습니다 (${petProfiles.length}마리 펫 정보)',
        {'pets': petProfiles, 'dashboard': dashboardData},
      );
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 날씨 정보 로드
  Future<HomeResult> loadWeatherInfo() async {
    try {
      final weather = await _repository.getCurrentWeather();
      return HomeResult.success('날씨 정보가 로드되었습니다', weather);
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 정보 로드
  Future<HomeResult> loadWalkInfo() async {
    try {
      final walkSummary = await _repository.getWalkSummary();
      return HomeResult.success('산책 정보가 로드되었습니다', walkSummary);
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 건강 정보 로드
  Future<HomeResult> loadHealthInfo() async {
    try {
      final healthSummary = await _repository.getPetHealthSummary();
      return HomeResult.success('건강 정보가 로드되었습니다', healthSummary);
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 예약 정보 로드
  Future<HomeResult> loadAppointmentInfo() async {
    try {
      final appointments = await _repository.getUpcomingAppointments();
      return HomeResult.success('예약 정보가 로드되었습니다', appointments);
    } catch (error) {
      handleError(error);
      return HomeResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
