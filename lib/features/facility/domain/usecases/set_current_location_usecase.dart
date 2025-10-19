import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class SetCurrentLocationUseCase {
  final FacilityRepository repository;

  SetCurrentLocationUseCase(this.repository);

  Future<Result<void>> call(
    double latitude,
    double longitude,
    String address,
  ) async {
    try {
      final result = await repository.setCurrentLocation(
        latitude,
        longitude,
        address,
      );
      if (result.isSuccess) {
        return Result.success('現在地を設定しました', null);
      } else {
        return Result.failure('現在地の設定に失敗しました');
      }
    } catch (error) {
      return Result.failure('現在地の設定中にエラーが発生しました: ${error.toString()}');
    }
  }
}
