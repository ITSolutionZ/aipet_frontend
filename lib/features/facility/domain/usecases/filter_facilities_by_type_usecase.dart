import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class FilterFacilitiesByTypeUseCase {
  final FacilityRepository repository;

  FilterFacilitiesByTypeUseCase(this.repository);

  Future<Result<List<Facility>>> call(FacilityType type) async {
    try {
      final result = await repository.getFacilitiesByType(type);
      if (result.isSuccess) {
        return Result.success('施設をタイプ別にフィルタリングしました', result.dataOrNull ?? []);
      } else {
        return Result.failure('施設のフィルタリングに失敗しました');
      }
    } catch (error) {
      return Result.failure('施設のフィルタリング中にエラーが発生しました: ${error.toString()}');
    }
  }
}
