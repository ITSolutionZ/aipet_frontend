import '../../../../app/controllers/base_controller.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class HomeDashboardResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const HomeDashboardResult._(this.isSuccess, this.message, this.data);

  factory HomeDashboardResult.success(String message, [dynamic data]) =>
      HomeDashboardResult._(true, message, data);
  factory HomeDashboardResult.failure(String message) =>
      HomeDashboardResult._(false, message, null);
}

class HomeDashboardController extends BaseController {
  HomeDashboardController(super.ref);

  // Repository 및 UseCase 인스턴스
  late final HomeRepository _repository = HomeRepositoryImpl();
  late final GetDashboardDataUseCase _getDashboardDataUseCase =
      GetDashboardDataUseCase(_repository);

  /// 홈 화면 초기화
  Future<HomeDashboardResult> initializeHome() async {
    try {
      final dashboardData = await _getDashboardDataUseCase.call();
      return HomeDashboardResult.success('홈 화면이 로드되었습니다', dashboardData);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
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

  /// 날씨 정보 로드
  Future<HomeDashboardResult> loadWeatherInfo() async {
    try {
      final weather = await _repository.getCurrentWeather();
      return HomeDashboardResult.success('날씨 정보가 로드되었습니다', weather);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 산책 정보 로드
  Future<HomeDashboardResult> loadWalkInfo() async {
    try {
      final walkSummary = await _repository.getWalkSummary();
      return HomeDashboardResult.success('산책 정보가 로드되었습니다', walkSummary);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 건강 정보 로드
  Future<HomeDashboardResult> loadHealthInfo() async {
    try {
      final healthSummary = await _repository.getPetHealthSummary();
      return HomeDashboardResult.success('건강 정보가 로드되었습니다', healthSummary);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 예약 정보 로드
  Future<HomeDashboardResult> loadAppointmentInfo() async {
    try {
      final appointments = await _repository.getUpcomingAppointments();
      return HomeDashboardResult.success('예약 정보가 로드되었습니다', appointments);
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }

  /// 프로필 업데이트
  Future<HomeDashboardResult> updateProfile() async {
    try {
      // 펫 프로필 정보를 다시 로드하여 최신 상태로 업데이트
      final petProfiles = await _repository.getPetProfiles();
      final dashboardData = await _getDashboardDataUseCase.call();

      // 프로필 업데이트 성공 메시지와 함께 업데이트된 데이터 반환
      return HomeDashboardResult.success(
        '프로필이 업데이트되었습니다 (${petProfiles.length}마리 펫 정보)',
        {'pets': petProfiles, 'dashboard': dashboardData},
      );
    } catch (error) {
      handleError(error);
      return HomeDashboardResult.failure(getUserFriendlyErrorMessage(error));
    }
  }
}
