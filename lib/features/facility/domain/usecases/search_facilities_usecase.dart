import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class SearchFacilitiesUseCase {
  final FacilityRepository repository;

  SearchFacilitiesUseCase(this.repository);

  Future<Result<List<Facility>>> call(String query) async {
    try {
      final result = await repository.searchFacilities(query);
      if (result.isSuccess) {
        return Result.success('施設を検索しました', result.dataOrNull ?? []);
      } else {
        return Result.failure('施設の検索に失敗しました');
      }
    } catch (error) {
      return Result.failure('施設の検索中にエラーが発生しました: ${error.toString()}');
    }
  }
}
