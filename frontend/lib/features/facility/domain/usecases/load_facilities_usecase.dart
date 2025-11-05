import '../../../../shared/shared.dart';

import '../entities/facility_entity.dart';
import '../repositories/facility_repository.dart';


class LoadFacilitiesUseCase {
  final FacilityRepository repository;

  LoadFacilitiesUseCase(this.repository);

  Future<Result<List<Facility>>> call() async {
    try {
      final result = await repository.getNearbyFacilities();
      if (result.isSuccess) {
        return Result.success('近くの施設を読み込みました', result.dataOrNull ?? []);
      } else {
        return Result.failure('施設の読み込みに失敗しました');
      }
    } catch (error) {
      return Result.failure('施設の読み込み中にエラーが発生しました: ${error.toString()}');
    }
  }
}
