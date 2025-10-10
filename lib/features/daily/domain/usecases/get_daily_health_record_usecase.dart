import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/daily_health_repository_impl.dart';
import '../entities/daily_health_record.dart';
import '../repositories/daily_health_repository.dart';

part 'get_daily_health_record_usecase.g.dart';

/// 일일 건강 기록 조회 Use Case
class GetDailyHealthRecordUseCase {
  final DailyHealthRepository _repository;

  const GetDailyHealthRecordUseCase(this._repository);

  /// 특정 펫의 오늘 건강 기록 조회
  Future<DailyHealthRecord?> getTodayRecord(String petId) async {
    return await _repository.getTodayHealthRecord(petId);
  }

  /// 특정 ID의 건강 기록 조회
  Future<DailyHealthRecord?> getRecord(String recordId) async {
    return await _repository.getDailyHealthRecord(recordId);
  }

  /// 특정 펫의 모든 건강 기록 조회
  Future<List<DailyHealthRecord>> getAllRecords(String petId) async {
    return await _repository.getDailyHealthRecords(petId);
  }

  /// 날짜 범위별 건강 기록 조회
  Future<List<DailyHealthRecord>> getRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getDailyHealthRecordsByDateRange(
      petId,
      startDate,
      endDate,
    );
  }
}

/// Use Case Provider
@riverpod
GetDailyHealthRecordUseCase getDailyHealthRecordUseCase(
  GetDailyHealthRecordUseCaseRef ref,
) {
  final repository = ref.watch(dailyHealthRepositoryProvider);
  return GetDailyHealthRecordUseCase(repository);
}