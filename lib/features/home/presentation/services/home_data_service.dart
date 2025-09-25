import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 홈 데이터 로딩을 위한 통합 서비스
///
/// 모든 홈 관련 데이터 로딩을 중앙화하여 중복 코드를 제거하고
/// 일관된 에러 처리와 결과 반환을 제공합니다.
class HomeDataService {
  final GetDashboardDataUseCase _getDashboardDataUseCase;
  final GetPetSummaryUseCase _getPetSummaryUseCase;
  final GetWeatherDataUseCase _getWeatherDataUseCase;
  final GetWalkSummaryUseCase _getWalkSummaryUseCase;
  final GetHealthSummaryUseCase _getHealthSummaryUseCase;
  final GetAppointmentSummaryUseCase _getAppointmentSummaryUseCase;

  HomeDataService({
    required GetDashboardDataUseCase getDashboardDataUseCase,
    required GetPetSummaryUseCase getPetSummaryUseCase,
    required GetWeatherDataUseCase getWeatherDataUseCase,
    required GetWalkSummaryUseCase getWalkSummaryUseCase,
    required GetHealthSummaryUseCase getHealthSummaryUseCase,
    required GetAppointmentSummaryUseCase getAppointmentSummaryUseCase,
  }) : _getDashboardDataUseCase = getDashboardDataUseCase,
       _getPetSummaryUseCase = getPetSummaryUseCase,
       _getWeatherDataUseCase = getWeatherDataUseCase,
       _getWalkSummaryUseCase = getWalkSummaryUseCase,
       _getHealthSummaryUseCase = getHealthSummaryUseCase,
       _getAppointmentSummaryUseCase = getAppointmentSummaryUseCase;

  /// 홈 화면 초기화
  Future<Result<HomeDashboardEntity>> initializeHome() async {
    return _executeUseCase(
      () => _getDashboardDataUseCase.call(),
      context: '홈 화면 초기화',
      successMessage: '홈 화면이 초기화되었습니다',
    );
  }

  /// 펫 목록 확인
  Future<Result<bool>> hasPets() async {
    final result = await _executeUseCase(
      () => _getPetSummaryUseCase.call(),
      context: '펫 목록 확인',
      successMessage: '펫 목록을 확인했습니다',
    );

    if (result.isFailure) {
      return ResultFactory.failure(result.errorOrNull ?? '펫 목록 확인에 실패했습니다');
    }

    final petSummaries = result.dataOrNull ?? <PetSummaryEntity>[];
    return ResultFactory.success(petSummaries.isNotEmpty, 'ペットリストの確認が完了しました');
  }

  /// 날씨 정보 로드
  Future<Result<WeatherEntity?>> loadWeatherInfo({
    bool userTriggered = false,
  }) async {
    return _executeUseCase(
      () => _getWeatherDataUseCase.call(userTriggered: userTriggered),
      context: '날씨 정보 로드',
      successMessage: '天気情報がロードされました',
    );
  }

  /// 산책 정보 로드
  Future<Result<WalkSummary>> loadWalkInfo() async {
    return _executeUseCase(
      () => _getWalkSummaryUseCase.call(),
      context: '산책 정보 로드',
      successMessage: '散歩情報がロードされました',
    );
  }

  /// 건강 정보 로드
  Future<Result<HealthSummary>> loadHealthInfo() async {
    return _executeUseCase(
      () => _getHealthSummaryUseCase.call(),
      context: '건강 정보 로드',
      successMessage: '健康情報がロードされました',
    );
  }

  /// 예약 정보 로드
  Future<Result<List<AppointmentSummary>>> loadAppointmentInfo() async {
    return _executeUseCase(
      () => _getAppointmentSummaryUseCase.call(),
      context: '예약 정보 로드',
      successMessage: '予約情報がロードされました',
    );
  }

  /// 펫 프로필 업데이트
  Future<Result<Map<String, dynamic>>> updateProfile() async {
    final petsResult = await _executeUseCase(
      () => _getPetSummaryUseCase.call(),
      context: '펫 정보 조회',
      successMessage: '펫 정보를 조회했습니다',
    );

    if (petsResult.isFailure) {
      return ResultFactory.failure(petsResult.errorOrNull ?? '펫 정보 조회에 실패했습니다');
    }

    final pets = petsResult.dataOrNull ?? <PetSummaryEntity>[];
    return ResultFactory.success({
      'pets': pets,
      'petCount': pets.length,
      'lastUpdated': DateTime.now().toIso8601String(),
    }, '프로필이 업데이트되었습니다');
  }

  /// 통합 데이터 로드 (모든 정보를 한 번에)
  Future<Result<Map<String, dynamic>>> loadAllData({
    bool userTriggered = false,
  }) async {
    try {
      final results = await Future.wait([
        _getDashboardDataUseCase.call(),
        _getPetSummaryUseCase.call(),
        _getWeatherDataUseCase.call(userTriggered: userTriggered),
        _getWalkSummaryUseCase.call(),
        _getHealthSummaryUseCase.call(),
        _getAppointmentSummaryUseCase.call(),
      ]);

      // 모든 결과가 성공인지 확인
      for (final result in results) {
        if (result.isFailure) {
          return ResultFactory.failure('일부 데이터 로드에 실패했습니다');
        }
      }

      return ResultFactory.success({
        'dashboard': results[0],
        'pets': results[1],
        'weather': results[2],
        'walk': results[3],
        'health': results[4],
        'appointments': results[5],
        'loadedAt': DateTime.now().toIso8601String(),
      }, '모든 데이터가 성공적으로 로드되었습니다');
    } catch (error) {
      return ResultFactory.failure('데이터 로드 중 오류가 발생했습니다: ${error.toString()}');
    }
  }

  /// 공통 UseCase 실행 헬퍼
  Future<Result<T>> _executeUseCase<T>(
    Future<Result<T>> Function() useCase, {
    required String context,
    required String successMessage,
  }) async {
    try {
      final result = await useCase();
      return result;
    } catch (error) {
      return ResultFactory.failure('$context에 실패했습니다: ${error.toString()}');
    }
  }
}
