import '../../../../shared/shared.dart';

import '../../../../../features/pet_health/domain/entities/vaccine_record_entity.dart';
import '../../../../../features/pet_health/domain/entities/weight_record_entity.dart';
import '../../../../../features/pet_health/domain/repositories/pet_health_repository.dart';

/// 건강 기록 수정 UseCase
class UpdateHealthRecordUseCase {
  final PetHealthRepository repository;

  UpdateHealthRecordUseCase(this.repository);

  /// 체중 기록 수정
  Future<Result<WeightRecordEntity>> updateWeightRecord(
    WeightRecordEntity weightRecord,
  ) async {
    try {
      final result = await repository.updateWeightRecord(weightRecord);
      return Result.success('体重記録を更新しました', result);
    } catch (error) {
      return Result.failure('体重記録の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 백신 기록 수정
  Future<Result<VaccineRecordEntity>> updateVaccineRecord(
    String petId,
    VaccineRecordEntity vaccineRecord,
  ) async {
    try {
      final result = await repository.updateVaccineRecord(petId, vaccineRecord);
      return Result.success('ワクチン記録を更新しました', result);
    } catch (error) {
      return Result.failure('ワクチン記録の更新に失敗しました: ${error.toString()}');
    }
  }

  /// 체중 기록 메모 수정
  Future<Result<WeightRecordEntity>> updateWeightRecordNotes(
    String petId,
    String recordId,
    String notes,
  ) async {
    try {
      // 기존 기록 조회
      final weightRecords = await repository.getWeightRecords(petId);
      final existingRecord = weightRecords.firstWhere(
        (record) => record.id == recordId,
        orElse: () => throw Exception('体重記録が見つかりません'),
      );

      final updatedRecord = existingRecord.copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final result = await repository.updateWeightRecord(updatedRecord);
      return Result.success('体重記録のメモを更新しました', result);
    } catch (error) {
      return Result.failure('体重記録のメモ更新に失敗しました: ${error.toString()}');
    }
  }

  /// 백신 접종 완료 처리
  Future<Result<VaccineRecordEntity>> markVaccineAsCompleted(
    String petId,
    String recordId,
  ) async {
    try {
      // 기존 백신 기록 조회
      final vaccineRecords = await repository.getVaccineRecords(petId);
      final existingRecord = vaccineRecords.firstWhere(
        (record) => record.id == recordId,
        orElse: () => throw Exception('ワクチン記録が見つかりません'),
      );

      final updatedRecord = existingRecord.copyWith(
        notes:
            '${existingRecord.notes ?? ''}\n[접종 완료] ${DateTime.now().toIso8601String()}',
      );

      final result = await repository.updateVaccineRecord(petId, updatedRecord);
      return Result.success('ワクチン接種を完了しました', result);
    } catch (error) {
      return Result.failure('ワクチン接種の完了処理に失敗しました: ${error.toString()}');
    }
  }

  /// 건강 기록 일괄 수정
  Future<Result<Map<String, dynamic>>> updateMultipleHealthRecords(
    String petId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final results = <String, dynamic>{};

      // 체중 기록 수정
      if (updates.containsKey('weightRecords')) {
        final weightUpdates =
            updates['weightRecords'] as List<Map<String, dynamic>>;
        final weightRecords = await repository.getWeightRecords(petId);

        for (final update in weightUpdates) {
          final recordId = update['id'] as String;
          final existingRecord = weightRecords.firstWhere(
            (record) => record.id == recordId,
            orElse: () => throw Exception('体重記録が見つかりません'),
          );

          final updatedRecord = existingRecord.copyWith(
            weight: update['weight'] as double? ?? existingRecord.weight,
            notes: update['notes'] as String? ?? existingRecord.notes,
            updatedAt: DateTime.now(),
          );
          final result = await repository.updateWeightRecord(updatedRecord);
          results['weight_$recordId'] = result;
        }
      }

      // 백신 기록 수정
      if (updates.containsKey('vaccineRecords')) {
        final vaccineUpdates =
            updates['vaccineRecords'] as List<Map<String, dynamic>>;
        final vaccineRecords = await repository.getVaccineRecords(petId);

        for (final update in vaccineUpdates) {
          final recordId = update['id'] as String;
          final existingRecord = vaccineRecords.firstWhere(
            (record) => record.id == recordId,
            orElse: () => throw Exception('ワクチン記録が見つかりません'),
          );

          final updatedRecord = existingRecord.copyWith(
            name: update['name'] as String? ?? existingRecord.name,
            doctor: update['doctor'] as String? ?? existingRecord.doctor,
            notes: update['notes'] as String? ?? existingRecord.notes,
          );
          final result = await repository.updateVaccineRecord(
            petId,
            updatedRecord,
          );
          results['vaccine_$recordId'] = result;
        }
      }

      return Result.success('複数の健康記録を更新しました', results);
    } catch (error) {
      return Result.failure('複数の健康記録の更新に失敗しました: ${error.toString()}');
    }
  }
}
