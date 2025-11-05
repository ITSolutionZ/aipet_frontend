import '../../../../shared/shared.dart';

import '../../../../../features/pet_health/domain/repositories/pet_health_repository.dart';

/// 건강 기록 삭제 UseCase
class DeleteHealthRecordUseCase {
  final PetHealthRepository repository;

  DeleteHealthRecordUseCase(this.repository);

  /// 체중 기록 삭제
  Future<Result<void>> deleteWeightRecord(String recordId) async {
    try {
      await repository.deleteWeightRecord(recordId);
      return Result.success('体重記録を削除しました', null);
    } catch (error) {
      return Result.failure('体重記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 백신 기록 삭제
  Future<Result<void>> deleteVaccineRecord(String recordId) async {
    try {
      await repository.deleteVaccineRecord(recordId);
      return Result.success('ワクチン記録を削除しました', null);
    } catch (error) {
      return Result.failure('ワクチン記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 펫의 모든 체중 기록 삭제
  Future<Result<void>> deleteAllWeightRecords(String petId) async {
    try {
      final weightRecords = await repository.getWeightRecords(petId);
      for (final record in weightRecords) {
        await repository.deleteWeightRecord(record.id);
      }
      return Result.success('ペットの体重記録をすべて削除しました', null);
    } catch (error) {
      return Result.failure('ペットの体重記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 펫의 모든 백신 기록 삭제
  Future<Result<void>> deleteAllVaccineRecords(String petId) async {
    try {
      final vaccineRecords = await repository.getVaccineRecords(petId);
      for (final record in vaccineRecords) {
        await repository.deleteVaccineRecord(record.id);
      }
      return Result.success('ペットのワクチン記録をすべて削除しました', null);
    } catch (error) {
      return Result.failure('ペットのワクチン記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 펫의 모든 건강 기록 삭제
  Future<Result<void>> deleteAllHealthRecords(String petId) async {
    try {
      // 체중 기록 삭제
      final weightResult = await deleteAllWeightRecords(petId);
      if (!weightResult.isSuccess) {
        return weightResult;
      }

      // 백신 기록 삭제
      final vaccineResult = await deleteAllVaccineRecords(petId);
      if (!vaccineResult.isSuccess) {
        return vaccineResult;
      }

      return Result.success('ペットの健康記録をすべて削除しました', null);
    } catch (error) {
      return Result.failure('ペットの健康記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 오래된 건강 기록 삭제 (예: 1년 이상 된 기록)
  Future<Result<Map<String, int>>> deleteOldHealthRecords(
    String petId,
    int daysOld,
  ) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedWeightRecords = 0;
      int deletedVaccineRecords = 0;

      // 오래된 체중 기록 삭제
      final weightRecords = await repository.getWeightRecords(petId);
      for (final record in weightRecords) {
        if (record.recordedDate.isBefore(cutoffDate)) {
          await repository.deleteWeightRecord(record.id);
          deletedWeightRecords++;
        }
      }

      // 오래된 백신 기록 삭제 (만료된 것만)
      final vaccineRecords = await repository.getVaccineRecords(petId);
      for (final record in vaccineRecords) {
        if (record.date.isBefore(cutoffDate) && record.isExpired) {
          await repository.deleteVaccineRecord(record.id);
          deletedVaccineRecords++;
        }
      }

      final result = {
        'deletedWeightRecords': deletedWeightRecords,
        'deletedVaccineRecords': deletedVaccineRecords,
        'totalDeleted': deletedWeightRecords + deletedVaccineRecords,
      };

      return Result.success('古い健康記録を削除しました', result);
    } catch (error) {
      return Result.failure('古い健康記録の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 특정 날짜 범위의 건강 기록 삭제
  Future<Result<Map<String, int>>> deleteHealthRecordsByDateRange(
    String petId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      int deletedWeightRecords = 0;
      int deletedVaccineRecords = 0;

      // 날짜 범위 내 체중 기록 삭제
      final weightRecords = await repository.getWeightRecords(petId);
      for (final record in weightRecords) {
        if (record.recordedDate.isAfter(startDate) &&
            record.recordedDate.isBefore(endDate)) {
          await repository.deleteWeightRecord(record.id);
          deletedWeightRecords++;
        }
      }

      // 날짜 범위 내 백신 기록 삭제
      final vaccineRecords = await repository.getVaccineRecords(petId);
      for (final record in vaccineRecords) {
        if (record.date.isAfter(startDate) && record.date.isBefore(endDate)) {
          await repository.deleteVaccineRecord(record.id);
          deletedVaccineRecords++;
        }
      }

      final result = {
        'deletedWeightRecords': deletedWeightRecords,
        'deletedVaccineRecords': deletedVaccineRecords,
        'totalDeleted': deletedWeightRecords + deletedVaccineRecords,
      };

      return Result.success('指定期間の健康記録を削除しました', result);
    } catch (error) {
      return Result.failure('指定期間の健康記録の削除に失敗しました: ${error.toString()}');
    }
  }
}
