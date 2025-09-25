import 'package:aipet_frontend/features/facility/domain/entities/facility_entity.dart';
import 'package:aipet_frontend/features/facility/domain/repositories/facility_repository.dart';

class GetFacilityByIdUseCase {
  final FacilityRepository repository;

  GetFacilityByIdUseCase(this.repository);

  Future<Facility?> call(String id) async {
    final result = await repository.getFacilityById(id);
    if (result.isSuccess) {
      return result.dataOrNull;
    } else {
      return null;
    }
  }
}
