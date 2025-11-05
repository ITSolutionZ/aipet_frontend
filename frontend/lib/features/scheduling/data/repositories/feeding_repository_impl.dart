import '../../../../shared/shared.dart';

import '../../../../../features/scheduling/data/services/feeding_local_storage_service.dart';
import '../../../../../features/scheduling/domain/repositories/feeding_repository.dart';

/// 급여 관리 Repository 구현체
/// 로컬 저장소를 사용하여 급여 관련 데이터를 제공
class FeedingRepositoryImpl implements FeedingRepository {
  @override
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingInfo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final data = FeedingLocalStorageService.getPetSizeFeedingInfo();
      return Result.success('ペットサイズ給餌量情報を取得しました', data);
    } catch (error) {
      return Result.failure('ペットサイズ給餌量情報の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPetSizeFeedingGuide() async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final guide = FeedingLocalStorageService.getPetSizeFeedingGuide();
      return Result.success('ペットサイズ給餌ガイドを取得しました', guide);
    } catch (error) {
      return Result.failure('ペットサイズ給餌ガイドの取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> addFeedingRecord(Map<String, dynamic> record) async {
    try {
      await FeedingLocalStorageService.addFeedingRecord(record);
      return Result.success('給餌記録を追加しました', null);
    } catch (error) {
      return Result.failure('給餌記録の追加に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<List<String>>> getPetStatusOptions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final options = FeedingLocalStorageService.getPetStatusOptions();
      return Result.success('ペット状態オプションを取得しました', options);
    } catch (error) {
      return Result.failure('ペット状態オプションの取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getPetInfo(String petId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final petsInfo = FeedingLocalStorageService.getPetSizeFeedingInfo();
      final pet = petsInfo[petId];

      if (pet != null) {
        return Result.success('ペット情報を取得しました', pet);
      } else {
        return Result.success('ペットが見つかりません', null);
      }
    } catch (error) {
      return Result.failure('ペット情報の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getFeedingRecords({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final records = await FeedingLocalStorageService.getFeedingRecords();

      // 펫 ID로 필터링
      var filteredRecords = petId != null
          ? records.where((record) => record['petId'] == petId).toList()
          : records;

      // 날짜 범위로 필터링
      if (startDate != null || endDate != null) {
        filteredRecords = filteredRecords.where((record) {
          final recordDate = DateTime.parse(record['fedTime'] as String);
          if (startDate != null && recordDate.isBefore(startDate)) return false;
          if (endDate != null && recordDate.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      return Result.success('給餌記録を取得しました', filteredRecords);
    } catch (error) {
      return Result.failure('給餌記録の取得に失敗しました: ${error.toString()}');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getFeedingAnalysisData({
    String? petId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final analysisData =
          await FeedingLocalStorageService.getFeedingAnalysisData();
      return Result.success('給餌分析データを取得しました', analysisData);
    } catch (error) {
      return Result.failure('給餌分析データの取得に失敗しました: ${error.toString()}');
    }
  }
}
