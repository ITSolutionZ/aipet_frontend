import '../../../../shared/shared.dart';

import '../../../../../features/pet_feeding/data/services/backend_feeding_api_service.dart';
import '../../../../../features/pet_feeding/domain/entities/feeding_record_entity.dart';
import '../../../../../features/pet_feeding/domain/repositories/pet_feeding_repository.dart';

/// 급여 기록 Repository 구현체
/// Backend API 연동 (BackendFeedingApiService 사용)
class PetFeedingRepositoryImpl implements PetFeedingRepository {
  PetFeedingRepositoryImpl();

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecords(String petId) async {
    final result = await BackendFeedingApiService.getFeedings(petId: petId);

    if (result.isSuccess) {
      final records = result.dataOrNull ?? [];
      LoggerService.debug(
        '✅ PetFeedingRepository: 급여 기록 ${records.length}개 조회 (Backend API)',
      );
      return records;
    } else {
      LoggerService.error(
        '❌ PetFeedingRepository: 급여 기록 조회 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    // 해당 날짜의 시작과 끝 시간 계산
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await BackendFeedingApiService.getFeedings(
      petId: petId,
      startDate: startDate,
      endDate: endDate,
    );

    if (result.isSuccess) {
      final records = result.dataOrNull ?? [];
      LoggerService.debug(
        '✅ PetFeedingRepository: ${date.toString().split(' ')[0]} 급여 기록 ${records.length}개 조회 (Backend API)',
      );
      return records;
    } else {
      LoggerService.error(
        '❌ PetFeedingRepository: 날짜별 급여 기록 조회 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<FeedingRecordEntity> addFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    final result = await BackendFeedingApiService.createFeeding(
      petId: record.petId,
      feeding: record,
    );

    if (result.isSuccess) {
      final createdRecord = result.dataOrNull!;
      LoggerService.debug(
        '✅ PetFeedingRepository: 급여 기록 추가 - ID: ${createdRecord.id} (Backend API)',
      );
      return createdRecord;
    } else {
      LoggerService.error(
        '❌ PetFeedingRepository: 급여 기록 추가 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<FeedingRecordEntity> updateFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    final result = await BackendFeedingApiService.updateFeeding(
      petId: record.petId,
      feeding: record,
    );

    if (result.isSuccess) {
      final updatedRecord = result.dataOrNull!;
      LoggerService.debug(
        '✅ PetFeedingRepository: 급여 기록 업데이트 - ID: ${updatedRecord.id} (Backend API)',
      );
      return updatedRecord;
    } else {
      LoggerService.error(
        '❌ PetFeedingRepository: 급여 기록 업데이트 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }

  @override
  Future<void> deleteFeedingRecord(String recordId) async {
    // ⚠️ Backend API는 petId도 필요하지만, interface에는 recordId만 있음
    // Controller에서 petId를 함께 전달하도록 수정 필요
    // 임시로 에러 처리 - interface 변경 필요
    throw UnimplementedError(
      'deleteFeedingRecord는 petId가 필요합니다. '
      'Repository interface를 deleteFeedingRecord(String petId, String recordId)로 변경해주세요.',
    );
  }

  @override
  Future<FeedingStatistics> getFeedingStatistics(String petId) async {
    final result = await BackendFeedingApiService.getFeedingStats(
      petId: petId,
    );

    if (result.isSuccess) {
      final stats = result.dataOrNull!;
      LoggerService.debug(
        '✅ PetFeedingRepository: 급여 통계 조회 (Backend API)',
      );
      return stats;
    } else {
      LoggerService.error(
        '❌ PetFeedingRepository: 급여 통계 조회 실패 - ${result.error}',
      );
      throw Exception(result.error);
    }
  }
}
