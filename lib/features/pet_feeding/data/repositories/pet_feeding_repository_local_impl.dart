import 'package:aipet_frontend/features/pet_feeding/data/models/feeding_record_model.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/entities/feeding_record_entity.dart';
import 'package:aipet_frontend/features/pet_feeding/domain/repositories/pet_feeding_repository.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';

/// Pet Feeding Repository - 로컬 저장소 구현체
/// Mock 데이터 대신 로컬 저장소(SharedPreferences)를 사용하는 버전
class PetFeedingRepositoryLocalImpl implements PetFeedingRepository {
  final LocalDataManager _localDataManager = LocalDataManager.instance;

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecords(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // API 지연 시뮬레이션

    final recordsData = await _localDataManager.loadFeedingRecords();

    return recordsData
        .where((data) => data['petId'] == petId)
        .map((data) => FeedingRecordModel.fromJson(data).toEntity())
        .toList();
  }

  @override
  Future<List<FeedingRecordEntity>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await _localDataManager.loadFeedingRecords();

    return recordsData
        .where((data) {
          if (data['petId'] != petId) return false;

          final fedTimeStr = data['fedTime'] as String?;
          if (fedTimeStr == null) return false;

          final fedTime = DateTime.parse(fedTimeStr);
          return fedTime.year == date.year &&
              fedTime.month == date.month &&
              fedTime.day == date.day;
        })
        .map((data) => FeedingRecordModel.fromJson(data).toEntity())
        .toList();
  }

  @override
  Future<FeedingRecordEntity> addFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recordsData = await _localDataManager.loadFeedingRecords();

    // Entity를 Model로 변환
    final model = FeedingRecordModel.fromEntity(record);

    // 새로운 기록 추가
    final newRecordData = model.toJson();

    // ID가 없으면 생성
    if (newRecordData['id'] == null ||
        (newRecordData['id'] as String).isEmpty) {
      newRecordData['id'] = 'feeding-${DateTime.now().millisecondsSinceEpoch}';
    }

    newRecordData['createdAt'] = DateTime.now().toIso8601String();

    recordsData.add(newRecordData);
    await _localDataManager.saveFeedingRecords(recordsData);

    return FeedingRecordModel.fromJson(newRecordData).toEntity();
  }

  @override
  Future<FeedingRecordEntity> updateFeedingRecord(
    FeedingRecordEntity record,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recordsData = await _localDataManager.loadFeedingRecords();

    final index = recordsData.indexWhere((data) => data['id'] == record.id);
    if (index == -1) {
      throw Exception('급여 기록을 찾을 수 없습니다: ${record.id}');
    }

    // Entity를 Model로 변환
    final model = FeedingRecordModel.fromEntity(record);
    final updatedData = model.toJson();
    updatedData['updatedAt'] = DateTime.now().toIso8601String();

    recordsData[index] = updatedData;
    await _localDataManager.saveFeedingRecords(recordsData);

    return FeedingRecordModel.fromJson(updatedData).toEntity();
  }

  @override
  Future<void> deleteFeedingRecord(String recordId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final recordsData = await _localDataManager.loadFeedingRecords();

    final initialLength = recordsData.length;
    recordsData.removeWhere((data) => data['id'] == recordId);

    if (recordsData.length == initialLength) {
      throw Exception('삭제할 급여 기록을 찾을 수 없습니다: $recordId');
    }

    await _localDataManager.saveFeedingRecords(recordsData);
  }

  @override
  Future<FeedingStatistics> getFeedingStatistics(String petId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recordsData = await _localDataManager.loadFeedingRecords();

    final petRecords = recordsData
        .where((data) => data['petId'] == petId)
        .map((data) => FeedingRecordModel.fromJson(data).toEntity())
        .toList();

    final completedRecords = petRecords
        .where((r) => r.status == FeedingStatus.completed)
        .toList();
    final skippedRecords = petRecords
        .where((r) => r.status == FeedingStatus.skipped)
        .toList();

    final totalAmount = completedRecords.fold<double>(
      0,
      (sum, record) => sum + record.amount,
    );
    final averageAmount = completedRecords.isNotEmpty
        ? totalAmount / completedRecords.length
        : 0.0;
    final completionRate = petRecords.isNotEmpty
        ? completedRecords.length / petRecords.length
        : 0.0;

    final feedingsByHour = <String, int>{};
    for (var record in petRecords) {
      // ✅ DateTimeUtils 사용
      feedingsByHour[hour] = (feedingsByHour[hour] ?? 0) + 1;
    }

    return FeedingStatistics(
      totalFeedings: petRecords.length,
      completedFeedings: completedRecords.length,
      skippedFeedings: skippedRecords.length,
      totalAmount: totalAmount,
      averageAmount: averageAmount,
      completionRate: completionRate,
      feedingsByHour: feedingsByHour,
    );
  }

  /// 로컬 데이터 초기화 (개발/테스트용)
  Future<void> clearAllFeedingRecords() async {
    await _localDataManager.saveFeedingRecords([]);
  }

  /// 특정 펫의 급식 기록만 삭제
  Future<void> clearPetFeedingRecords(String petId) async {
    final recordsData = await _localDataManager.loadFeedingRecords();
    recordsData.removeWhere((data) => data['petId'] == petId);
    await _localDataManager.saveFeedingRecords(recordsData);
  }

  /// 데이터 존재 여부 확인
  Future<bool> hasFeedingData(String petId) async {
    final recordsData = await _localDataManager.loadFeedingRecords();
    return recordsData.any((data) => data['petId'] == petId);
  }

  /// 급식 기록 수 조회
  Future<int> getFeedingRecordCount(String petId) async {
    final recordsData = await _localDataManager.loadFeedingRecords();
    return recordsData.where((data) => data['petId'] == petId).length;
  }
}
