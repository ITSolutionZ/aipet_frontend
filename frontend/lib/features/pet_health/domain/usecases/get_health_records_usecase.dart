import 'package:aipet_frontend/features/pet_health/domain/entities/vaccine_record_entity.dart';
import 'package:aipet_frontend/features/pet_health/domain/entities/weight_record_entity.dart';
import 'package:aipet_frontend/features/pet_health/domain/repositories/pet_health_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 건강 기록 조회 UseCase
class GetHealthRecordsUseCase {
  final PetHealthRepository repository;

  GetHealthRecordsUseCase(this.repository);

  /// 펫의 체중 기록 조회
  Future<Result<List<WeightRecordEntity>>> getWeightRecords(
    String petId,
  ) async {
    try {
      final result = await repository.getWeightRecords(petId);
      return Result.success('体重記録を取得しました', result);
    } catch (error) {
      return Result.failure('体重記録の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 펫의 백신 기록 조회
  Future<Result<List<VaccineRecordEntity>>> getVaccineRecords(
    String petId,
  ) async {
    try {
      final result = await repository.getVaccineRecords(petId);
      return Result.success('ワクチン記録を取得しました', result);
    } catch (error) {
      return Result.failure('ワクチン記録の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 최신 체중 기록 조회
  Future<Result<WeightRecordEntity?>> getLatestWeightRecord(
    String petId,
  ) async {
    try {
      final result = await repository.getLatestWeight(petId);
      return Result.success('最新の体重記録を取得しました', result);
    } catch (error) {
      return Result.failure('最新の体重記録の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 다음 백신 접종 예정일 조회
  Future<Result<List<VaccineRecordEntity>>> getUpcomingVaccines(
    String petId,
  ) async {
    try {
      final result = await repository.getUpcomingVaccines(petId);
      return Result.success('次のワクチン接種予定を取得しました', result);
    } catch (error) {
      return Result.failure('次のワクチン接種予定の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 체중 기록 통계 조회
  Future<Result<Map<String, dynamic>>> getWeightStatistics(String petId) async {
    try {
      final weightRecords = await repository.getWeightRecords(petId);
      final statistics = _calculateWeightStatistics(weightRecords);
      return Result.success('体重統計を取得しました', statistics);
    } catch (error) {
      return Result.failure('体重統計の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 백신 만료 예정 목록 조회
  Future<Result<List<VaccineRecordEntity>>> getExpiringVaccines(
    String petId,
    int daysAhead,
  ) async {
    try {
      final allVaccines = await repository.getVaccineRecords(petId);
      final expiringVaccines = allVaccines
          .where((vaccine) => vaccine.isExpiringSoon)
          .toList();
      return Result.success('期限切れ予定のワクチンを取得しました', expiringVaccines);
    } catch (error) {
      return Result.failure('期限切れ予定のワクチンの取得に失敗しました: ${error.toString()}');
    }
  }

  /// 건강 기록 검색
  Future<Result<List<Map<String, dynamic>>>> searchHealthRecords(
    String petId,
    String query,
  ) async {
    try {
      final weightRecords = await repository.getWeightRecords(petId);
      final vaccineRecords = await repository.getVaccineRecords(petId);

      final results = <Map<String, dynamic>>[];

      // 체중 기록에서 검색
      for (final record in weightRecords) {
        if (record.notes?.toLowerCase().contains(query.toLowerCase()) == true) {
          results.add({
            'type': 'weight',
            'record': record,
            'matchedField': 'notes',
          });
        }
      }

      // 백신 기록에서 검색
      for (final record in vaccineRecords) {
        if (record.name.toLowerCase().contains(query.toLowerCase()) ||
            record.doctor.toLowerCase().contains(query.toLowerCase()) ||
            record.notes?.toLowerCase().contains(query.toLowerCase()) == true) {
          results.add({
            'type': 'vaccine',
            'record': record,
            'matchedField': 'name',
          });
        }
      }

      return Result.success('健康記録を検索しました', results);
    } catch (error) {
      return Result.failure('健康記録の検索に失敗しました: ${error.toString()}');
    }
  }

  /// 체중 통계 계산
  Map<String, dynamic> _calculateWeightStatistics(
    List<WeightRecordEntity> records,
  ) {
    if (records.isEmpty) {
      return {
        'currentWeight': 0.0,
        'averageWeight': 0.0,
        'minWeight': 0.0,
        'maxWeight': 0.0,
        'totalRecords': 0,
        'weightChange': 0.0,
        'weightChangePercentage': 0.0,
      };
    }

    final weights = records.map((r) => r.weight).toList();
    final currentWeight = weights.last;
    final averageWeight = weights.reduce((a, b) => a + b) / weights.length;
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    double weightChange = 0.0;
    double weightChangePercentage = 0.0;

    if (weights.length > 1) {
      final previousWeight = weights[weights.length - 2];
      weightChange = currentWeight - previousWeight;
      weightChangePercentage = (weightChange / previousWeight) * 100;
    }

    return {
      'currentWeight': currentWeight,
      'averageWeight': averageWeight,
      'minWeight': minWeight,
      'maxWeight': maxWeight,
      'totalRecords': weights.length,
      'weightChange': weightChange,
      'weightChangePercentage': weightChangePercentage,
    };
  }
}
