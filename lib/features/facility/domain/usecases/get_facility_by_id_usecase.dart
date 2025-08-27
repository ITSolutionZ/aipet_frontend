import '../facility.dart';
import '../repositories/facility_repository.dart';

class GetFacilityByIdUseCase {
  final FacilityRepository repository;

  GetFacilityByIdUseCase(this.repository);

  Future<Facility?> call(String id) async {
    return repository.getFacilityById(id);
  }
}
