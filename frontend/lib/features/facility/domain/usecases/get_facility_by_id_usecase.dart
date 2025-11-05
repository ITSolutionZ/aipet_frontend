import '../../../../shared/shared.dart';

import '../entities/facility_entity.dart';
import '../repositories/facility_repository.dart';


class GetFacilityByIdUseCase {
  final FacilityRepository repository;

  GetFacilityByIdUseCase(this.repository);

  Future<Result<Facility?>> call(String id) async {
    try {
      final result = await repository.getFacilityById(id);
      if (result.isSuccess) {
        return Result.success('施設情報を取得しました', result.dataOrNull);
      } else {
        return Result.failure('施設情報の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('施設情報の取得中にエラーが発生しました: ${error.toString()}');
    }
  }
}
