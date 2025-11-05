import '../../../../shared/shared.dart';

import '../../../../../features/pet_health/domain/entities/vaccine_record_entity.dart';
import '../../../../../features/pet_health/domain/entities/weight_record_entity.dart';
import '../../../../../features/pet_health/domain/repositories/pet_health_repository.dart';

/// 건강 기록 생성 UseCase
class CreateHealthRecordUseCase {
  final PetHealthRepository repository;

  CreateHealthRecordUseCase(this.repository);

  /// 체중 기록 생성
  Future<Result<WeightRecordEntity>> createWeightRecord(
    WeightRecordEntity weightRecord,
  ) async {
    try {
      final result = await repository.addWeightRecord(weightRecord);
      return Result.success('体重記録を作成しました', result);
    } catch (error) {
      return Result.failure('体重記録の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 백신 기록 생성
  Future<Result<VaccineRecordEntity>> createVaccineRecord(
    VaccineRecordEntity vaccineRecord,
  ) async {
    try {
      final result = await repository.addVaccineRecord(vaccineRecord);
      return Result.success('ワクチン記録を作成しました', result);
    } catch (error) {
      return Result.failure('ワクチン記録の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 건강 체크 기록 생성
  Future<Result<Map<String, dynamic>>> createHealthCheckRecord(
    String petId,
    Map<String, dynamic> healthData,
  ) async {
    try {
      // 건강 체크 데이터 검증
      if (!_validateHealthData(healthData)) {
        return Result.failure('健康チェックデータが無効です');
      }

      // 실제 구현에서는 repository에 건강 체크 기록 생성 메서드가 필요
      // 현재는 mock 데이터로 처리
      final record = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'petId': petId,
        'data': healthData,
        'createdAt': DateTime.now().toIso8601String(),
      };

      return Result.success('健康チェック記録を作成しました', record);
    } catch (error) {
      return Result.failure('健康チェック記録の作成に失敗しました: ${error.toString()}');
    }
  }

  /// 건강 데이터 검증
  bool _validateHealthData(Map<String, dynamic> data) {
    // 기본적인 검증 로직
    return data.isNotEmpty && data.containsKey('checkDate');
  }
}
