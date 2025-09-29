import 'package:aipet_frontend/features/scheduling/domain/repositories/feeding_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 급여 관리 Repository 구현체
/// Mock 데이터를 사용하여 급여 관련 데이터를 제공
class FeedingRepositoryImpl implements FeedingRepository {
  @override
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingInfo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final data = SchedulingMockService.getMockPetSizesAndFeedingAmounts();
      return Result.success(
        '펫 사이즈 급여량 정보를 성공적으로 가져왔습니다',
        data as Map<String, dynamic>,
      );
    } catch (error) {
      return Result.failure('펫 사이즈 급여량 정보를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingGuide() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final guide = SchedulingMockService.getPetSizeFeedingGuide();
      return Result.success('펫 사이즈 급여량 가이드를 성공적으로 가져왔습니다', guide);
    } catch (error) {
      return Result.failure('펫 사이즈 급여량 가이드를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> addFeedingRecord(Map<String, dynamic> record) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      SchedulingMockService.addMockFeedingRecord(record);
      return Result.success('급여 기록이 성공적으로 추가되었습니다', null);
    } catch (error) {
      return Result.failure('급여 기록 추가에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<List<String>>> getPetStatusOptions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final options = ['건강함', '배고픔', '활발함', '피곤함', '스트레스', '기타'];
      return Result.success('펫 상태 옵션을 성공적으로 가져왔습니다', options);
    } catch (error) {
      return Result.failure('펫 상태 옵션을 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getPetInfo(String petId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final pets = PetMockService.getMockPetProfiles();
      final pet = pets.cast<Map<String, dynamic>?>().firstWhere(
        (p) => p?['id']?.toString() == petId,
        orElse: () => null,
      );

      if (pet != null) {
        return Result.success('펫 정보를 성공적으로 가져왔습니다', pet);
      } else {
        return Result.success('펫을 찾을 수 없습니다', null);
      }
    } catch (error) {
      return Result.failure('펫 정보를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getFeedingRecords({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));
      final records = SchedulingMockService.getMockFeedingSchedules();
      // 펫 ID로 필터링 (필요시)
      final filteredRecords = petId != null
          ? records.where((record) => record['petId'] == petId).toList()
          : records;
      return Result.success('급여 기록을 성공적으로 가져왔습니다', filteredRecords);
    } catch (error) {
      return Result.failure('급여 기록을 가져오는데 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getFeedingAnalysisData({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final analysisData =
          SchedulingMockService.getMockFeedingStatisticsForRecords();
      return Result.success('급여 분석 데이터를 성공적으로 가져왔습니다', analysisData);
    } catch (error) {
      return Result.failure('급여 분석 데이터를 가져오는데 실패했습니다: ${error.toString()}');
    }
  }
}
