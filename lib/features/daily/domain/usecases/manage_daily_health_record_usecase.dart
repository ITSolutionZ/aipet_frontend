import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/daily_health_repository_impl.dart';
import '../entities/daily_health_record.dart';
import '../repositories/daily_health_repository.dart';

part 'manage_daily_health_record_usecase.g.dart';

/// 일일 건강 기록 관리 Use Case
class ManageDailyHealthRecordUseCase {
  final DailyHealthRepository _repository;

  const ManageDailyHealthRecordUseCase(this._repository);

  /// 건강 기록 생성
  Future<DailyHealthRecord> createRecord(DailyHealthRecord record) async {
    // 비즈니스 로직: 같은 날짜에 이미 기록이 있는지 확인
    final existingRecord = await _repository.getTodayHealthRecord(record.petId);

    if (existingRecord != null) {
      throw Exception('Today\'s health record already exists for this pet');
    }

    return await _repository.createDailyHealthRecord(record);
  }

  /// 건강 기록 업데이트
  Future<DailyHealthRecord> updateRecord(DailyHealthRecord record) async {
    // 비즈니스 로직: 기록이 존재하는지 확인
    final existingRecord = await _repository.getDailyHealthRecord(record.id);

    if (existingRecord == null) {
      throw Exception('Health record not found');
    }

    return await _repository.updateDailyHealthRecord(record);
  }

  /// 건강 기록 삭제
  Future<void> deleteRecord(String recordId) async {
    // 비즈니스 로직: 기록이 존재하는지 확인
    final existingRecord = await _repository.getDailyHealthRecord(recordId);

    if (existingRecord == null) {
      throw Exception('Health record not found');
    }

    await _repository.deleteDailyHealthRecord(recordId);
  }

  /// 건강 기록 생성 또는 업데이트 (upsert)
  Future<DailyHealthRecord> upsertRecord(DailyHealthRecord record) async {
    final existingRecord = await _repository.getTodayHealthRecord(record.petId);

    if (existingRecord != null) {
      // 기존 기록이 있으면 업데이트
      final updatedRecord = record.copyWith(id: existingRecord.id);
      return await updateRecord(updatedRecord);
    } else {
      // 기존 기록이 없으면 생성
      return await createRecord(record);
    }
  }
}

/// Use Case Provider
@riverpod
ManageDailyHealthRecordUseCase manageDailyHealthRecordUseCase(
  ManageDailyHealthRecordUseCaseRef ref,
) {
  final repository = ref.watch(dailyHealthRepositoryProvider);
  return ManageDailyHealthRecordUseCase(repository);
}